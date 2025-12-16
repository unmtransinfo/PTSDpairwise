setwd("~/PTSDpairwise")
library(PTSDpairwise)

# Optional: specify where the temporary files (used by the Andromeda package) will be created:
options(andromedaTempFolder = "~/PTSDpairwise/andromedaTemp")

# Maximum number of cores to be used:
maxCores <- parallel::detectCores() - 1

# The folder where the study intermediate and result files will be written:
outputFolder <- "~/PTSDpairwise/output"

# Details for connecting to the server:
connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = "postgresql",
                                                                connectionString = "jdbc:postgresql://localhost:5432/truven", 
                                                                user = Sys.getenv("DB_USERNAME"),
                                                                password = Sys.getenv("DB_PASSWORD"),  
                                                                pathToDriver = "~/jdbcDrivers")

# The name of the database schema where the CDM data can be found:
cdmDatabaseSchema <- "ccae2003_2023"

# The name of the database schema and table where the study-specific cohorts will be instantiated:
cohortDatabaseSchema <- "SCHEMA" # temporary schema for cohort creation
cohortTable <- "SCHEMA" # cohort table where the cohorts are chreated
tempEmulationSchema <- "SCHEMA"
# Some meta-information that will be used by the export function:
databaseId <- "MDCR"
databaseName <- "IBM MarketScan?? Medicare Supplemental and Coordination of Benefits Database"
databaseDescription <- "IBM MarketScan?? Medicare Supplemental and Coordination of Benefits Database (MDCR) represents health services of retirees in the United States with primary or Medicare supplemental coverage through privately insured fee-for-service, point-of-service, or capitated health plans.  These data include adjudicated health insurance claims (e.g. inpatient, outpatient, and outpatient pharmacy). Additionally, it captures laboratory tests for a subset of the covered lives."

# For some database platforms (e.g. Oracle): define a schema that can be used to emulate temp tables:
options(sqlRenderTempEmulationSchema = NULL)

execute(connectionDetails = connectionDetails,
        cdmDatabaseSchema = cdmDatabaseSchema,
        cohortDatabaseSchema = cohortDatabaseSchema,
        cohortTable = cohortTable,
        outputFolder = outputFolder,
        databaseId = databaseId,
        databaseName = databaseName,
        databaseDescription = databaseDescription,
        verifyDependencies = FALSE, # Default: TRUE
        createCohorts = TRUE, # Default: TRUE
        synthesizePositiveControls = FALSE, # Default: TRUE
        runAnalyses = TRUE,
        packageResults = TRUE,
        maxCores = maxCores)

resultsZipFile <- file.path(outputFolder, "export", paste0("Results_", databaseId, ".zip"))
dataFolder <- file.path(outputFolder, "shinyData")

# You can inspect the results if you want:
prepareForEvidenceExplorer(resultsZipFile = resultsZipFile, dataFolder = dataFolder)
launchEvidenceExplorer(dataFolder = dataFolder, blind = TRUE, launch.browser = FALSE)

# Upload the results to the OHDSI SFTP server:
privateKeyFileName <- ""
userName <- ""
# uploadResults(outputFolder, privateKeyFileName, userName)