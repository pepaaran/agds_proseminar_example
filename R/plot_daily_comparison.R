# Function to plot raster data, comparing original to downscaled values
plot_daily_comparison <- function(
    year,                  # numeric indicating year
    month,                 # numeric indicating month, from 1 to 12
    day                    # day of the month
){
  # Change format of month
  if(month < 10){
    month <- paste0("0", month)
  } else {
    month <- as.character(month)
  }
  
  # Read files and subset relevant day
  r <- terra::rast(paste0("data/tavg_vpd_daily_", year, month, ".tif")) |>
    terra::subset(subset = paste0(c("tavg_tstep=", "vpd_tstep="), day-1))
  
  r_downscaled <- terra::rast(paste0("data/tavg_vpd_daily_downscaled_",
                                     year, month, ".tif")) |>
    terra::subset(subset = paste0(c("tavg_tstep=", "vpd_tstep="), day-1))
  
  # Get plot limits
  xlim <- c(min(terra::ext(r)[1], terra::ext(r_downscaled)[1]),
            max(terra::ext(r)[2], terra::ext(r_downscaled)[2]))
  ylim <- c(min(terra::ext(r)[3], terra::ext(r_downscaled)[3]),
            max(terra::ext(r)[4], terra::ext(r_downscaled)[4]))
  temp_lim <- c(min(minmax(r[[1]])[1,1], minmax(r_downscaled[[1]])[1,1]),
                max(minmax(r[[1]])[2,1], minmax(r_downscaled[[1]])[2,1]))
  vpd_lim <- c(min(minmax(r[[2]])[1,1], minmax(r_downscaled[[2]])[1,1]),
               max(minmax(r[[2]])[2,1], minmax(r_downscaled[[2]])[2,1]))
  
  # Create plot objects
  p1 <- ggplot() +
    tidyterra::geom_spatraster(data = r[[1]]) +           # temp, original
    scale_fill_viridis_c(
      na.value = NA,
      limits = temp_lim
    ) +
    ggplot2::xlim(xlim) +
    ggplot2::ylim(ylim) +
    labs(
      subtitle = expression(paste("Original data (0.5"^o, ")"))
    ) + 
    theme_bw() +
    theme(legend.position = "none")
  
  p2 <- ggplot() +
    tidyterra::geom_spatraster(data = r_downscaled[[1]]) +  # temp, downscaled
    scale_fill_viridis_c(
      na.value = NA,
      name = expression(paste("Temperature ("^o, "C)")),
      limits = temp_lim
    ) +
    ggplot2::xlim(xlim) +
    ggplot2::ylim(ylim) +
    labs(
      subtitle = "Downscaled data (30\")"
    ) + 
    theme_bw()
  
  p3 <- ggplot() +
    tidyterra::geom_spatraster(data = r[[2]]) +           # vpd, original
    scale_fill_viridis_c(
      na.value = NA,
      limits = vpd_lim
    ) +
    ggplot2::xlim(xlim) +
    ggplot2::ylim(ylim) +
    theme_bw() + 
    theme(legend.position = "none")
  
  p4 <- ggplot() +
    tidyterra::geom_spatraster(data = r_downscaled[[2]]) +  # vpd, downscaled
    scale_fill_viridis_c(
      na.value = NA,
      name = "VPD (Pa) \n",
      limits = vpd_lim
    ) +
    ggplot2::xlim(xlim) +
    ggplot2::ylim(ylim) + 
    theme_bw()
  
  # Return plots in a mosaic
  p <- (p1 + p2) / (p3 + p4)
  p + plot_annotation(
    title = paste0("Comparing daily values for ", day, ".", month, ".", year)
  )
}
