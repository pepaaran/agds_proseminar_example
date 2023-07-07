#' Calculate vapour pressure deficit from specific humidity
#'
#' Follows Abtew and Meleese (2013), Ch. 5 Vapor Pressure Calculation Methods,
#' in Evaporation and Evapotranspiration
#'
#' @param qair Air specific humidity (g g-1)
#' @param tc temperature, deg C
#' @param elv Elevation above sea level (m) (Used only if \code{patm} is missing 
#' for calculating it based on standard sea level pressure)
#'
#' @return vapor pressure deficit (Pa)
#' @export
#' 
calc_vpd_from_qair <- function(
    qair,
    tc,
    elv
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
  
  # Calculate the mass mixing ratio of water vapor to dry air (dimensionless)
  wair <- qair / (1 - qair)
  
  # Define constants
  kR  = 8.3143   # universal gas constant, J/mol/K (Allen, 1973)
  kMv = 18.02    # molecular weight of water vapor, g/mol (Tsilingiris, 2008)
  kMa = 28.963   # molecular weight of dry air, g/mol (Tsilingiris, 2008)
  
  # Calculate atmospheric pressure (Pa) from elevation
  patm <- calc_patm(elv)
  
  # Calculate water vapor pressure from atmospheric pressure (Pa)
  rv <- kR / kMv
  rd <- kR / kMa
  vapr = patm * wair * rv / (rd + wair * rv)
  
  # Calculate saturation water vapor pressure in Pa based on average daily 
  # air temperature (in C)
  svapr <- 611.0 * exp( (17.27 * tc)/(tc + 237.3) )
  
  # Calculate VPD
  vpd <- svapr - vapr
  
  return(vpd)
}


