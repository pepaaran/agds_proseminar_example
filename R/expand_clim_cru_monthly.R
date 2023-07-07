# Interpolates monthly data to daily data using polynomials or linear
# for a single year

expand_clim_cru_monthly <- function( mdf, cruvars ){
  
  ddf <- purrr::map(as.list(unique(mdf$year)),
                    ~expand_clim_cru_monthly_byyr( ., mdf, cruvars ) ) %>%
    bind_rows()
  
  return( ddf )
  
}

# ---------------------------------------------------------------

# Interpolates monthly data to daily data using polynomials or linear
# for a single year

expand_clim_cru_monthly_byyr <- function( yr, mdf, cruvars ){
  
  # define variables  
  year <- ccov_int <- NULL
  nmonth <- 12
  
  startyr <- mdf$year %>% first()
  endyr   <- mdf$year %>% last()
  
  yr_pvy <- max(startyr, yr-1)
  yr_nxt <- min(endyr, yr+1)
  
  # add first and last year to head and tail of 'mdf'
  first <- mdf[1:12,] %>% mutate( year = year - 1)
  last  <- mdf[(nrow(mdf)-11):nrow(mdf),] %>% mutate( year = year + 1 )
  
  ddf <- init_dates_dataframe( yr, yr )
  
  
  # air temperature: interpolate using polynomial
  
  if ("temp" %in% cruvars){
    mtemp     <- dplyr::filter( mdf, year==yr     )$temp
    mtemp_pvy <- dplyr::filter( mdf, year==yr_pvy )$temp
    mtemp_nxt <- dplyr::filter( mdf, year==yr_nxt )$temp
    if (length(mtemp_pvy)==0){
      mtemp_pvy <- mtemp
    }
    if (length(mtemp_nxt)==0){
      mtemp_nxt <- mtemp
    }
    
    ddf <- init_dates_dataframe( yr, yr ) %>%
      mutate(
        temp = monthly2daily(
          mtemp,
          "polynom",
          mtemp_pvy[nmonth],
          mtemp_nxt[1],
          leapyear = lubridate::leap_year(yr) 
        ) 
      ) %>%
      right_join( ddf, by = c("date") )
  }
  
  
  # daily minimum air temperature: interpolate using polynomial
  
  if ("tmin" %in% cruvars){
    mtmin     <- dplyr::filter( mdf, year==yr     )$tmin
    mtmin_pvy <- dplyr::filter( mdf, year==yr_pvy )$tmin
    mtmin_nxt <- dplyr::filter( mdf, year==yr_nxt )$tmin
    if (length(mtmin_pvy)==0){
      mtmin_pvy <- mtmin
    }
    if (length(mtmin_nxt)==0){
      mtmin_nxt <- mtmin
    }
    
    ddf <- init_dates_dataframe( yr, yr ) %>%
      mutate( tmin = monthly2daily( mtmin, "polynom", mtmin_pvy[nmonth], mtmin_nxt[1], leapyear = lubridate::leap_year(yr) ) ) %>%
      right_join( ddf, by = c("date") )
  }
  
  
  # daily minimum air temperature: interpolate using polynomial
  
  if ("tmax" %in% cruvars){
    mtmax     <- dplyr::filter( mdf, year==yr     )$tmax
    mtmax_pvy <- dplyr::filter( mdf, year==yr_pvy )$tmax
    mtmax_nxt <- dplyr::filter( mdf, year==yr_nxt )$tmax
    if (length(mtmax_pvy)==0){
      mtmax_pvy <- mtmax
    }
    if (length(mtmax_nxt)==0){
      mtmax_nxt <- mtmax
    }
    
    ddf <- init_dates_dataframe( yr, yr ) %>%
      mutate( tmax = monthly2daily( mtmax, "polynom", mtmax_pvy[nmonth], mtmax_nxt[1], leapyear = lubridate::leap_year(yr) ) ) %>%
      right_join( ddf, by = c("date") )
  }
  
  
  # precipitation: interpolate using weather generator
  
  if ("prec" %in% cruvars){
    mprec <- dplyr::filter( mdf, year==yr )$prec
    mwetd <- dplyr::filter( mdf, year==yr )$wetd
    
    if (any(!is.na(mprec))&&any(!is.na(mwetd))){
      ddf <-  init_dates_dataframe( yr, yr ) %>%
        mutate( prec = get_daily_prec( mprec, mwetd, leapyear = lubridate::leap_year(yr) ) ) %>%
        right_join( ddf, by = c("date") )
    }
  }
  
  
  # cloud cover: interpolate using polynomial
  
  if ("ccov" %in% cruvars){
    mccov     <- dplyr::filter( mdf, year==yr     )$ccov
    mccov_pvy <- dplyr::filter( mdf, year==yr_pvy )$ccov
    mccov_nxt <- dplyr::filter( mdf, year==yr_nxt )$ccov
    if (length(mccov_pvy)==0){
      mccov_pvy <- mccov
    }
    if (length(mccov_nxt)==0){
      mccov_nxt <- mccov
    }
    
    ddf <-  init_dates_dataframe( yr, yr ) %>%
      mutate( ccov_int = monthly2daily( mccov, "polynom", mccov_pvy[nmonth], mccov_nxt[1], leapyear = lubridate::leap_year(yr) ) ) %>%
      # Reduce CCOV to a maximum 100%
      mutate( ccov = ifelse( ccov_int > 100, 100, ccov_int ) ) %>%
      right_join( ddf, by = c("date") )
  }
  
  
  # VPD: interpolate using polynomial
  
  if ("vap" %in% cruvars){
    mvap     <- dplyr::filter( mdf, year==yr     )$vap
    mvap_pvy <- dplyr::filter( mdf, year==yr_pvy )$vap
    mvap_nxt <- dplyr::filter( mdf, year==yr_nxt )$vap
    if (length(mvap_pvy)==0){
      mvap_pvy <- mvap
    }
    if (length(mvap_nxt)==0){
      mvap_nxt <- mvap
    }
    
    ddf <- init_dates_dataframe( yr, yr ) %>%
      mutate( vap = monthly2daily( mvap, "polynom", mvap_pvy[nmonth], mvap_nxt[1], leapyear = lubridate::leap_year(yr) ) ) %>%
      right_join( ddf, by = c("date") )
    
  }
  
  return( ddf )
  
}
