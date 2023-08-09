# This function reads the daily T and VPD files, downscales them and de-biases
# the data using WorldClim files
debias_t_vpd <- function(
    year,                    # year of data to read
    month,                   # string indicating month, e.g. "01"
    bias,                    # raster indicating monthly bias
                               # clim_monthly_resampled - clim_monthly_worldclim
    cores                    # number of cores for parallelisation over pixels
){
  # Read daily data derived from WATCH-WFDEI
  file_daily <- paste0("data/tavg_vpd_daily_",
                       year,
                       month,
                       ".tif")
  
  # Resample daily data with bilinear interpolation to 1/12 deg
  daily <- terra::rast(file_daily) |>
    terra::resample(bias) |>
    terra::crop(bias)
  
  # Get number of days in month
  n <- terra::nlyr(daily)/2
  
  # De-bias
  daily_debiased <- terra::app(c(bias, daily),
                               fun = function(i, ff) ff(i),
                               cores = cores,
                               ff = function(r) debias(r, n))
  
  # Save in file
  terra::writeRaster(daily_debiased, 
                     filename = paste0("data/tavg_vpd_daily_downscaled_",
                                       year, month, ".tif"),
                     overwrite = TRUE)
}

# Define a simple function to de-bias daily climatology
debias <- function(r, n){
  # n: number of days in month
  # r: raster including 
  #    t_bias | vpd_bias | t_01 ... t_n | vpd_01 ... vpd_n
  
  # Substract bias from daily values
  t <- r[2 + (1:n) ] - r[1]
  vpd <- r[2 + n + (1:n) ] - r[2]
  
  # Return temp and vpd
  c(t, vpd)
}