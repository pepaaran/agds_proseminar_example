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

### Summary

This report introduces a geographical data science project that aims to downscale vapor pressure deficit (VPD) and temperature to high-resolution daily values to address vegetation modelling questions. By leveraging several climate datasets with complementing spatial and time resolution and employing simple de-biasing techniques, we can achieve higher spatio-temporal resolution. However, several challenges must be addressed, including data quality, computational requirements, and validation. Various evaluation techniques will assist in assessing the quality of the downscaled data against temperature and VPD measurements.

### Background and motivation

Vegetation modelling requires high-resolution climate data to accurately capture the intricate relationships between environmental variables and plant growth. Vapor pressure deficit, which represents the difference between the saturated and actual vapor pressure, is a crucial climatic parameter influencing plant transpiration and water stress. Temperature plays a crucial role in vegetation modelling as it directly influences plant growth, phenology, and photosynthesis rates, impacting the distribution, composition, and productivity of vegetation communities.

Vegetation responses to environmental factors exhibit significant spatial heterogeneity, influenced by various factors such as topography, land cover, and local climate variations. Monthly VPD and temperature data available at 0.5 degree spatial resolution, fails to capture the fine-scale variations in moisture stress and transpiration patterns across diverse landscapes. Fine-scale spatial information becomes particularly critical when studying ecosystem processes within regions characterized by complex topography, such as mountainous areas with numerous water bodies like Switzerland, where local climatic conditions can significantly differ from larger-scale averages.

Moreover, downscaled climatic data with higher spatial resolution enables more precise identification of ecological transition zones, microclimates, and areas of high ecological sensitivity. This finer spatial representation supports a better understanding of the mechanisms driving vegetation patterns, species distributions, and ecosystem functioning, thereby enhancing our ability to make informed decisions in ecological management and conservation efforts.

### Objective

The goal of this project is to obtain maps of VPD and temperature values with a high spatio-temporal resolution, that is, daily values in a 1km-grid, from public data sources. To ensure the quality of the data processing, the resulting daily maps should be reasonably close to a time series of site measurements. Ultimately, these maps should enable the study of vegetation responses to the climate, capturing environmental changes across topography and time.

### Implementation

#### Data

To tackle the challenge of spatial downscaling, we can leverage the strengths of two datasets: the WATCH-WFDEI dataset and Worldclim. The Worldclim dataset provides monthly climatology of temperature and vapor pressure (averaged over a 30-year period), offering valuable insights into long-term climatic patterns at a ~1km grid. On the other hand, WATCH-WFDEI offers daily temperature and specific humidity data at a coarser spatial grid, enabling us to capture day-to-day variations in climatic conditions. VPD can be directly calculated from vapor pressure, or from surface pressure and specific humidity using different formulas. By combining these datasets, we can achieve higher spatial resolution for daily climatic data. Finally, the FLUXNET2015 dataset provides daily average observations of both temperature and VPD, from several eddy covariance towers across the world, which can be used to evaluate the downscaled output to ground measurements.

#### Methods

To achieve the desired spatio-temporal resolution, we propose integrating the daily WATCH-WFDEI data with the higher spatial resolution of Worldclim. The workflow for the downscaling of temperature consists of:

1. Derive the WATCH_WFDEI monthly climatology at 0.5 degree resolution, to be compared with the WorldClim climatology.

2. Calculate the bias by substracting the WorldClim temperature (at higher resolution) from the WATCH-WFDEI-derived temperature. 

3. Substract the average-climatology bias of each 1km grid from the 0.5 deg monthly temperature data.

4. Compare the downscaled temperature against site-level measurements.

To downscale VPD, start by computing WorldClim-derived VPD from vapor pressure values and WATCH-WFDEI-derived VPD from specific humidity and total surface pressure. Then, follow the same workflow as for temperature.

In implementing this proposal, several R packages can be useful. For data assimilation, the package `ncdf4` can aid in optimization and reading NetCDF files, respectively. Additionally, packages such as `terra`, `raster` and `sp` provide functionalities for spatial data handling and manipulation, while `ggplot2` and `leaflet` enable high-quality visualizations.

To evaluate the quality of the downscaling process, visualization techniques can provide valuable insights. Comparing downscaled VPD values against observed or higher-resolution data using visualizations, such as time series plots, scatterplots, or spatial maps, can help identify any discrepancies in the downscaled data. 

Furthermore, we should compare the processed data to field measurements from FLUXNET2015. A variety of metrics can showcase the similarity or disparity between downscaled and measured data, including RMSE, bias, slope... These general metrics will also allow to compare the downscaling quality across geographical locations, in a quantitative way.

In conclusion, these visual and quantitative assessments can aid in further refining the downscaling methodology and ultimately improving the accuracy of vegetation modelling outputs.

### Responsibilities and timeline

This project will be fully implemented by Pepa Arán. 

> NOTE: If you are working in a pair, responsibilities should be allocated to each person. For example, one person is responsible for the initial literature research while the other looks for datasets, then one person works on the data processing while the other works on the validation, and finally one creates the plots and the other completes the report. Discuss who will take care of what, or what tasks will be shared, such that you exploit the experience of each person but also make sure that you take away the learnings you seek from this course.

Listed below are a succession of weekly intermediate goals, which serve as a guide for the implementation of the project:

1. Set up the repository for the project and download all the relevant data.

2. Learn to work with the `terra` package and read the raster files from WorldClim and WATCH-WFDEI.

3. Implement functions to calculate VPD from the raster files.

4. Write code to execute the whole downscaling pipeline on a toy dataset/subset.

5. Review results from the processing implementation with visualisations and correct inconsistencies.

6. Refactor the downscaling code to process the whole data, avoiding repeated computations and saving relevant intermediate files.

7. Read FLUXNET2015 data and select relevant sites and variables.

8. Perform analysis comparing downscaling output and observations, using both statistical metrics and plots.

9. Put all pieces together into the report and write interpretations.

10. Polish final submission and create slides.

> NOTE: Thinking of your intermediate goals in detail will help you plan accordingly and foresee complications, but the timeline must not be as granular as our example. It is also good to plan for some buffer time and expect to spend time reviewing your work or re-implementing certain aspects.

### Risks and contingency

During the completion of this project, several challenges may arise. These challenges include:

1. Data quality: Ensuring the accuracy and consistency of the input datasets is crucial for reliable downscaled VPD and temperature values. Addressing potential biases, errors, or missing data in both WATCH-WFDEI, Worldclim and FLUXNET2015 datasets will be necessary.

2. Computational requirements: Generating downscaled monthly values at a high spatio-temporal resolution can be computationally intensive. Planning the project execution with the runtimes in mind and developing the code with subsets of the data will help to complete it in time.

3. Validation: Determining appropriate methods for the data assimilation techniques and validating the downscaled values against ground-based observations or higher-resolution datasets will be essential to assess the quality and accuracy of the results.

### Impact

Data science plays a vital role in understanding the complex interactions between climate variables and vegetation dynamics. In this report, we aim to address the necessity of having high resolution climatic datasets that correctly capture spatio-temporal variations in order to effectively answer vegetation modelling questions. Our spatially downscaled daily temperature and Vapor Pressure Deficit (VPD) data allow to gain deeper insights into the relationships between environmental variables and vegetation dynamics at finer scales, ultimately enhancing the understanding of ecosystem processes.
