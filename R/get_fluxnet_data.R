# Obtain clean FLUXNET2015 data
get_fluxnet_data <- function(
    path_fluxnet,     # path for FLUXNET2015 data
    site_code        # code for the site from which we want to extract data
){
  # Get file name for daily data
  file_name <- list.files(path_fluxnet,
                          pattern = paste0("FLX_", site_code, "_FLUXNET2015_FULLSET_DD*"),
                          full.names = TRUE)
 
  # Read variables of interest
  dd <- read.csv(file_name) |>
    dplyr::select(TIMESTAMP,
                  TA_F,
                  TA_F_QC,
                  VPD_F,
                  VPD_F_QC) |>
    dplyr::mutate(TIMESTAMP = as.Date(strptime(TIMESTAMP, format = "%Y%m%d")))
  
  # Retain only observed data
  dd |>
    dplyr::filter(TA_F_QC == 1, VPD_F_QC == 1) |>
    dplyr::select(TIMESTAMP, TA_F, VPD_F) |>
    dplyr::mutate(VPD_F = VPD_F * 100)           # from hPa to Pa
}

