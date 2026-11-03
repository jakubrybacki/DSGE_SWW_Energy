# Step 2: Transfer observables to DSGE model folders. See README_PL.md.
# Rscript data/step2_transfer_to_models.R --geo=EA --install=true
if (.Platform$OS.type=='windows') invisible(Sys.setlocale('LC_CTYPE','English_United States.utf8'))

.get_data_dir <- function() {
  arg <- grep('^--file=', commandArgs(), value=TRUE)
  if (length(arg)) return(dirname(normalizePath(sub('^--file=', '', arg[1]))))
  frame_files <- Filter(Negate(is.null), lapply(sys.frames(), function(f) f$ofile))
  if (length(frame_files)) return(dirname(normalizePath(tail(frame_files, 1)[[1]])))
  if (file.exists('data/utils_io_helpers.R')) return(normalizePath('data'))
  if (file.exists('utils_io_helpers.R')) return(normalizePath('.'))
  getwd()
}

transfer_main <- function(args=commandArgs(trailingOnly=TRUE)) {
  opt <- list(geo='EA',install='false')
  for(a in args) {
    if(!grepl('^--[^=]+=.*$',a)) stop('Use --geo=EA / --geo=PL / --geo=ALL and --install=true')
    key <- sub('^--([^=]+)=.*$','\\1',a)
    if(!key %in% names(opt)) stop('Unknown option: ',key)
    opt[[key]] <- sub('^--[^=]+=','',a)
  }
  data_dir <- .get_data_dir()
  root <- normalizePath(file.path(data_dir,'..'),winslash='/',mustWork=TRUE)
  source(file.path(data_dir,'utils_io_helpers.R'),local=TRUE)
  ensure_packages(c('jsonlite','R.matlab'),opt$install=='true')
  geo <- toupper(opt$geo)
  if(geo=='EA') geo <- 'EA20'
  if(!grepl('^[A-Z0-9_]+$',geo)) stop('Invalid geography')
  geos <- if(geo=='ALL') basename(list.dirs(file.path(data_dir,'output'),recursive=FALSE)) else geo
  geos <- geos[grepl('^[A-Z0-9_]+$',geos)]
  if(!length(geos)) stop('No country directories')
  vars <- c('dyobs','dcobs','diobs','piobs','dwobs','deobs','uobs','robs','pEobs')
  quarter_id <- function(x) {
    if(anyNA(x) || any(!grepl('^[0-9]{4}Q[1-4]$',x))) stop('Invalid quarter labels')
    as.integer(substr(x,1,4))*4L+as.integer(substr(x,6,6))-1L
  }
  for(g in geos) {
    src <- file.path(data_dir,'output',g)
    bundle <- readRDS(file.path(src,'dane.rds'))
    if(!identical(bundle$format,'sww-data-v1')) stop('Unsupported data bundle')
    obs <- bundle$observations
    cfg <- bundle$config
    if(!is.null(cfg$rate_unit) && cfg$rate_unit!='annual_percent') stop('Rate units incompatible with model: expected annual_percent')
    if(!identical(cfg$effective_geo,g)) stop('Country mismatch: ',g)
    if(!identical(names(obs),c('quarter',vars)) || !nrow(obs)) stop('Invalid observable columns')
    dates <- quarter_id(obs$quarter)
    if(any(diff(dates)!=1L) || anyDuplicated(dates)) stop('Non-contiguous or duplicate quarters')
    if(obs$quarter[1]!=cfg$options$start || tail(obs$quarter,1)!=cfg$options$end) stop('Sample/config mismatch')
    if(!all(vapply(obs[vars],is.numeric,logical(1))) || any(!is.finite(as.matrix(obs[vars])))) stop('Nonfinite/non-numeric observations')
    # Original classical equation implies nominal growth minus change in inflation.
    prices <- bundle$hicp_monthly
    if(anyDuplicated(prices$time) || any(!grepl('^[0-9]{4}-[0-9]{2}$',prices$time))) stop('Invalid monthly HICP dates')
    pq <- as.integer(substr(prices$time,1,4))*4L+(as.integer(substr(prices$time,6,7))-1L)%/%3L
    groups <- split(seq_len(nrow(prices)),pq)
    h <- vapply(groups,function(ix) if(length(ix)==3L && all(is.finite(prices$value[ix]))) mean(prices$value[ix]) else NA_real_,numeric(1))
    keys <- as.integer(names(h))
    if(any(h<=0,na.rm=TRUE)) stop('Nonpositive HICP')
    lagpi <- 100*(log(h[match(dates-1L,keys)])-log(h[match(dates-2L,keys)]))
    nowpi <- 100*(log(h[match(dates,keys)])-log(h[match(dates-1L,keys)]))
    if(any(!is.finite(lagpi)) || any(!is.finite(nowpi))) stop('Classical wage mapping needs two prior complete HICP quarters')
    if(max(abs(nowpi-obs$piobs))>1e-8) stop('HICP/observables mismatch')
    prepared <- list()
    for(model in c('SWW_klasyczny','SWW_energia_w_produkcji')) {
      if(!dir.exists(file.path(root,model))) stop('Model folder missing: ',model)
      selected <- if(model=='SWW_klasyczny') vars[vars!='pEobs'] else vars
      x <- obs[selected]
      wage_note <- 'dwobs = nominal compensation per employee growth.'
      if(model=='SWW_klasyczny') {
        x$dwobs <- obs$dwobs-(obs$piobs-lagpi)
        wage_note <- 'Legacy classical equation: dwobs = nominal growth - (piobs(t)-piobs(t-1)); headline HICP used as common inflation proxy.'
      }
      dest <- file.path(root,model,'data',g)
      if(dir.exists(dest) && !file.exists(file.path(dest,'.sww_generated'))) stop('Unmarked destination: ',dest)
      stage <- new_stage(dest)
      payload <- lapply(x,function(v) matrix(v,ncol=1))
      # Include both legacy and underscored names for Dynare varobs compatibility
      var_mapping <- c(dyobs='dy_obs',dcobs='dc_obs',diobs='di_obs',piobs='pi_obs',
                       dwobs='dw_obs',deobs='de_obs',uobs='u_obs',robs='r_obs',pEobs='p_e_obs')
      for(v in names(x)) {
        if(v %in% names(var_mapping)) payload[[var_mapping[[v]]]] <- matrix(x[[v]],ncol=1)
      }
      payload$sample_year <- matrix(dates%/%4L,ncol=1)
      payload$sample_quarter <- matrix(dates%%4L+1L,ncol=1)
      do.call(R.matlab::writeMat,c(list(con=file.path(stage,'dane.mat')),payload,list(fixNames=FALSE)))
      m <- c('% Generated by data/step2_transfer_to_models.R',paste0('% ',g,': ',obs$quarter[1],' -- ',tail(obs$quarter,1)),
        paste0('% ',wage_note),'% robs: annual percent; matches robs/4=crbar+r; no additional division by 4.',paste0('% ',cfg$rate_note))
      for(n in names(payload)) m <- c(m,paste0(n,' = ['),sprintf('%.17g;',payload[[n]]),'];')
      writeLines(m,file.path(stage,'dane.m'))
      write.csv(cbind(quarter=obs$quarter,x),file.path(stage,'observables.csv'),row.names=FALSE)
      for(f in c('config.json','sources.json','report.txt')) {
        writeBin(bundle$provenance[[f]],file.path(stage,paste0('source_',f)))
      }
      writeLines(c(paste('Model:',model),paste('Country:',g),paste('Sample:',obs$quarter[1],tail(obs$quarter,1)),
        paste('Observables:',paste(selected,collapse=' ')),wage_note,
        'Both exports use headline HICP as inflation proxy; no equations or calibration changed.',cfg$rate_note,
        'MAT file contains column vectors and sample_year/sample_quarter.',
        "Load from MATLAB using load('data/COUNTRY/dane.mat'). No estimation is started."),file.path(stage,'README.txt'))
      jsonlite::write_json(list(model=model,geo=g,source_md5=unname(tools::md5sum(file.path(src,'dane.rds'))),
        generated_utc=format(Sys.time(),tz='UTC',usetz=TRUE),wage_mapping=wage_note),
        file.path(stage,'export.json'),pretty=TRUE,auto_unbox=TRUE)
      prepared[[model]] <- list(stage=stage,dest=dest)
    }
    for(p in prepared) {publish_directory(p$stage,p$dest); message('EXPORTED: ',p$dest)}
  }
  invisible(geos)
}
if(sys.nframe()==0L) transfer_main()
