# Create TRAN files from climate data and save to folder. The code assumes that
# the climate data includes a splitID column. The splitID is used to split the 
# dt for running in parts. If the dt is small enough to run in one go, then
# splitID 1 should be used for all rows.



source('scripts/settings.R')
source('./r/multiSite.R')
source('./r/utils.R')



# Climate scenario name
climateScenario <- tolower(config$VAR_climate_names[config$VAR_climate_id])

print(paste0("Running create_tran.R"))
print(paste0("Climate scenario is: ", climateScenario))
print(paste0("VAR_climate_id is: ", config$VAR_climate_id))
print(paste0("VAR_split_id is: ", config$VAR_split_id))
cat("\n")

print(paste0("Loading data..."))
# Load climate data using custom function
climate_dt <- load_data(config$VAR_climate_paths[config$VAR_climate_id])

# Name of splitID column
split_id_name <- "splitID"

print(paste0("Splitting data..."))
# Filter climate_dt based on splitID
split_dt <- climate_dt[get(split_id_name) == config$VAR_split_id]

rm(climate_dt)
gc()

# Add day column
split_dt[, day := .GRP, by = c("time")]

# Variables to create TRAN tables for
tranVars <- c("par", "vpd", "co2", "precip", "tair")

print(paste0("Creating tran matrices..."))
cat("\n")

# Create list of TRAN matrices
tranMatrices <- lapply(tranVars, function(x) {
  formula <- as.formula(paste("siteID", "~", "day"))
  dcast_dt <- as.matrix(dcast(split_dt, formula, value.var = x))
})

# Add names to list
names(tranMatrices) <- paste0(tranVars,"Tran")

# Create PATH_tran variable
path_tran_var <- config$PATH_tran

# Create PATH_tran if it doesn't exist
path_tran <- get_or_create_path(pathVarName = "path_tran_var", defaultDir = config$PATH_tran, subDir = climateScenario)

# Create save path
savePath <- paste0(path_tran, climateScenario)

# Invisibly save
invisible(lapply(names(tranMatrices), function(x) {
  
  # Create temp environment
  env <- new.env()

  # Store list item as object
  item <- tranMatrices[[x]]
  
  # Assign name to item
  assign(x, item, envir = env)
  
  print(paste0("Saving ", x, " into ", savePath, " with split_id ", config$VAR_split_id))

  # Save
  save(list = x, file = paste0(savePath, "/", x, "_", config$VAR_split_id, ".RData"), envir = env)

  # Remove temp environment
  rm(env)
  
}))


# # Clean up if not using yaml.runner
# keep_vars <- c("config", "config_path")
# remove_selected_variables_from_env(keep_vars)
 




















