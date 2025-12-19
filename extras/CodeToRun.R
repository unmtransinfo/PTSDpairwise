#Set this to where the study package is installed
setwd("~/PTSDpairwise")
library(PTSDpairwise)

# Optional: specify where the temporary files (used by the Andromeda package) will be created:
options(andromedaTempFolder = "andromedaTemp")

# Maximum number of cores to be used:
maxCores <- round(parallel::detectCores()/2)    

# The folder where the study intermediate and result files will be written:
outputFolder <- "output"


Sys.setenv(DB_USER= "lambert" )
#This prompts for password
Sys.setenv(DB_PASSWORD = getPass::getPass("Enter your password:"))

# Details for connecting to the server:
connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = "postgresql",
		     						server = "localhost/truven",
                                                                connectionString = "jdbc:postgresql://localhost:5432/truven", 
                                                                user = Sys.getenv("DB_USER"),
                                                                password =  Sys.getenv("DB_PASSWORD"),
                                                                pathToDriver = "~/jdbcDrivers")

# The name of the database schema where the CDM data can be found:
cdmDatabaseSchema <- "mdcr2003_2023"

# The name of the database schema and table where the study-specific cohorts will be instantiated:
cohortDatabaseSchema <- "ptsd_mdcr_temp" # temporary schema for cohort creation
cohortTable <- "ptsd_mdcr_cohort" # cohort table where the cohorts are chreated
tempEmulationSchema <- cohortDatabaseSchema
# Some meta-information that will be used by the export function:
databaseId <- "mdcr"
databaseName <- "MarketScan Medicare Supplemental and Coordination of Benefits Database"
databaseDescription <- "MarketScan Medicare Supplemental and Coordination of Benefits Database (MDCR) represents health services of retirees in the United States with primary or Medicare supplemental coverage through privately insured fee-for-service, point-of-service, or capitated health plans.  These data include adjudicated health insurance claims (e.g. inpatient, outpatient, and outpatient pharmacy). Additionally, it captures laboratory tests for a subset of the covered lives."

# For some database platforms (e.g. Oracle): define a schema that can be used to emulate temp tables:
options(sqlRenderTempEmulationSchema = NULL)

# verifyDependencies: When TRUE (default), checks that all required R packages are installed
# with compatible versions before running. Set to FALSE to skip this check when you know
# dependencies are already satisfied (e.g., when resuming a previously interrupted run in
# the same R session). Skipping saves time but risks cryptic errors if packages are missing.

# createCohorts: When TRUE (default), creates/recreates the cohort table in the database.
# Set to FALSE when resuming a failed run where cohorts were already successfully created.
# The cohort table is preserved in the database between runs, so skipping this step avoids
# redundant computation and preserves the exact same cohort definitions.

# minCohortSize: Minimum number of subjects required in BOTH target and comparator cohorts
# for a pairwise comparison to be included. Pairs where either cohort has fewer subjects
# are excluded before analysis begins. This prevents failures from:
# - Zero subjects in one cohort
# - Insufficient data for propensity score model convergence
# - High correlation between covariates and treatment assignment

# excludeCohortIds: Cohorts to completely exclude from all comparisons. Used to skip
# cohorts with known issues (e.g., high covariate-treatment correlation).
# Cohort 24 = NMDAR_Antagonist (Ketamine) - high correlation issues
# Cohort 33 = Z_Drugs (Zolpidem, etc.) - insomnia diagnosis may cause perfect separation

execute(connectionDetails = connectionDetails,
        cdmDatabaseSchema = cdmDatabaseSchema,
        cohortDatabaseSchema = cohortDatabaseSchema,
        cohortTable = cohortTable,
        outputFolder = outputFolder,
        databaseId = databaseId,
        databaseName = databaseName,
        databaseDescription = databaseDescription,
        verifyDependencies = FALSE, # Skip dependency check when resuming (already verified)
        createCohorts = FALSE, # Skip cohort creation - cohorts already exist from previous run
        synthesizePositiveControls = FALSE, # Default: TRUE - skip if already synthesized
        runAnalyses = TRUE, # Resume CohortMethod analysis from where it left off
        packageResults = TRUE,
        maxCores = maxCores,
        minCohortSize = 100, # Filter out pairs with < 100 subjects in either cohort
        excludeCohortIds = c(24, 33)) # Skip NMDAR_Antagonist and Z_Drugs (high correlation issues)

resultsZipFile <- file.path(outputFolder, "export", paste0("Results_", databaseId, ".zip"))
dataFolder <- file.path(outputFolder, "shinyData")

# You can inspect the results if you want:
prepareForEvidenceExplorer(resultsZipFile = resultsZipFile, dataFolder = dataFolder)
launchEvidenceExplorer(dataFolder = dataFolder, blind = TRUE, launch.browser = FALSE)

# Upload the results to the OHDSI SFTP server:
privateKeyFileName <- ""
userName <- ""
# uploadResults(outputFolder, privateKeyFileName, userName)