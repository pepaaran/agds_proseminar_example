# Proseminar in Geocomputation and Earth Observation - Example project
This repository serves as a project sample for the Proseminar in Geocomputation and Earth Observation. 

> NOTE: Throughout the proposal, report and slides, there will be notes like this one indicating instructions and tips for your project implementation. You don't need to include such notes in your submission.

----------

# Spatial downscaling of meteorological variables

## Repository structure

All of the code necessary to reproduce the results in this project is available in the repository. Public datasets downloaded from the web are kept separately because of their size.

```
├── README.md                <- The top-level README includes instructions to use this repository
|                               and the project proposal for the Proseminar
│
├── agds_proseminar_example.Rproj    <- R project file
| 
├── renv.lock                <- file to keep package versions for reproducibility
|
├── .gitignore               <- file indicating which files should be ignored when pushing
|
├── data-raw/                <- folder for data downloaded from the web, unprocessed
|   |                           (this folder is never pushed, see .gitignore)
│   ├── wfdei_weedon_2014/
│   ├── worldclim_fick_2017/
│   └── fluxnet_pastorello_2020/
|
├── data                     <- folder for data produced by the repository
│
├── analysis                 <- R markdown scripts used for the development of the report,
|                               includes intermediate data analyses
|
├── vignettes                <- R markdown files
│   ├── report.Rmd           <- main file containing the submitted report
│   ├── slides.Rmd           <- file creating presentation slides
│   └── references.bib       <- bibliography file
│
├── src                      <- bash code for this project, contains scripts for data download
|
├── R                        <- R functions used in the project, contains one function per script
```

## Project proposal

Data science plays a vital role in understanding the complex interactions between climate variables and vegetation dynamics. In this report, we aim to address the necessity of spatially downscaling temperature and Vapor Pressure Deficit (VPD) data in order to effectively answer vegetation modelling questions. By improving the spatial resolution of climatic data, we can gain deeper insights into the relationships between environmental variables and vegetation dynamics at finer scales, enhancing our understanding of ecosystem processes.

#### Motivating the Necessity of Spatially Downscaling VPD and Temperature

Vegetation modelling requires high-resolution climate data to accurately capture the intricate relationships between environmental variables and plant growth. VPD, which represents the difference between the saturated and actual vapor pressure, is a crucial climatic parameter influencing plant transpiration and water stress. Temperature plays a crucial role in vegetation modelling as it directly influences plant growth, phenology, and photosynthesis rates, impacting the distribution, composition, and productivity of vegetation communities.

Vegetation responses to environmental factors exhibit significant spatial heterogeneity, influenced by various factors such as topography, land cover, and local climate variations. Monthly VPD and temperature data available at 0.5 degree spatial resolution, fails to capture the fine-scale variations in moisture stress and transpiration patterns across diverse landscapes. Fine-scale spatial information becomes particularly critical when studying ecosystem processes within regions characterized by complex topography, such as mountainous areas with numerous water bodies like Switzerland, where local climatic conditions can significantly differ from larger-scale averages.

Moreover, downscaled climatic data with higher spatial resolution enables more precise identification of ecological transition zones, microclimates, and areas of high ecological sensitivity. This finer spatial representation supports a better understanding of the mechanisms driving vegetation patterns, species distributions, and ecosystem functioning, thereby enhancing our ability to make informed decisions in ecological management and conservation efforts.

#### Leveraging Monthly Climatic Data at a Finer Spatial Grid Dataset

To tackle the challenge of spatial downscaling, we can leverage the strengths of two datasets: the WATCH-WFDEI dataset and Worldclim. The Worldclim dataset provides monthly climatology of temperature and vapor pressure (averaged over a 30-year period), offering valuable insights into long-term climatic patterns at a ~1km grid. On the other hand, WATCH-WFDEI offers daily temperature and specific humidity data at a coarser spatial grid, enabling us to capture day-to-day variations in climatic conditions. VPD can be directly calculated from vapor pressure, or from surface pressure and specific humidity using different formulas. By combining these datasets, we can achieve higher spatial resolution for daily climatic data.

#### Proposal for Combining Datasets and Data Assimilation Techniques

To achieve the desired spatio-temporal resolution, we propose integrating the daily WATCH-WFDEI data with the higher spatial resolution of Worldclim. The workflow for the downscaling of temperature consists of:

1. Derive the WATCH_WFDEI monthly climatology at 0.5 degree resolution, to be compared with the WorldClim climatology.

2. Calculate the bias by substracting the WorldClim temperature (at higher resolution) from the WATCH-WFDEI-derived temperature. 

3. Substract the average-climatology bias of each 1km grid from the 0.5 deg monthly temperature data.

4. Compare the downscaled temperature against site-level measurements.

To downscale VPD, start by computing WorldClim-derived VPD from vapor pressure values and WATCH-WFDEI-derived VPD from specific humidity and total surface pressure. Then, follow the same workflow as for temperature.

In implementing this proposal, several R packages can be useful. For data assimilation, the package `ncdf4` can aid in optimization and reading NetCDF files, respectively. Additionally, packages such as `terra`, `raster` and `sp` provide functionalities for spatial data handling and manipulation, while `ggplot2` and `leaflet` enable high-quality visualizations.

#### Evaluating the Quality of Downscaling

To evaluate the quality of the downscaling process, visualization techniques can provide valuable insights. Comparing downscaled VPD values against observed or higher-resolution data using visualizations, such as time series plots, scatterplots, or spatial maps, can help identify any discrepancies in the downscaled data. 

Furthermore, we should compare the processed data to field measurements. The FLUXNET2015 dataset provides daily average observations of both temperature and VPD, from several eddy covariance towers across the world. A variety of metrics can showcase the similarity or disparity between downscaled and measured data, including RMSE, bias, slope... These general metrics will also allow to compare the downscaling quality across geographical locations, in a quantitative way.

In conclusion, these visual and quantitative assessments can aid in further refining the downscaling methodology and ultimately improving the accuracy of vegetation modelling outputs.

#### Potential Challenges

During the completion of this project, several challenges may arise. These challenges include:

a) Data quality: Ensuring the accuracy and consistency of the input datasets is crucial for reliable downscaled VPD and temperature values. Addressing potential biases, errors, or missing data in both WATCH-WFDEI, Worldclim and FLUXNET2015 datasets will be necessary.

b) Computational requirements: Generating downscaled monthly values at a high spatio-temporal resolution can be computationally intensive. Planning the project execution with the runtimes in mind and developing the code with subsets of the data will help to complete it in time.

c) Validation: Determining appropriate methods for the data assimilation techniques and validating the downscaled values against ground-based observations or higher-resolution datasets will be essential to assess the quality and accuracy of the results.

#### Conclusion

In summary, this report introduces a geographical data science project that aims to downscale VPD and temperature to high-resolution daily values to address vegetation modelling questions. By leveraging several climate datasets with complementing spatial and time resolution and employing simple de-biasing techniques, we can achieve higher spatio-temporal resolution. However, several challenges must be addressed, including data quality, computational requirements, and validation. Various evaluation techniques will assist in assessing the quality of the downscaled data.
