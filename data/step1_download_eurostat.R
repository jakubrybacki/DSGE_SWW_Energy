# Step 1: Eurostat & BIS data download, transformation, and Excel export. See README_PL.md.
if (.Platform$OS.type == 'windows') invisible(Sys.setlocale('LC_CTYPE', 'English_United States.utf8'))
# Rscript data/step1_download_eurostat.R --geo=EA --start=2009Q1 --end=2025Q4 --install=true

.get_data_dir <- function() {
  arg <- grep('^--file=', commandArgs(), value=TRUE)
  if (length(arg)) return(dirname(normalizePath(sub('^--file=', '', arg[1]))))
  frame_files <- Filter(Negate(is.null), lapply(sys.frames(), function(f) f$ofile))
  if (length(frame_files)) return(dirname(normalizePath(tail(frame_files, 1)[[1]])))
  if (file.exists('data/utils_io_helpers.R')) return(normalizePath('data'))
  if (file.exists('utils_io_helpers.R')) return(normalizePath('.'))
  getwd()
}
source(file.path(.get_data_dir(), 'utils_io_helpers.R'))

qnum <- function(x) {
  if (any(!grepl('^[0-9]{4}Q[1-4]$', x))) stop('Quarter must be YYYYQ1..YYYYQ4')
  as.integer(substr(x,1,4))*4L + as.integer(substr(x,6,6))-1L
}

qlabel <- function(x) paste0(x %/% 4L,'Q',x %% 4L+1L)

growth <- function(x) {
  if (any(x<=0,na.rm=TRUE)) stop('Nonpositive level in log transformation')
  c(NA_real_,100*diff(log(x)))
}

# Single-series JSON-stat, including sparse zero-based observations/status flags.
decode_series <- function(j) {
  if (!is.null(j$error)) stop(paste(unlist(j$error),collapse=' '))
  ids <- unlist(j$id); sizes <- as.integer(unlist(j$size))
  if (!'time' %in% ids || any(sizes[ids!='time']!=1L) || any(sizes==0L))
    stop('Empty or ambiguous series: check geography and dimension filters')
  idx <- unlist(j$dimension$time$category$index)
  dates <- names(idx)[order(idx)]
  if (!length(dates)) stop('No time periods returned')
  expand <- function(z,default) {
    out <- rep(default,length(dates))
    if (length(z)) {
      v <- unlist(z)
      pos <- if (is.null(names(v))) seq_along(v) else as.integer(names(v))+1L
      if (anyNA(pos) || any(pos<1L | pos>length(out))) stop('Invalid JSON-stat positions')
      out[pos] <- v
    }
    out
  }
  data.frame(time=dates,value=as.numeric(expand(j$value,NA_real_)),status=expand(j$status,''))
}

monthly_quarters <- function(d,adjust=FALSE,model_file=NULL) {
  if (any(!grepl('^[0-9]{4}-[0-9]{2}$',d$time)) || anyDuplicated(d$time)) stop('Invalid monthly dates')
  d <- d[order(d$time),]
  valid <- which(is.finite(d$value))
  if (!length(valid)) stop('Monthly series has no observations')
  # Remove only empty boundary periods; final sample coverage remains strict.
  d <- d[seq(min(valid),max(valid)),]
  expected <- format(seq(as.Date(paste0(d$time[1],'-01')),
    as.Date(paste0(tail(d$time,1),'-01')),by='month'),'%Y-%m')
  if (!identical(d$time,expected) || anyNA(d$value)) stop('Gap in monthly series')
  d$original <- d$value
  if (adjust) {
    if (any(d$value<=0) || nrow(d)<60L) stop('X-13 needs positive levels and >=60 months')
    x <- ts(d$value,start=c(as.integer(substr(d$time[1],1,4)),as.integer(substr(d$time[1],6,7))),frequency=12)
    # Identical procedure on all prices. No trading-day/Easter regressors.
    fit <- seasonal::seas(x,transform.function='log',regression.aictest=NULL,outlier='',automdl='',x11='')
    d$value <- as.numeric(seasonal::final(fit))
    if (!is.null(model_file)) saveRDS(fit,model_file)
  }
  d$q <- as.integer(substr(d$time,1,4))*4L+(as.integer(substr(d$time,6,7))-1L)%/%3L
  groups <- split(seq_len(nrow(d)),d$q)
  out <- do.call(rbind,lapply(groups,function(ix) data.frame(q=d$q[ix[1]],
    value=if (length(ix)==3L && all(is.finite(d$value[ix]))) mean(d$value[ix]) else NA_real_)))
  list(quarterly=out,monthly=d)
}

