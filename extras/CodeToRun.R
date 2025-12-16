#Set this to where the study package is installed
setwd("~/PTSDpairwise")
library(PTSDpairwise)

# Optional: specify where the temporary files (used by the Andromeda package) will be created:
options(andromedaTempFolder = "andromedaTemp")

# Maximum number of cores to be used:
maxCores <- parallel::detectCores() - 1

# The folder where the study intermediate and result files will be written:
outputFolder <- "output"

#This prompts for password
mypassword <- getPass::getPass("Enter your password:")

#Set this to your username
myusername <- "lambert"

# Details for connecting to the server:
connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = "postgresql",
		     						server = "localhost/truven",
                                                                connectionString = "jdbc:postgresql://localhost:5432/truven", 
                                                                user = myusername,
                                                                password = mypassword,
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