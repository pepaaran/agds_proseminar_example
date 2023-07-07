# Extracts point data for a set of sites given by df_lonlat using
# functions from the raster package.

extract_pointdata_allsites <- function(
  filename,
  df_lonlat,
  get_time = FALSE
  ) {
  
  # define variables
  lon <- lat <- data <- NULL
  
  # load file using the raster library
  #print(paste("Creating raster brick from file", filename))
  if (!file.exists(filename)) stop(paste0("File not found: ", filename))
  # message(paste0("Reading file: ", filename))
  rasta <- raster::brick(filename)
  
  df_lonlat <- raster::extract(
    rasta,
    sp::SpatialPoints(dplyr::select(df_lonlat, lon, lat)), # , proj4string = rasta@crs
    sp = TRUE
  ) %>%
    as_tibble() %>%
    tidyr::nest(data = c(-lon, -lat)) %>%
    right_join(df_lonlat, by = c("lon", "lat")) %>%
    mutate( data = purrr::map(data, ~dplyr::slice(., 1)) ) %>%
    dplyr::mutate(data = purrr::map(data, ~t(.))) %>%
    dplyr::mutate(data = purrr::map(data, ~as_tibble(.)))
  
  # xxx todo: use argument df = TRUE in the extract() function call in order to
  # return a data frame directly (and not having to rearrange the data afterwards)
  # xxx todo: implement the GWR method for interpolating using elevation as a
  # covariate here.
  
  if (get_time){
    timevals <- raster::getZ(rasta)
    df_lonlat <- df_lonlat %>%
      mutate( data = purrr::map(data, ~bind_cols(., tibble(date = timevals))))
  }
  
  return(df_lonlat)
}
