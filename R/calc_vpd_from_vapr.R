#' Calculate vapour pressure deficit from water vapor pressure
#'
#' Follows Abtew and Meleese (2013), Ch. 5 Vapor Pressure Calculation Methods,
#' in Evaporation and Evapotranspiration
#'
#' @param vapr Water vapour pressure (Pa)
#' @param tc temperature, deg C
#' @param patm Atmospehric pressure (Pa)
#' @param elv Elevation above sea level (m) (Used only if \code{patm} is missing 
#' for calculating it based on standard sea level pressure)
#'
#' @return vapor pressure deficit (Pa)
#' @export
#' 
calc_vpd_from_vapr <- function(
  qair = NA,
  vapr = NA,
  tc = NA,
  tmin = NA,
  tmax = NA,
  patm = NA,
  elv = NA
) {
  
  ##-----------------------------------------------------------------------
  ## Ref:      Eq. 5.1, Abtew and Meleese (2013), Ch. 5 Vapor Pressure 
  ##           Calculation Methods, in Evaporation and Evapotranspiration: 
  ##           Measurements and Estimations, Springer, London.
  ##             vpd = 0.611*exp[ (17.27 tc)/(tc + 237.3) ] - vapr
  ##             where:
  ##                 tc = average daily air temperature, deg C
  ##                 vapr  = actual vapor pressure, Pa
  ##-----------------------------------------------------------------------

  ## calculate atmopheric pressure (Pa) assuming standard conditions at sea level (elv=0)
  if (is.na(elv) && is.na(patm) && is.na(vapr)){
    
    warning("calc_vpd(): Either patm or elv must be provided if vapr is not given.")
    vpd <- NA
    
  } else {
    
    if (is.na(vapr)){
      patm <- ifelse(is.na(patm),
                     calc_patm(elv),
                     patm)
    }
    
    ## Calculate VPD as mean of VPD based on Tmin and VPD based on Tmax if they are availble.
    ## Otherwise, use just tc for calculating VPD.
    if(!is.na(tmin) && !is.na(tmax)){
      vpd <- ( calc_vpd_inst( qair=qair, vapr=vapr, tc=tmin, patm=patm) +
                 calc_vpd_inst( qair=qair, vapr=vapr, tc=tmax, patm=patm) )/2
    }else{
      vpd <- calc_vpd_inst( qair=qair, vapr=vapr, tc=tc, patm=patm)
    }
  }
  return( vpd )
}
