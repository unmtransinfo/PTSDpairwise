# Installation Steps

1. Download the JDBC Driver
You can download the official PostgreSQL JDBC driver (postgresql-<version>.jar) from:
PostgreSQL JDBC websiteThis folder is for files needed by the package developer.
Place the driver into folder that's accessible. 

2. Use `createTCosListFile.R` to create pairwise comparisons. This script is not part of analysis script but initially needed to create pairwise comparisons. 

The script creates file `TcosOfInterest.csv` which has to be copied in `inst/settings/` folder and replace the original file.  

Make sure that `inst/cohorts` consists of all cohort json-s that will be constructed and fetched. 

Before running the script you have to download `excludedCovariateConceptIds` from Atlas, each cohort needs its own concepts, placing them to `excluded_covariate_concept_ids` folder as csv files. Each concept set has to have id included in file name. 

The script uses those excluded concept ids to create pairwise analysis. 

3. Create Conda environment with R version=4.1.2. 
- Activate Conda environment
- Install all R dependencies using `renv::restore()`
- Install package using
`setwd("~/PTSDpairwise")`
`renv::activate()`
`renv::install(".")`

# Running Steps

4. Set database, cohort schema, cohort table and other parameters in `extras/CodeToRun.R`
5. Run `extras/CodeToRun.R`

# View Results wih Shiny App - Evidence Explorer

6. Create copy of the project. And if neccessary install separate conda environment. 
Copy `output`  directory with the results to copied project root. 

Run the `CodeToRun.R` parts where the Shiny app is launched. 