# This function computes the monthly average climatology from WATCH-WFDEI
# data between the years 1979 to 2000. 
compute_monthly_climatology <- function(
    path_watch,            # path for WATCH-WFDEI data (.nc in subdirectories)
    crop_map,              # map from rnaturalearth
    month,                 # string indicating month, e.g. "01"
    cores,                 # number of cores for parallelization over pixels
    save_daily = TRUE      # logical indicating whether to save daily transformed
                             # values for future use, into data/ folder
){
  
  years <- 1979:2000
  
  clim_monthly <- lapply(years,
         FUN = function(y){
           # Define file paths
           file_tair <- path.expand(paste0(path_watch,
                                            "/Tair_daily/Tair_daily_WFDEI_",
                                            y,
                                            month,
                                            ".nc"))
           file_qair <- path.expand(paste0(path_watch,
                                            "/Qair_daily/Qair_daily_WFDEI_",
                                            y,
                                            month,
                                            ".nc"))
           file_psurf <- path.expand(paste0(path_watch,
                                             "/PSurf_daily/PSurf_daily_WFDEI_",
                                             y,
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
                                                  y, month, ".tif"),
                                overwrite = TRUE)             
           }
           
           # Compute monthly average
           tair_monthly <- tair |>
             terra::app(mean, na.rm = TRUE)
           names(tair_monthly) <- paste0("tair_", month)
           
           vpd_monthly <- vpd |>
             terra::app(mean, na.rm = TRUE)
           names(vpd_monthly) <- paste0("vpd_", month)
           
           
           c(tair_monthly, vpd_monthly)
         }) |>
    terra::rast() |>                      # convert to single rast
    terra::app(fun = function(i, ff) ff(i),
               cores = cores,
               ff = function(r){
                 # Separate temperature and vpd
                 mean_t <- mean(r[seq(from = 1, to = length(r), by = 2)],
                                na.rm = TRUE)
                 mean_vpd <- mean(r[seq(from = 2, to = length(r), by = 2)],
                                  na.rm = TRUE)
                 c(mean_t, mean_vpd)
               })                         # avg over 22 years
  # Match names to WorldClim data
  names(clim_monthly) <- c(paste0("tavg_", month),
                           paste0("vpd_", month))
  # Return clim_monthly
  clim_monthly
}