# Human-readable export of the same observations used by the model transfer.
export_data_xlsx <- function(bundle,path,install=FALSE) {
  ensure_packages('openxlsx',install)
  stopifnot(identical(bundle$format,'sww-data-v1'))
  x <- bundle$observations
  descriptions <- c('Real GDP growth','Real household and NPISH consumption growth',
    'Real fixed investment growth','Headline HICP inflation',
    'Nominal compensation per employee growth','Employment growth',
    'Unemployment rate','Nominal policy or money market rate (see source)',
    'Demeaned log relative energy price')
  units <- c(rep('100 * quarterly log difference',6),'Percent of labour force',
    'Percent per year; quarterly average','100 * log(energy / nonenergy), demeaned')
  wb <- openxlsx::createWorkbook()
  openxlsx::addWorksheet(wb,'Dane')
  openxlsx::writeDataTable(wb,'Dane',x,tableStyle='TableStyleMedium2')
  openxlsx::freezePane(wb,'Dane',firstRow=TRUE,firstCol=TRUE)
  openxlsx::setColWidths(wb,'Dane',cols=1:10,widths=c(14,rep(16,9)))
  openxlsx::addStyle(wb,'Dane',openxlsx::createStyle(numFmt='0.0000'),rows=2:(nrow(x)+1),cols=2:10,gridExpand=TRUE)
  openxlsx::addWorksheet(wb,'Opis')
  cfg <- bundle$config
  info <- data.frame(Pole=c('Gospodarka','Poczatek','Koniec','Liczba kwartalow','Stopa procentowa','Zrodlo stopy','Uwagi o placach'),
    Wartosc=c(cfg$effective_geo,x$quarter[1],tail(x$quarter,1),nrow(x),
      'robs: procent rocznie; model robs/4=crbar+r; nie dzielic ponownie przez 4',cfg$rate_note,
      'dwobs: nominalny wzrost wynagrodzenia; transfer do modelu klasycznego stosuje dodatkowe mapowanie.'))
  openxlsx::writeData(wb,'Opis',info)
  dictionary <- data.frame(Zmienna=names(x)[-1],Opis=descriptions,Jednostka=units)
  openxlsx::writeDataTable(wb,'Opis',dictionary,startRow=11,tableStyle='TableStyleMedium2')
  urls <- data.frame(Seria=names(bundle$sources),URL=vapply(bundle$sources,function(z) if(is.null(z$url)) '' else z$url,character(1)))
  openxlsx::writeData(wb,'Opis',urls,startRow=23)
  openxlsx::setColWidths(wb,'Opis',cols=1:3,widths=c(24,80,48))
  openxlsx::addStyle(wb,'Opis',openxlsx::createStyle(wrapText=TRUE,valign='top'),rows=1:(24+nrow(urls)),cols=1:3,gridExpand=TRUE)
  openxlsx::setRowHeights(wb,'Opis',rows=7,height=125)
  openxlsx::setRowHeights(wb,'Opis',rows=c(6,8,12:20),height=32)
  openxlsx::setRowHeights(wb,'Opis',rows=24:(23+nrow(urls)),height=60)
  openxlsx::freezePane(wb,'Opis',firstRow=TRUE)
  dir.create(dirname(path),recursive=TRUE,showWarnings=FALSE)
  tmp <- tempfile('sww_excel_',tmpdir=dirname(path),fileext='.xlsx')
  on.exit(if(file.exists(tmp)) unlink(tmp),add=TRUE)
  openxlsx::saveWorkbook(wb,tmp,overwrite=TRUE)
  check <- openxlsx::read.xlsx(tmp,sheet='Dane')
  stopifnot(isTRUE(all.equal(check,x,tolerance=1e-12,check.attributes=FALSE)))
  if (!file.copy(tmp,path,overwrite=TRUE)) stop('Cannot save XLSX; close it in Excel: ',path)
  message('XLSX: ',normalizePath(path))
  invisible(path)
}

