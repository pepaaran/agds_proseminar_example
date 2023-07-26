# Calculate vapor pressure deficit from specific humidity and air pressure
calc_vpd_from_qair <- function(t, q, P){
  # t: temperature in degrees C
  # q: specific humidity in kg/kg
  # P: total air pressure in Pa
  
  # Calculate e_S (saturation vapor pressure) as a function of temperature
  e_S <- 611.0 * exp( (17.27 * t)/(t + 237.3) )
  
  # Approximate e (actual vapor pressure) from total air pressure and specific
  # humidity
  e <- 1.608 * q * P
  
  # Calculate VPD
  e_S - e
}


