PTSDpairwise
==============================

A package for conducting pairwise comparative effectiveness studies using observational healthcare data in the OMOP Common Data Model format.

Requirements
============

- A database in [Common Data Model version 5](https://ohdsi.github.io/CommonDataModel/) in one of these platforms: SQL Server, Oracle, PostgreSQL, IBM Netezza, Apache Impala, Amazon RedShift, Google BigQuery, Spark, or Microsoft APS.
- [Conda](https://docs.conda.io/en/latest/) (Miniconda or Anaconda)
- JDBC driver for your database platform

Installation
============

### 1. Clone the Repository

```bash
git clone https://github.com/unmtransinfo/PTSDpairwise.git
cd PTSDpairwise
```

### 2. Download the JDBC Driver

You can download the official PostgreSQL JDBC driver (`postgresql-<version>.jar`) from the [PostgreSQL JDBC website](https://jdbc.postgresql.org/download/).

Place the driver into a folder that's accessible (e.g., `~/jdbcDrivers`).

### 3. Set Up Conda Environment

Create and activate a Conda environment with R version 4.1.2, OpenJDK, and libsodium. This must be done before setting up the R packages:

```bash
conda create -n ptsdpairwise -c conda-forge r-base=4.1.2 openjdk=11 libsodium
conda activate ptsdpairwise
```

### 4. Configure Java for R

After activating the conda environment, set up the Java library path and configure R:

```bash
# Set LD_LIBRARY_PATH for this conda environment
conda env config vars set LD_LIBRARY_PATH=$CONDA_PREFIX/lib/server

# Reactivate the environment to apply the new setting
conda deactivate
conda activate ptsdpairwise

# Configure R's Java settings
R CMD javareconf
```

### 5. Install R Dependencies

Follow [these instructions](https://ohdsi.github.io/Hades/rSetup.html) for additional R environment setup if needed.

Once the Conda environment is active and Java is configured, install the package dependencies in R:

```r
renv::restore()
```

If renv mentions that the project already has a lockfile, select "*1: Restore the project from the lockfile.*"

### 6. Install the Study Package

After restoring the dependencies, install the PTSDpairwise package itself from the project directory:

```r
renv::install(".")
```

### 7. Create Required Directories

The `andromedaTemp` directory must exist before running the analysis, or the run will fail:

```bash
mkdir -p ~/PTSDpairwise/andromedaTemp
mkdir -p ~/PTSDpairwise/output
```

### 8. Create Pairwise Comparisons (For Developers)

This step is only needed if you want to regenerate the pairwise comparison configuration. The script `extras/createTcosListFile.R` creates all pairwise treatment comparisons for the study.

#### Excluded Covariate Concept IDs

The `inst/excluded_covariate_concept_ids/` folder contains CSV files with concept IDs that must be excluded from propensity score matching for each cohort. These files were exported from ATLAS and map 1-to-1 with the cohort definition JSON files in `inst/cohorts/`. For example, `inst/excluded_covariate_concept_ids/4.csv` corresponds to `inst/cohorts/4.json`.

If you modify cohort definitions, you must also update the corresponding excluded covariate files by exporting the new excluded concept sets from ATLAS. Each CSV file must contain an `Id` column with the concept IDs to exclude.

#### Running the Script

```bash
cd ~/PTSDpairwise
conda activate ptsdpairwise
```

Then in R:

```r
source("extras/createTcosListFile.R")
```

#### What the Script Does

The script performs the following steps:

1. **Defines cohort IDs**: Uses a predefined list of drug class cohort IDs (e.g., Barbiturates=4, Alpha_agonist=8, Benzodiazepines=13, SSRI=31, etc.)

2. **Creates pairwise combinations**: Generates all unique pairs of target/comparator cohorts (e.g., 4 vs 8, 4 vs 9, ..., 32 vs 33)

3. **Loads excluded covariates**: For each cohort pair, reads the excluded covariate concept IDs from the CSV files in `inst/excluded_covariate_concept_ids/` and merges them

4. **Sets outcome IDs**: Assigns outcome IDs (default: `4;5;35` for Psychiatric Hospitalization, Non-Psychiatric Hospitalization, and Self Harm)

5. **Writes output**: Creates `inst/settings/TcosOfInterest.csv` with columns:
   - `targetId`: The target cohort ID
   - `comparatorId`: The comparator cohort ID
   - `outcomeIds`: Semicolon-separated outcome IDs
   - `excludedCovariateConceptIds`: Merged excluded concept IDs for both cohorts
   - `includedCovariateConceptIds`: (empty by default)

The file `inst/settings/TcosOfInterest.csv` already contains a pre-generated configuration if you don't need to regenerate it.

How to Run
==========

### 1. Create the Cohort Schema

Before running the study, you must create a database schema where the study cohorts will be stored. This schema requires write access. For example, in PostgreSQL:

```sql
CREATE SCHEMA ptsd_cohort_schema AUTHORIZATION your_username;
```

### 2. Configure and Execute the Study

Edit `extras/CodeToRun.R` to configure the following parameters for your environment:

- **`myusername`**: Your database username
- **`connectionDetails`**: Database connection settings (dbms, server, connectionString, pathToDriver)
- **`cdmDatabaseSchema`**: Schema containing the CDM data
- **`cohortDatabaseSchema`**: Schema for creating study cohorts (requires write access)
- **`cohortTable`**: Name of the cohort table to create
- **`databaseId`**: Short identifier for your database (used in output filenames)
- **`databaseName`**: Full name of your database
- **`databaseDescription`**: Description of your database

Then run the script from R:

```r
source("extras/CodeToRun.R")
```

The script will prompt for your database password and execute the study.

### 3. View Results with Shiny App - Evidence Explorer

After the analysis completes, the script will launch the Evidence Explorer Shiny app to view results.

**Notes:**
- You can save plots from within the Shiny app
- It is possible to view results from more than one database by applying `prepareForEvidenceExplorer` to the Results file from each database, using the same data folder
- Set `blind = FALSE` if you wish to be unblinded to the final results

### 4. Upload Results (Optional)

To upload the results to the OHDSI SFTP server, edit the `privateKeyFileName` and `userName` variables in `extras/CodeToRun.R` and uncomment the `uploadResults` call.

License
=======
The PTSDpairwise package is licensed under Apache License 2.0

Development
===========
PTSDpairwise was developed in ATLAS and R Studio.

### Development status

Unknown
