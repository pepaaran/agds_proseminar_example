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
    
    # Compute metrics for VPD and temperature
    c(rmse_vpd = sqrt(mean( df_joint$vpd_dif^2, na.rm = TRUE)),
      
      bias_vpd = mean( df_joint$vpd_dif, na.rm = TRUE),
      
      slope_vpd = coef(lm(df_joint$vpd ~ df_joint$VPD_F))[2] |>
        stats::setNames(""),
      mre_vpd = df_joint |>
        dplyr::filter(VPD_F != 0) |>
        dplyr::mutate(rel_error = abs( vpd_dif/VPD_F )) |>
        dplyr::select(rel_error) |>
        apply(2, mean, na.rm=TRUE),
        
        # mean( abs( (df_joint$vpd_dif)/df_joint$VPD_F),
        #               na.rm = TRUE),
      
      rmse_tavg = sqrt(mean( (df_joint$tavg_dif)^2,
                             na.rm = TRUE)),
      bias_tavg = mean( df_joint$tavg_dif,
                        na.rm = TRUE),
      slope_tavg = coef(lm(df_joint$tavg ~ df_joint$TA_F))[2] |>
        stats::setNames(""),
      mre_tavg = mean( abs( (df_joint$tavg_dif)/df_joint$TA_F),
                      na.rm = TRUE)
    ) |>
      round(3)      
  }) |>
    t()               # Return the table, transposed
}
