# Define function to get global monthly temperature climatology
# (1979-2000 to align with WorldClim)
derive_monthly_temperature <- function(
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
  
  # Compute monthly average for each file
  tavg_watch <- lapply(files_tair,
         FUN = function(filename){
           # Read temperature data and crop, then get monthly avg
           terra::rast(filename) |>
             terra::crop(vect(crop_map)) |>
             terra::app(mean, na.rm = TRUE)
         }) |>
    terra::rast() |>                      # convert to single rast
    terra::app(fun = function(i, ff) ff(i),
               cores = cores,
               ff = function(r){
                 mean(r, na.rm = TRUE) - 273.15
               })                         # avg over 22 years, units K -> C
  
  names(tavg_watch) <- paste0("tavg_", month)  
    
  terra::writeRaster(tavg_watch,
                     filename = filename,
                     overwrite = TRUE)
}