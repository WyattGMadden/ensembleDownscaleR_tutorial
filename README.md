# ensembleDownscaleR tutorial

This repo contains the *ensembleDownscaleR* code tutorial and code for replicating all plots and tables presented in the publication. 

All code is contained in the repository root directory. The `data` directory is empty and needs to be populated with the data downloaded from Zenodo.


## Download Data

To download all data from Zenodo, either run the R script `download_zenodo_data.R` from the repository root directory:

```r
source("scripts/download_zenodo_data.R")
```

download the data in the terminal with the following commands:

```bash
curl -L -o data/monitor_pm25_with_cmaq.rds "https://zenodo.org/record/14996970/files/monitor_pm25_with_cmaq.rds?download=1"
curl -L -o data/monitor_pm25_with_aod.rds "https://zenodo.org/record/14996970/files/monitor_pm25_with_aod.rds?download=1"
curl -L -o data/cmaq_for_predictions.rds "https://zenodo.org/record/14996970/files/cmaq_for_predictions.rds?download=1"
curl -L -o data/aod_for_predictions.rds "https://zenodo.org/record/14996970/files/aod_for_predictions.rds?download=1"
```


or download the four datasets manually from the following link and place in `data` directory: [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.14996970.svg)](https://doi.org/10.5281/zenodo.14996970).


## Tutorial

The tutorial code is contained in the `tutorial.R` file. Please see publication for explanation of the code and available functionality. 


## Reproduce Plots and Tables

To reproduce all plots and tables in the publication, run the following R scripts in this order:

1. `tutorial.R`
2. `additional_cv_fits.R`
3. `plots.R`
3. `tables.R`


`plots.R` depends on output from `tutorial.R`. `tables.R` depends on output from both `tutorial.R` and `additional_cv_fits.R`.

