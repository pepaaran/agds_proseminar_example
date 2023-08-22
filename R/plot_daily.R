# Function to plot raster data from file name
plot_daily <- function(
    filename,              # name of raster file
    layer_name,            # either "tavg" or "pvd"
    day                    # day of the month, with the first day being 0
){
  # Read file
  r <- terra::rast(filename)
  
  # Get title from file name
  title <- ifelse(test = grepl("downscaled", filename),
                  no = paste0("Original 0.5deg ", 
                               regmatches(filename, regexpr("[0-9]+", filename)),
                               ifelse(test = day < 9,
                                      yes = paste0("0", day+1),
                                      no = day+1)),
                  yes = paste0("Downscaled 30sec ", 
                              regmatches(filename, regexpr("[0-9]+", filename)),
                              ifelse(test = day < 9,
                                     yes = paste0("0", day+1),
                                     no = day+1)))
  
  # Define plot legend, title and range
  if(grepl("tavg", layer_name)){
    r <- r[[paste0(layer_name, "_tstep=", day)]]

    ggplot() +
      tidyterra::geom_spatraster(data = r ) +
      scale_fill_viridis_c(
        na.value = NA,
        name = "Temperature (C) \n",
        limits = c(-40, 40)
      ) +
      theme_bw() +
      theme(
        legend.position = "bottom"
      ) +
      ggtitle(title)
  } else if(grepl("vpd", layer_name)){
    r <- r[[paste0(layer_name, "_tstep=", day)]]
  
    ggplot() +
      tidyterra::geom_spatraster(data =  r ) +
      scale_fill_viridis_c(
        na.value = NA,
        name = "VPD (Pa) \n",
        limits = c(0, 2000)
      ) +
      theme_bw() +
      theme(
        legend.position = "bottom"
      ) +
      ggtitle(title)
  }
}
