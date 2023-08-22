# This function plots a comparison between measured data and downscaled values
# for a given site
plot_comparison_site <- function(
    df_downscaled,          # data frame returned by get_downscaled_time_series() 
    path_fluxnet,           # path to FLUXNET2015 data
    site_code               # site code from FLUXNET2015
){
  # Get FLUXNET data
  df_fluxnet <- get_fluxnet_data(                   # function must be loaded
    path_fluxnet = path_fluxnet,
    site_code = site_code)
  
  # Get downscaled data
  df_joint <- df_downscaled |>
    dplyr::filter(ID == site_code) |>
    
    # Remove years before FLUXNET observations
    dplyr::filter(tstep >= min(df_fluxnet$TIMESTAMP)) |>
    
    # Remove years after FLUXNET observations
    dplyr::filter(tstep <= max(df_fluxnet$TIMESTAMP)) |>
    
    # Join FLUXNET data, by date
    dplyr::left_join(
      df_fluxnet,
      by = join_by(tstep == TIMESTAMP))
    
  
  # # Get FLUXNET data
  # df_joint <- get_fluxnet_data(                   # function must be loaded
  #   path_fluxnet = path_fluxnet,
  #   site_code = site_code) |>
  #   
  #   # Join downscaled data from Davos
  #   dplyr::left_join(
  #     df_downscaled |> 
  #       dplyr::filter(ID == site_code),
  #     by = join_by(TIMESTAMP == tstep)
  #   ) |>
  #   dplyr::rename(tstep = TIMESTAMP)
  
  # Prepare VPD data for plotting
  p1 <- df_joint |>                       # save plot
    dplyr::select(tstep, vpd, VPD_F) |>
    dplyr::rename(downscaled = vpd,
                  measured = VPD_F) |>
    tidyr::gather(origin, value, -tstep) |>
    
    # Plot data
    ggplot() +
    geom_line(aes(x = tstep, y = value, col = origin),
              alpha = 0.5) +
    xlab("Date") +
    ylab("VPD (Pa)") +
    theme_classic() +
    theme(legend.position = "bottom", legend.title = element_blank()) +
    labs(title = paste("Downscaling evaluation for ", site_code) )
  
  p2 <- ggplot(df_joint) +
    geom_point(aes(x = VPD_F, y = vpd), alpha = 0.3) +
    xlab("Measured VPD (Pa)") +
    ylab("Downscaled VPD (Pa)") +
    geom_smooth(aes(x = VPD_F, y = vpd),
                method = "lm") +
    geom_abline(slope = 1, intercept = 0, lty = 2, col = 2) +
    theme_classic() +
    theme(plot.subtitle = element_text(size = 9)) +
    labs(subtitle = paste("RMSE =", 
                          sqrt(mean( (df_joint$vpd - df_joint$VPD_F)^2,
                                     na.rm = TRUE)) |>
                            round(2),
                          "   Bias =",
                          mean( df_joint$vpd - df_joint$VPD_F,
                                na.rm = TRUE) |>
                            round(2),
                          "   Slope = ",
                          coef(lm(df_joint$vpd ~ df_joint$VPD_F))[2] |>
                            round(2)
    ))
  
  # cowplot::plot_grid(p1, p2, ncol = 1)
  
  # Prepare temperature data for plotting
  p3 <- df_joint |>                       # save plot
    dplyr::select(tstep, tavg, TA_F) |>
    dplyr::rename(downscaled = tavg,
                  measured = TA_F) |>
    tidyr::gather(origin, value, -tstep) |>
    
    # Plot data
    ggplot() +
    geom_line(aes(x = tstep, y = value, col = origin),
              alpha = 0.5) +
    xlab("Date") +
    ylab("Temperature (C)") +
    theme_classic() +
    theme(legend.position = "bottom", legend.title = element_blank()) +
    labs(title = "")
  
  p4 <- ggplot(df_joint) +
    geom_point(aes(x = TA_F, y = tavg), alpha = 0.3) +
    xlab("Measured temperature (C)") +
    ylab("Downscaled temperature (C)") +
    geom_smooth(aes(x = TA_F, y = tavg),
                method = "lm") +
    geom_abline(slope = 1, intercept = 0, lty = 2, col = 2) +
    theme_classic() +
    theme(plot.subtitle = element_text(size = 9)) +
    labs(subtitle = paste("RMSE =", 
                          sqrt(mean( (df_joint$tavg - df_joint$TA_F)^2,
                                     na.rm = TRUE)) |>
                            round(2),
                          "   Bias =",
                          mean( df_joint$tavg - df_joint$TA_F,
                                na.rm = TRUE) |>
                            round(2),
                          "   Slope = ",
                          coef(lm(df_joint$tavg ~ df_joint$TA_F))[2] |>
                            round(2)
    ))
  
  cowplot::plot_grid(p1, p3, p2, p4, ncol = 2) |> print()
}
