# This function extracts a time series of data from the downscaled maps for
# a set of locations
# The .tif files with downscaled data should already exist in the /data folder
get_downscaled_time_series <- function(
    years,            # years for which to get the time series
    fluxnet_sites     # a data frame containing columns: site_code, lon, lat
){
  # Initiate data.frame
  daily_downscaled <- data.frame()
  
  # For all months and years, read downscaled data from files
  for(year in years){
    for(month in c(paste0("0", 1:9), "10", "11", "12")){
      
      # Read data
      daily <- terra::rast(paste0("data/tavg_vpd_daily_downscaled_", year, month, ".tif")) |>
        terra::extract(y = fluxnet_sites[, c("lon", "lat")]) |>
        dplyr::mutate(ID = fluxnet_sites$site_code) 
      
      # Get temperature data and transform date format
      daily_tavg <- daily |>
        dplyr::select(ID, starts_with("tavg")) |>
        tidyr::gather(tstep, tavg, starts_with("tavg")) |>
        dplyr::mutate(tstep = as.Date(as.numeric(gsub("\\D", "", tstep)),
                                      origin = paste(year, month, "01", sep = "-")))
      
      # Get VPD data and transform date format
      daily |> 
        dplyr::select(ID, starts_with("vpd")) |>
        tidyr::gather(tstep, vpd, starts_with("vpd")) |>
        dplyr::mutate(tstep = as.Date(as.numeric(gsub("\\D", "", tstep)),
                                      origin = paste(year, month, "01", sep = "-"))) |>
        dplyr::left_join(daily_tavg, by = c("ID", "tstep")) |>
        
        # Add vertical dataset to data from previous years
        rbind(daily_downscaled) ->
        daily_downscaled
    }
  }
  
  # Return data.frame
  daily_downscaled
}