# Dependencies live in the standard R user library, never inside this project.
ensure_packages <- function(packages,install=FALSE) {
  missing <- packages[!vapply(packages,requireNamespace,logical(1),quietly=TRUE)]
  if (length(missing) && install) {
    lib <- strsplit(Sys.getenv('R_LIBS_USER'),.Platform$path.sep,fixed=TRUE)[[1]][1]
    if (!nzchar(lib)) stop('R_LIBS_USER is not configured')
    lib <- path.expand(lib)
    dir.create(lib,recursive=TRUE,showWarnings=FALSE)
    .libPaths(c(lib,.libPaths()))
    install.packages(missing,lib=lib,repos='https://cloud.r-project.org')
  }
  missing <- packages[!vapply(packages,requireNamespace,logical(1),quietly=TRUE)]
  if (length(missing)) stop('Missing R packages: ',paste(missing,collapse=', '),'; use --install=true')
}
is_generated <- function(path) {
  if (file.exists(file.path(path,'.sww_generated'))) return(TRUE)
  file <- file.path(path,'dane.rds')
  if (!file.exists(file)) return(FALSE)
  bundle <- tryCatch(readRDS(file),error=function(e) NULL)
  is.list(bundle) && identical(bundle$format,'sww-data-v1')
}
pack_download <- function(directory) {
  files <- list.files(directory,recursive=TRUE,all.files=TRUE,full.names=FALSE)
  files <- files[!dir.exists(file.path(directory,files)) & !files %in% c('.sww_generated','dane.rds')]
  provenance <- setNames(lapply(files,function(f) readBin(file.path(directory,f),'raw',n=file.info(file.path(directory,f))$size)),files)
  list(format='sww-data-v1',observations=read.csv(file.path(directory,'observables.csv')),
    config=jsonlite::fromJSON(file.path(directory,'config.json'),simplifyVector=FALSE),
    sources=jsonlite::fromJSON(file.path(directory,'sources.json'),simplifyVector=FALSE),
    hicp_monthly=read.csv(file.path(directory,'processed','hicp_monthly.csv')),
    provenance=provenance)
}
# Publish a complete generated directory; preserve previous data on failure.
new_stage <- function(destination) {
  parent <- dirname(destination)
  dir.create(parent,recursive=TRUE,showWarnings=FALSE)
  parent <- normalizePath(parent,winslash='/',mustWork=TRUE)
  stage <- tempfile('.sww_stage_',tmpdir=parent)
  if (!dir.create(stage)) stop('Cannot create staging directory')
  stage
}
publish_directory <- function(stage,destination) {
  stage <- normalizePath(stage,winslash='/',mustWork=TRUE)
  parent <- normalizePath(dirname(destination),winslash='/',mustWork=TRUE)
  destination <- file.path(parent,basename(destination))
  if (dirname(stage)!=parent || !startsWith(basename(stage),'.sww_stage_')) stop('Unsafe staging path')
  if (dir.exists(destination) && !is_generated(destination))
    stop('Refusing to replace an unmarked directory: ',destination)
  if (!file.exists(file.path(stage,'dane.rds'))) writeLines('Generated SWW data directory',file.path(stage,'.sww_generated'))
  backup <- tempfile('.sww_previous_',tmpdir=parent)
  exists <- dir.exists(destination)
  if (exists && !file.rename(destination,backup)) stop('Cannot move previous data; close files and retry')
  if (!file.rename(stage,destination)) {
    if (exists && !file.rename(backup,destination)) stop('Restore previous data from: ',backup)
    stop('Publish failed; previous data restored')
  }
  if (exists) {
    checked <- normalizePath(backup,winslash='/',mustWork=TRUE)
    if (dirname(checked)!=parent || !startsWith(basename(checked),'.sww_previous_')) stop('Unsafe cleanup path')
    unlink(checked,recursive=TRUE)
  }
  invisible(destination)
}
