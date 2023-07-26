# Calculate vapor pressure deficit from water vapor pressure
calc_vpd_from_vapr <- function(t, e){
  # t: temperature in degrees C
  # e: water vapor pressure in Pa
  
  # Calculate e_S (saturation vapor pressure) as a function of temperature
  e_S <- 611.0 * exp( (17.27 * t)/(t + 237.3) )
  
  # Calculate VPD
  e_S - e
}
