# Define function to get global monthly climatology 
# (1979-2000 to align with WorldClim)
derive_monthly_vpd <- function(
    data_path,   # path for WATCH-WFDEI data
    month,       # month number in character, e.g. "01"
    crop_map,    # map from rnaturalearth to crop global map
    filename,    # name for the output file
    cores        # number of cores for parallel computation
){
  # Read data from 1979 to 2000
  files_tair <- list.files(paste0(data_path, "/Tair_daily"),
                          pattern = paste0("*", month,".nc"),
                          full.names = TRUE)[1:22]
  files_qair <- list.files(paste0(data_path, "/Qair_daily"),
                           pattern = paste0("*", month,".nc"),
                           full.names = TRUE)[1:22]
  files_psurf <- list.files(paste0(data_path, "/PSurf_daily"),
                           pattern = paste0("*", month,".nc"),
                           full.names = TRUE)[1:22]
  
  # Compute monthly average VPD for each year
  vpd_watch <- lapply(1:22,
                       FUN = function(y){
                         # Read a year's data and crop
                         tair <- terra::rast(files_tair[y]) |>
                           terra::crop(terra::vect(crop_map)) - 273.15   # K -> C
                         qair <- terra::rast(files_qair[y]) |>
                           terra::crop(terra::vect(crop_map)) 
                         psurf <- terra::rast(files_psurf[y]) |>
                           terra::crop(terra::vect(crop_map))
                         
                         # Compute VPD
                         vpd <- calc_vpd_from_qair(tc = tair,
                                                   qair = qair,
                                                   patm = psurf)
                         names(vpd) <- gsub("Tair", "vpd", names(vpd))
                         
                         # Save daily VPD calculations at 0.5deg
                         terra::writeRaster(vpd, 
                                            filename = paste0("data/vpd_daily_",
                                                              1978+y, month, ".tif"),
                                            overwrite = TRUE)
                         # Save daily temperature calculations at 0.5deg
                         terra::writeRaster(tair,
                                            filename = paste0("data/tair_daily_",
                                                              1978+y, month, ".tif"),
                                            overwrite = TRUE)
                         
                         # Compute monthly average
                         vpd |>
                           terra::app(mean, na.rm = TRUE)
                       }) |>
    terra::rast() |>                      # convert to single rast
    terra::app(fun = function(i, ff) ff(i),
               cores = cores,
               ff = function(r){
                 mean(r, na.rm = TRUE)
               })                         # avg over 22 years
  
  names(vpd_watch) <- paste0("vpd_", month)  
  
  terra::writeRaster(vpd_watch,
                     filename = filename,
                     overwrite = TRUE)
}

