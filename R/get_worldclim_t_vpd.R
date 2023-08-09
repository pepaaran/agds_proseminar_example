# This function reads and processes WorldClim files to obtain
# monthly temperature and VPD
get_worldclim_t_vpd <- function(
    path_worldclim,        # path for WorldClim data
    month,                 # string indicating month, e.g. "01"
    crop_map               # map from rnaturalearth
){
  # Read temperature data and crop
  file_tavg <- paste0(path_worldclim, "/wc2.1_30s_tavg_", month, ".tif")
  tavg <- terra::rast(file_tavg) |>
    terra::crop(terra::vect(crop_map))
  
  # Read water vapor pressure data and crop
  file_vapr <- paste0(path_worldclim, "/wc2.1_30s_vapr_", month, ".tif")
  vapr <- terra::rast(file_vapr) |>
    terra::crop(terra::vect(crop_map)) * 1000         # kPa -> Pa
  
  # Compute VPD
  vpd <- calc_vpd_from_vapr(t = tavg, 
                            e = vapr)
  names(vpd) <- paste0("vpd_", month)
  
  # Return a single raster with all values
  c(tavg, vpd)
}