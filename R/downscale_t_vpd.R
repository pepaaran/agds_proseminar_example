# This function contains the whole workflow to downscale daily VPD and
# temperature to a finer spatial grid, starting with WATCH-WFDEI and WorldClim
# data.
downscale_t_vpd <- function(
    path_worldclim,           # path for Worldclim data
    path_watch,               # path for WATCH-WFDEI data (.nc in subdirectories)
    crop_map,                 # map from rnatural earth
    month,                    # string indicating month, e.g. "01"
    cores                     # number of cores for parallelisation over pixels
){
  
  # Compute average monthly climatology from WATCH-WFDEI over 1979-2000
  clim_monthly <- compute_monthly_climatology(
    path_watch = path_watch,
    crop_map = crop_map,
    month = month,
    cores = cores,
    save_daily = TRUE            # save raster of daily values of T and VPD
  )
  
  # Read and process WorldClim data
  clim_monthly_worldclim <- get_worldclim_t_vpd(
    path_worldclim = path_worldclim,
    month = month,
    crop_map = crop_map
  )
  
  # Resampling computed with bilinear interpolation 
  clim_monthly_resampled <- terra::resample(
    clim_monthly,            # SpatRaster to be resampled
    clim_monthly_worldclim)  # SpatRaster with the goal geometry
  
  # Crop again to align with WorldClim raster
  clim_monthly_resampled <- terra::crop(clim_monthly_resampled,
                                        clim_monthly_worldclim)
  
  # Calculate climatic bias
  clim_monthly_bias <- clim_monthly_resampled - clim_monthly_worldclim
  
  # Compute VPD and temperature for the remaining years of daily WATCH-WFDEI data
  lapply(2001:2018,
         FUN = function(y) get_daily_t_vpd(
           path_watch = path_watch,
           year = y,
           month = month,
           crop_map = crop_map,
           save_daily = TRUE
         ))
  
  # De-bias daily climatology and save in data/ folder
  lapply(1979:2018,
         FUN = function(y) debias_t_vpd(
             year = y, 
             month = month, 
             bias = clim_monthly_bias, 
             cores = cores
           )
         )
}