main <- function(args=commandArgs(trailingOnly=TRUE)) {
  opt <- list(geo='EA',start='2009Q1',end='2026Q2',`price-sa`='x13',`rate-csv`='',
    `rate-code`='IRT_M3',`rate-source`='bis',out='',install='false',`employment-sa`='auto')
  for (a in args) {
    if (!grepl('^--[^=]+=.*$',a)) stop('Use --name=value; see README_PL.md')
    key <- sub('^--([^=]+)=.*$','\\1',a)
    if (!key %in% names(opt)) stop('Unknown option: ',key)
    opt[[key]] <- sub('^--[^=]+=','',a)
  }
  geo <- toupper(opt$geo)
  if (geo=='EA') geo <- 'EA20'
  if (!grepl('^[A-Z0-9_]+$',geo)) stop('Invalid geo')
  begin <- qnum(opt$start); end <- qnum(opt$end)
  if (begin>end) stop('Start must not exceed end')
  if (!opt[['price-sa']] %in% c('x13','none')) stop('price-sa must be x13 or none')
  script_dir <- .get_data_dir()
  if (!opt[['rate-source']] %in% c('bis','eurostat')) stop('rate-source must be bis or eurostat')
  packages <- c('jsonlite',if(opt[['rate-source']]=='bis' && !nzchar(opt[['rate-csv']])) 'xml2',if(opt[['price-sa']]=='x13') 'seasonal','openxlsx')
  ensure_packages(packages,opt$install=='true')
  destination <- opt$out
  if (!nzchar(destination)) destination <- file.path(script_dir,'output',geo)
  if (dir.exists(destination) && !is_generated(destination))
    stop('Existing output is not marked as generated: ',destination)
  out <- tempfile('sww_download_')
  dir.create(out)
  on.exit(unlink(out,recursive=TRUE),add=TRUE)
  published <- FALSE
  on.exit(if (!published) message('Download failed; previous result unchanged.'),add=TRUE)
  dir.create(file.path(out,'raw'),recursive=TRUE); dir.create(file.path(out,'processed'))
  manifest <- list(); options(timeout=max(180,getOption('timeout')))
  fetch <- function(name,dataset,filters,geography=geo) {
    params <- c(list(lang='EN',geo=geography),filters,
      list(untilTimePeriod=paste0(end%/%4L,'-',sprintf('%02d',(end%%4L+1L)*3L))))
    query <- paste(paste0(names(params),'=',vapply(params,URLencode,character(1),reserved=TRUE)),collapse='&')
    url <- paste0('https://ec.europa.eu/eurostat/api/dissemination/statistics/1.0/data/',dataset,'?',query)
    dest <- file.path(out,'raw',paste0(name,'.json')); message('Downloading ',name,' (',geography,')')
    ok <- FALSE
    for (attempt in 1:3) {
      result <- try(download.file(url,dest,mode='wb',quiet=TRUE,method='libcurl'),silent=TRUE)
      if (!inherits(result,'try-error') && result==0L) {ok <- TRUE; break}
      Sys.sleep(attempt)
    }
    if (!ok) stop('Download failed: ',url)
    j <- jsonlite::fromJSON(dest,simplifyVector=FALSE); d <- decode_series(j)
    write.csv(d,file.path(out,'raw',paste0(name,'.csv')),row.names=FALSE,na='')
    manifest[[name]] <<- list(dataset=dataset,filters=params,url=url,
      fetched_utc=format(Sys.time(),tz='UTC',usetz=TRUE),updated=j$updated,
      md5=unname(tools::md5sum(dest)),label=j$label)
    jsonlite::write_json(manifest,file.path(out,'sources.json'),pretty=TRUE,auto_unbox=TRUE)
    d
  }
  grid <- data.frame(q=seq(begin-1L,end))
  add_q <- function(name,d) {
    if ('time' %in% names(d)) d$q <- qnum(sub('-Q','Q',d$time))
    if (anyDuplicated(d$q)) stop('Duplicate quarters: ',name)
    grid[[name]] <<- d$value[match(grid$q,d$q)]
  }
  for (name in c('gdp','consumption','investment')) {
    item <- c(gdp='B1GQ',consumption='P31_S14_S15',investment='P51G')[[name]]
    add_q(name,fetch(name,'namq_10_gdp',list(freq='Q',unit='CLV20_MNAC',s_adj='SCA',na_item=item)))
  }
  add_q('compensation',fetch('compensation','namq_10_gdp',list(freq='Q',unit='CP_MNAC',s_adj='SCA',na_item='D1')))
  employment_adjustments <- list()
  if (!opt[['employment-sa']] %in% c('auto','SCA','SA')) stop('employment-sa must be auto, SCA or SA')
  for (name in c('employment','employees')) {
    adj <- if (opt[['employment-sa']]=='auto') 'SCA' else opt[['employment-sa']]
    f <- list(freq='Q',unit='THS_PER',s_adj=adj,nace_r2='TOTAL',na_item=if(name=='employment') 'EMP_DC' else 'SAL_DC')
    d <- fetch(name,'namq_10_a10_e',f)
    if (opt[['employment-sa']]=='auto' && all(is.na(d$value))) {
      message('No SCA employment series for ',geo,'; using SA (recorded in report).')
      f$s_adj <- adj <- 'SA'
      d <- fetch(paste0(name,'_SA'),'namq_10_a10_e',f)
    }
    employment_adjustments[[name]] <- adj
    add_q(name,d)
  }
  add_q('unemployment',fetch('unemployment','une_rt_q',list(freq='Q',unit='PC_ACT',s_adj='SA',age='Y15-74',sex='T')))
  for (name in c('hicp','energy','nonenergy')) {
    code <- c(hicp='TOTAL',energy='NRG',nonenergy='TOT_X_NRG')[[name]]
    d <- fetch(name,'prc_hicp_minr',list(freq='M',unit='I25',coicop18=code))
    # API end constraint prevents future observations entering seasonal adjustment.
    d <- monthly_quarters(d,opt[['price-sa']]=='x13',file.path(out,'processed',paste0(name,'_x13.rds')))
    write.csv(d$monthly,file.path(out,'processed',paste0(name,'_monthly.csv')),row.names=FALSE)
    add_q(name,d$quarterly)
  }
  if (nzchar(opt[['rate-csv']])) {
    rate_path <- normalizePath(opt[['rate-csv']],mustWork=TRUE)
    d <- read.csv(rate_path,stringsAsFactors=FALSE)
    if (!all(c('quarter','robs') %in% names(d)) || !is.numeric(d$robs)) stop('Rate CSV needs quarter,robs (annual percent)')
    add_q('rate',data.frame(q=qnum(d$quarter),value=d$robs))
    file.copy(rate_path,file.path(out,'raw','external_policy_rate.csv'))
    rate_note <- paste('External quarterly policy rate, annual percent:',rate_path)
  } else {
    euro_entry <- c(AT=1999,BE=1999,DE=1999,ES=1999,FI=1999,FR=1999,IE=1999,
      IT=1999,LU=1999,NL=1999,PT=1999,GR=2001,SI=2007,CY=2008,MT=2008,
      SK=2009,EE=2011,LV=2014,LT=2015,HR=2023,BG=2026)
    rate_geo <- if (grepl('^EA[0-9]+$',geo)) 'EA' else geo
    if (geo %in% names(euro_entry)) {
      if (begin %/% 4L < euro_entry[[geo]]) stop('Sample includes pre-euro period: supply --rate-csv; no automatic currency-regime splice')
      rate_geo <- 'EA'
    }
    if (opt[['rate-source']]=='bis') {
      bis_geo <- if (rate_geo=='EA') 'XM' else rate_geo
      # Daily series includes calendar days. Do not average BIS monthly end-of-period rates.
      first <- as.Date(sprintf('%04d-%02d-01',(begin-1L)%/%4L,((begin-1L)%%4L)*3L+1L))
      after <- as.Date(sprintf('%04d-%02d-01',(end+1L)%/%4L,((end+1L)%%4L)*3L+1L))
      url <- paste0('https://stats.bis.org/api/v1/data/WS_CBPOL/D.',bis_geo,
        '?startPeriod=',first,'&endPeriod=',after-1L)
      dest <- file.path(out,'raw','bis_policy_rate.xml')
      message('Downloading BIS policy rate D.',bis_geo)
      ok <- FALSE
      for (attempt in 1:3) {
        result <- try(download.file(url,dest,mode='wb',quiet=TRUE,method='libcurl'),silent=TRUE)
        if (!inherits(result,'try-error') && result==0L) {ok <- TRUE; break}
        Sys.sleep(attempt)
      }
      if (!ok) stop('BIS download failed: ',url)
      doc <- xml2::read_xml(dest)
      series <- xml2::xml_find_all(doc,"//*[local-name()='Series']")
      if (length(series)!=1L || xml2::xml_attr(series,'REF_AREA')!=bis_geo ||
          xml2::xml_attr(series,'FREQ')!='D') stop('Unexpected BIS series')
      dataset <- xml2::xml_find_first(doc,"//*[local-name()='DataSet']")
      if (xml2::xml_attr(dataset,'UNIT_MULT')!='0' || xml2::xml_attr(dataset,'UNIT_MEASURE')!='368')
        stop('Unexpected BIS rate units; expected percent per year')
      nodes <- xml2::xml_find_all(series,"./*[local-name()='Obs']")
      daily <- data.frame(date=as.Date(xml2::xml_attr(nodes,'TIME_PERIOD')),
        value=as.numeric(xml2::xml_attr(nodes,'OBS_VALUE')),status=xml2::xml_attr(nodes,'OBS_STATUS'))
      daily <- daily[order(daily$date),]
      expected <- seq(first,after-1L,by='day')
      if (anyNA(daily$date) || anyDuplicated(daily$date) ||
          !identical(as.character(daily$date),as.character(expected)))
        stop('Incomplete BIS daily coverage; no interpolation or silent fallback')
      # BIS XM has 32 missing weekend observations in 2024/2025. Carry the
      # unchanged official rate only across weekends bracketed by equal valid rates.
      daily$raw_value <- daily$value
      daily$weekend_carry <- FALSE
      missing_days <- which(!is.finite(daily$value))
      for (ix in missing_days) {
        before <- which(seq_len(nrow(daily))<ix & is.finite(daily$raw_value))
        after_ix <- which(seq_len(nrow(daily))>ix & is.finite(daily$raw_value))
        if (!length(before) || !length(after_ix)) stop('Missing BIS boundary observation')
        lo <- max(before); hi <- min(after_ix)
        if (bis_geo!='XM' || !as.POSIXlt(daily$date[ix])$wday %in% c(0L,6L) ||
            hi-lo>3L || daily$raw_value[lo]!=daily$raw_value[hi])
          stop('Unresolved BIS missing value on ',daily$date[ix])
        daily$value[ix] <- daily$raw_value[lo]; daily$weekend_carry[ix] <- TRUE
      }
      daily$q <- as.integer(format(daily$date,'%Y'))*4L+(as.integer(format(daily$date,'%m'))-1L)%/%3L
      quarters <- aggregate(value~q,daily,mean)
      add_q('rate',quarters)
      write.csv(daily,file.path(out,'processed','bis_policy_rate_daily.csv'),row.names=FALSE)
      write.csv(data.frame(quarter=qlabel(quarters$q),annual_percent=quarters$value,
        quarterly_percent=quarters$value/4),file.path(out,'processed','policy_rate_quarterly.csv'),row.names=FALSE)
      compilation <- xml2::xml_attr(series,'COMPILATION')
      rate_note <- paste('BIS WS_CBPOL D.',bis_geo,': calendar-day quarterly mean; nominal percent per year; robs is annual, model robs/4=crbar+r. Source:',
        xml2::xml_attr(series,'SOURCE_REF'),'Weekend carries:',sum(daily$weekend_carry),'Compilation:',compilation)
      manifest[['policy_rate']] <- list(provider='BIS',dataset='WS_CBPOL',key=paste0('D.',bis_geo),
        url=url,unit='percent per year',aggregation='calendar-day quarterly mean',weekend_carries=sum(daily$weekend_carry),
        source=xml2::xml_attr(series,'SOURCE_REF'),compilation=compilation,
        fetched_utc=format(Sys.time(),tz='UTC',usetz=TRUE),md5=unname(tools::md5sum(dest)))
      jsonlite::write_json(manifest,file.path(out,'sources.json'),pretty=TRUE,auto_unbox=TRUE)
    } else {
      d <- fetch('money_market_rate','irt_st_m',list(freq='M',int_rt=opt[['rate-code']]),rate_geo)
      add_q('rate',monthly_quarters(d)$quarterly)
      rate_note <- paste('PROXY ONLY: Eurostat',opt[['rate-code']],'money market rate, not a central-bank policy rate. Geography:',rate_geo)
    }
  }
  # D1 divided by employees; employment growth includes self-employed.
  grid$nominal_compensation_per_employee <- 1000*grid$compensation/grid$employees
  if (any(as.matrix(grid[c('hicp','energy','nonenergy')])<=0,na.rm=TRUE)) stop('Invalid HICP level')
  relative <- 100*(log(grid$energy)-log(grid$nonenergy))
  obs <- data.frame(quarter=qlabel(grid$q),dyobs=growth(grid$gdp),dcobs=growth(grid$consumption),
    diobs=growth(grid$investment),piobs=growth(grid$hicp),dwobs=growth(grid$nominal_compensation_per_employee),
    deobs=growth(grid$employment),uobs=grid$unemployment,robs=grid$rate,pEobs=relative)[-1,]
  coverage <- data.frame(variable=names(obs)[-1],missing=vapply(obs[-1],function(x) sum(!is.finite(x)),integer(1)))
  write.csv(coverage,file.path(out,'coverage.csv'),row.names=FALSE)
  grid$quarter <- qlabel(grid$q)
  write.csv(grid,file.path(out,'quarterly_levels.csv'),row.names=FALSE,na='')
  if (any(coverage$missing>0L)) {
    write.csv(obs,file.path(out,'INCOMPLETE_observables.csv'),row.names=FALSE,na='')
    stop('Missing observations: inspect coverage.csv / quarterly_levels.csv. No Dynare export; no interpolation or sample shortening.')
  }
  center <- mean(obs$pEobs); obs$pEobs <- obs$pEobs-center
  weights <- fetch('energy_weight','prc_hicp_iw',list(freq='A',coicop18='NRG',statinfo='IW'))
  weights <- weights[as.integer(weights$time)>=begin%/%4L & as.integer(weights$time)<=end%/%4L,]
  weights$share <- weights$value/1000
  write.csv(weights,file.path(out,'energy_weights.csv'),row.names=FALSE)
  omega <- if (nrow(weights) && all(is.finite(weights$share))) mean(weights$share) else NA_real_
  write.csv(obs,file.path(out,'observables.csv'),row.names=FALSE)
  m <- c('% Generated from Eurostat and selected rate source; see report.txt and sources.json.',
    paste0('% Sample: ',opt$start,' -- ',opt$end,'; ',geo),paste0('% ',rate_note))
  for (name in names(obs)[-1]) m <- c(m,paste0(name,' = ['),sprintf('%.15g;',obs[[name]]),'];')
  writeLines(m,file.path(out,'energy_data.m'))
  report <- c(paste('Geography:',geo,'(EA alias = EA20, fixed composition)'),
    paste('Sample:',opt$start,'--',opt$end,'; observations:',nrow(obs)),
    paste('HICP seasonal adjustment:',opt[['price-sa']]),paste('Employment adjustment:',paste(names(employment_adjustments),unlist(employment_adjustments),collapse='; ')),rate_note,
    'Consumption: households + NPISH; investment: gross fixed capital formation.',
    'Wages: nominal D1 per employee SAL_DC; employment: EMP_DC.',
    'Growth/inflation: 100*quarterly log difference; no annualisation or demeaning.',
    paste('pEobs centering constant (estimation sample only):',format(center,digits=16)),
    paste('Candidate omegaE from mean annual HICP weights:',omega),
    'nu requires separate SUT/IO calibration, not HICP weights.',
    'HICP ex energy retains food. Retail energy proxies the common model energy price.',
    'X-13 uses only data through sample end, but latest revised data: not a real-time vintage.',
    'Inspect raw status flags and X-13 diagnostics before estimation.',
    'Model remains calibrated: priors, constants and identification need a separate estimation specification.')
  writeLines(report,file.path(out,'report.txt'))
  jsonlite::write_json(list(options=opt,effective_geo=geo,energy_center=center,
    omegaE_candidate=omega,rate_note=rate_note,rate_unit='annual_percent',rate_measurement='robs/4=crbar+r'),file.path(out,'config.json'),pretty=TRUE,auto_unbox=TRUE)
  capture.output(sessionInfo(),file=file.path(out,'sessionInfo.txt'))
  rownames(obs) <- NULL
  bundle <- pack_download(out)
  stage <- new_stage(destination)
  saveRDS(bundle,file.path(stage,'dane.rds'),compress='xz')
  stopifnot(isTRUE(all.equal(readRDS(file.path(stage,'dane.rds'))$observations,obs,tolerance=1e-12)))
  export_data_xlsx(bundle,file.path(stage,paste0(geo,'.xlsx')))
  publish_directory(stage,destination)
  published <- TRUE
  message('DONE: ',normalizePath(destination),'\n',rate_note)
  invisible(obs)
}
if (sys.nframe()==0L) main()
