# This function reads and processes WATCH-WFDEI files to obtain
# daily temperature and VPD
get_daily_t_vpd <- function(
    path_watch,            # path for WATCH-WFDEI data (.nc in subdirectories)
    year,                  # year for which to read data
    month,                 # string indicating month, e.g. "01"
    crop_map,              # map from rnaturalearth
    save_daily = TRUE      # logical indicating whether to save daily transformed
                             # values for future use, into data/ folder
){
  # Define file paths
  file_tair <- path.expand(paste0(path_watch,
                                  "/Tair_daily/Tair_daily_WFDEI_",
                                  year,
                                  month,
                                  ".nc"))
  file_qair <- path.expand(paste0(path_watch,
                                  "/Qair_daily/Qair_daily_WFDEI_",
                                  year,
                                  month,
                                  ".nc"))
  file_psurf <- path.expand(paste0(path_watch,
                                   "/PSurf_daily/PSurf_daily_WFDEI_",
                                   year,
                                   month,
                                   ".nc"))
  
  # Read a year's data and crop
  tair <- terra::rast(file_tair) |>
    terra::crop(terra::vect(crop_map)) - 273.15   # K -> C
  qair <- terra::rast(file_qair) |>
    terra::crop(terra::vect(crop_map)) 
  psurf <- terra::rast(file_psurf) |>
    terra::crop(terra::vect(crop_map))
  
  # Compute VPD
  vpd <- calc_vpd_from_qair(t = tair,
                            q = qair,
                            P = psurf)
  names(vpd) <- gsub("Tair", "vpd", names(vpd))
  names(tair) <- gsub("Tair", "tavg", names(tair))
  
  if(save_daily){
    # Save daily VPD and temperature calculations at 0.5deg
    terra::writeRaster(c(tair, vpd), 
                       filename = paste0("data/tavg_vpd_daily_",
                                         year, month, ".tif"),
                       overwrite = TRUE)
  }
}
