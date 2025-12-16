# -------------------------------------------------------------------------
# User input
# -------------------------------------------------------------------------

# Folder containing excluded covariate lists (in inst/ directory)
excluded_folder <- "inst/excluded_covariate_concept_ids"

# Constant values for outcomes
outcome_ids <- "4;5;35"
included_covariate_concept_ids <- ""

# Load cohorts
cohort_ids <- c(4, # [Drug Class] Barbiturates
                # 5, # [Outcome] Psychiatric Hospitalization
                # 6, # [Outcome] Non-Psychiatric Hospitalization
                8, # [Drug Class] Alpha_agonist
                9, # [Drug Class] Alpha_blocker
                10, # [Drug Class] AntiConvulsant
                11, # [Drug Class] Azaspirone
                12, # [Drug Class] SARI
                13, # [Drug Class] Benzodiazepines
                14, # [Drug Class] Benzoxazine
                15, # [Drug Class] BetaBlocker
                16, # [Drug Class] Cannabinoids
                17, # [Drug Class] FGA
                18, # [Drug Class] Lithium
                19, # [Drug Class] MAOI
                20, # [Drug Class] Melatonin_Receptor_Agonists
                21, # [Drug Class] MSA
                22, # [Drug Class] NaSSA
                23, # [Drug Class] NDRI
                24, # [Drug Class] NMDAR_Antagonist
                25, # [Drug Class] OrexinAntagonists
                26, # [Drug Class] Psychedelics
                28, # [Drug Class] SGA
                29, # [Drug Class] SMS
                30, # [Drug Class] SNRI
                31, # [Drug Class] SSRI
                32, # [Drug Class] TCA_TeCA
                33)  # [Drug Class] Z_Drugs
                # 35 # [Outcome] Self Harm - Snomed)


# -------------------------------------------------------------------------
# Create all pairwise combinations (no duplicates)
# -------------------------------------------------------------------------

pairs <- expand.grid(
  targetId = cohort_ids, 
  comparatorId = cohort_ids,
  stringsAsFactors = FALSE
)

# Remove same-target-comparator and keep only ascending combinations
pairs <- pairs[pairs$targetId < pairs$comparatorId, ]

# -------------------------------------------------------------------------
# Helper function: Load excluded covariates
# -------------------------------------------------------------------------

load_excluded <- function(id) {
  files <- list.files(excluded_folder, full.names = TRUE)
  match_files <- files[grepl(id, files)]
  
  if (length(match_files) == 0) return("")
  
  all_ids <- c()
  for (f in match_files) {
    df <- read.csv(f, stringsAsFactors = FALSE)
    if ("Id" %in% colnames(df)) {
      all_ids <- c(all_ids, df$Id)
    }
  }
  
  all_ids <- unique(all_ids)
  paste(all_ids, collapse = ";")
}

# -------------------------------------------------------------------------
# Build output table
# -------------------------------------------------------------------------

pairs$outcomeIds <- outcome_ids

pairs$excludedCovariateConceptIds <- mapply(function(t, c) {
  t_excl <- load_excluded(t)
  c_excl <- load_excluded(c)
  
  res <- unique(c(
    unlist(strsplit(t_excl, ";")),
    unlist(strsplit(c_excl, ";"))
  ))
  
  res <- res[res != ""]
  paste(res, collapse = ";")
}, pairs$targetId, pairs$comparatorId)

pairs$includedCovariateConceptIds <- included_covariate_concept_ids

# -------------------------------------------------------------------------
# Save output
# -------------------------------------------------------------------------

write.csv(
  pairs,
  file = "inst/settings/TcosOfInterest.csv",
  row.names = FALSE,
  quote = FALSE
)

cat("File written: inst/settings/TcosOfInterest.csv\n")