#' Calculate instantenous VPD from ambient conditions
#' 
#' Follows Abtew and Meleese (2013), Ch. 5 Vapor Pressure Calculation Methods,
#' in Evaporation and Evapotranspiration
#' 
#' @param qair Air specific humidity (g g-1)
#' @param eact Water vapour pressure (Pa)
#' @param tc temperature, deg C
#' @param patm Atmospehric pressure (Pa)
#' @param elv Elevation above sea level (m) (Used only if \code{patm} is missing 
#' for calculating it based on standard sea level pressure)
#'
#' @return instantenous VPD from ambient conditions
#' @export

calc_vpd_inst <- function(
    qair=NA,
    eact=NA, 
    tc=NA,
    patm=NA,
    elv=NA
) {
  
  ##-----------------------------------------------------------------------
  ## Ref:      Eq. 5.1, Abtew and Meleese (2013), Ch. 5 Vapor Pressure 
  ##           Calculation Methods, in Evaporation and Evapotranspiration: 
  ##           Measurements and Estimations, Springer, London.
  ##             vpd = 0.611*exp[ (17.27 tc)/(tc + 237.3) ] - ea
  ##             where:
  ##                 tc = average daily air temperature, deg C
  ##                 eact  = actual vapor pressure, Pa
  ##-----------------------------------------------------------------------
  
  if (is.na(eact)){
    # kTo = 288.15   # base temperature, K (Prentice, unpublished)
    kR  = 8.3143   # universal gas constant, J/mol/K (Allen, 1973)
    kMv = 18.02    # molecular weight of water vapor, g/mol (Tsilingiris, 2008)
    kMa = 28.963   # molecular weight of dry air, g/mol (Tsilingiris, 2008)
    
    ## calculate the mass mixing ratio of water vapor to dry air (dimensionless)
    wair <- qair / (1 - qair)
    
    ## calculate water vapor pressure 
    rv <- kR / kMv
    rd <- kR / kMa
    eact = patm * wair * rv / (rd + wair * rv)  
  }
  
  ## calculate saturation water vapour pressure in Pa
  esat <- 611.0 * exp( (17.27 * tc)/(tc + 237.3) )
  
  ## calculate VPD in units of Pa
  vpd <- ( esat - eact )    
  
  ## this empirical equation may lead to negative values for VPD
  ## (happens very rarely). assume positive...
  vpd <- max( 0.0, vpd )
  
  return( vpd )
}