# This function calculates metrics to compare downscaled and measured values
# for a set of given sites
compare_downscaled <- function(
    df_downscaled,          # data frame returned by get_downscaled_time_series()
    path_fluxnet            # path to FLUXNET2015 data
){
  # Compile sites for which to get measurements
  site_codes <- unique(df_downscaled$ID)
  
  sapply(site_codes, function(site_code){
    # Get FLUXNET data
    df_fluxnet <- get_fluxnet_data(                   # function must be loaded
      path_fluxnet = path_fluxnet,
      site_code = site_code)
    
    # Get downscaled data from Davos
    df_joint <- df_downscaled |>
      dplyr::filter(ID == site_code) |>
      
      # Remove years before FLUXNET observations
      dplyr::filter(tstep >= min(df_fluxnet$TIMESTAMP)) |>
      
      # Remove years after FLUXNET observations
      dplyr::filter(tstep <= max(df_fluxnet$TIMESTAMP)) |>
      
      # Join FLUXNET data, by date
      dplyr::left_join(
        df_fluxnet,
        by = join_by(tstep == TIMESTAMP)) |>
    
      # Compute difference between observed and downscaled
      # to save later repeated computations
      dplyr::mutate(vpd_dif = vpd - VPD_F,
                    tavg_dif = tavg - TA_F)
    
    # Compute standard deviations
    sd_vpd <- sd(df_joint$vpd, na.rm = TRUE)
    sd_tavg <- sd(df_joint$tavg, na.rm = TRUE)
    
    # Compute RMSE
    rmse_vpd <- sqrt(mean( df_joint$vpd_dif^2, na.rm = TRUE))
    rmse_tavg <- sqrt(mean( (df_joint$tavg_dif)^2, na.rm = TRUE))
    
    # Compute metrics for VPD and temperature
    c(rmse_vpd = rmse_vpd,
      
      bias_vpd = mean( df_joint$vpd_dif, na.rm = TRUE),
      
      slope_vpd = coef(lm(df_joint$vpd ~ df_joint$VPD_F))[2] |>
        stats::setNames(""),
        
      norm_rmse_vpd = rmse_vpd / sd_vpd,
      
      rmse_tavg = rmse_tavg,
      
      bias_tavg = mean( df_joint$tavg_dif, na.rm = TRUE),
      
      slope_tavg = coef(lm(df_joint$tavg ~ df_joint$TA_F))[2] |>
        stats::setNames(""),
      
      norm_rmse_tavg = rmse_tavg / sd_tavg
    ) |>
      round(3)      
  }) |>
    t()               # Return the table, transposed
}
