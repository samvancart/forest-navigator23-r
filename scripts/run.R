source('scripts/settings.R')

# Run scripts with different settings


# Functions

# Read file lines
get_file_lines <- function(file_name) {
  f <- file(file_name, open="r")
  lines <- readLines(f)
  close(f)
  return(lines)
}


# get specified line from file lines
get_line <- function(lines, line) {
  found <- NULL
  for (i in seq_along(lines)){
    if (substr(lines[i],0,nchar(line)) == line) {
      found <- lines[i]
      return(found)
    }
  }
  if (is.null(found)) {
    print("Line not found!")
    return(NULL)
  }
}

# replace patterns in file: Old and new patterns given as vectors
replace_patterns <- function(old_patterns, new_patterns, lines) {
  for (i in 1:length(old_patterns)) {
    new_lines <- gsub(pattern = old_patterns[i], replacement = new_patterns[i], lines)
    lines <- new_lines
  }
  return(new_lines)
}


# Run species and estimate
run_species_and_estimate <- function(estimated_vector,species_vector,sources,settings_file="scripts/settings.R") {
  for (i in estimated_vector) {
    eID <- i
    new_eID <- paste0("estimatedID <- ", as.character(eID))
    for (j in species_vector) {
      sID <- j
      new_sID <- paste0("speciesID <- ", as.character(sID))
      lines <- get_file_lines(settings_file)
      new_lines <- replace_patterns(c(old_sID,old_eID),c(new_sID,new_eID),lines)
      writeLines(new_lines, settings_file)
      old_sID <- new_sID
      old_eID <- new_eID
      sapply(sources, source)
      print(paste0("Plots for speciesID ", sID, " and estimatedID ", eID, " done."))
    }
  }
}

# Run for ID
run_ID <- function(id_vector, id_name, old_id, sources=c(NULL), settings_file="scripts/settings.R") {
  for (i in id_vector) {
    id <- i
    new_id <- paste0(id_name, " <- ", as.character(id))
    lines <- get_file_lines(settings_file)
    new_lines <- replace_patterns(c(old_id),c(new_id),lines)
    writeLines(new_lines, settings_file)
    old_id <- new_id
    sapply(sources, source)
  }
}

# Modify an ID value
change_ID <- function(id, id_name, old_id, settings_file = "scripts/settings.R") {
  source(settings_file)
  new_id <- paste0(id_name, " <- ", as.character(id))
  lines <- get_file_lines(settings_file)
  new_lines <- replace_patterns(c(old_id),c(new_id),lines)
  writeLines(new_lines, settings_file)
  old_id <- new_id

}



# Initialise variables

# R files to run (vector in order)
multiSpecies <- c("scripts/multiSiteSpecies.R")
multiLayers <- c("scripts/multiSiteLayers.R")
multi_and_plots_species <- c("scripts/multiSiteSpecies.R", "scripts/plotsSpecies.R")
multi_and_plots_layers <- c("scripts/multiSiteLayers.R", "scripts/plotsLayers.R")
multi_and_outputs_species <- c("scripts/multiSiteSpecies.R", "scripts/output_tables.R")
multi_and_outputs_layers <- c("scripts/multiSiteLayers.R", "scripts/output_tables.R")
plot_tables <- c("scripts/plot_tables.R")
cluster_weighted_means <- c("scripts/cluster_weighted_means.R")
sums_means <- c("scripts/modout_sums_and_means.R")
layerAggr <- c("scripts/layerAggr.R")

# Vector values for loop. Values correspond to ids
species_vector <- c((1:3), 12)
estimated_vector <- c(1:2)
layer_vector <- c(1:2)
tabX_layer_vector <- c(1)
tabX_layerAggr_vector <- c(2)
settings_file <- "scripts/settings.R"
noManagement_vector <- c(0)
managed_vector <- c(1)
historical_climate_vector <-c(1)
GFDL_ESM4_SSP370_climate_vector <-c(2)
UKESM1_0_LL_ssp370_climate_vector <-c(3)
historical_detrend_climate_vector <- c(4)

# 1. Get file lines
lines <- get_file_lines(settings_file)

# 2. Get lines to modify
old_sID <- get_line(lines, "speciesID")
old_eID <- get_line(lines, "estimatedID")
old_lID <- get_line(lines, "layerID")
old_tabXID <- get_line(lines, "tabXID")
old_managementID <- get_line(lines, "managementID")
old_climateID <- get_line(lines, "climateID")

# run_ID(species_vector, "speciesID", old_sID, multiSpecies)
# run_ID(layer_vector, "layerID", old_lID, multiLayers)
# run_ID(species_vector, "speciesID", old_sID, multi_and_outputs_species)
# run_species_and_estimate(estimated_vector, species_vector, multi_and_plots_species)
# run_ID(layer_vector, "layerID", old_lID, plot_tables)
# run_ID(layer_vector, "layerID", old_lID, cluster_weighted_means)
# run_ID(layer_vector, "layerID", old_lID, sums_means)
# run_ID(layer_vector, "layerID", old_lID, layerAggr)



# # Change ID
# change_ID(1, "climateID", old_climateID)
# 
# 
# lines <- get_file_lines(settings_file)
# old_climateID <- get_line(lines, "climateID")
# change_ID(2, "climateID", old_climateID)

# Get species outputs for all climate and management scenarios
for(i in c(1,4)){
  lines <- get_file_lines(settings_file)
  old_climateID <- get_line(lines, "climateID")
  change_ID(i, "climateID", old_climateID)
  for(j in 0:1){
    lines <- get_file_lines(settings_file)
    old_managementID <- get_line(lines, "managementID")
    old_sID <- get_line(lines, "speciesID")
    change_ID(j, "managementID", old_managementID)
    run_ID(species_vector, "speciesID", old_sID, multi_and_outputs_species)
  }
  # Remove tran files from global environment
  rm(parTran,tairTran,precipTran,vpdTran,co2Tran)
}

# # Run outputs for all climates with current managementID
# for(i in 1:3){
#   lines <- get_file_lines(settings_file)
#   old_climateID <- get_line(lines, "climateID")
#   change_ID(i, "climateID", old_climateID)
#   run_ID(species_vector, "speciesID", old_sID, multi_and_outputs_species)
# }


# GET OUTPUT TABLES

# MODIFY FILE STRUCTURE FOR USER/QUNANTILE ESTIMATION IF NECESSARY

# # Set historical climate
# run_ID(historical_climate_vector, "climateID", old_climateID)
# run_ID(species_vector, "speciesID", old_sID, multi_and_outputs_species)

# # Set GFDL_ESM4_SSP370 climate
# run_ID(GFDL_ESM4_SSP370_climate_vector, "climateID", old_climateID)
# run_ID(species_vector, "speciesID", old_sID, multi_and_outputs_species)

# # Set UKESM1_0_LL_ssp370 climate
# run_ID(UKESM1_0_LL_ssp370_climate_vector, "climateID", old_climateID)
# run_ID(species_vector, "speciesID", old_sID, multi_and_outputs_species)


# GET ALL PLOTS

# # MultiSiteSpecies and plotsSpecies
# # Set management to noManagement
# run_ID(noManagement_vector, "managementID", old_managementID)
# run_species_and_estimate(estimated_vector, species_vector, multi_and_plots_species)

# # MultiSiteSpecies and plotsSpecies
# # Set management to managed
# run_ID(managed_vector, "managementID", old_managementID)
# run_species_and_estimate(estimated_vector, species_vector, multi_and_plots_species)

# # Get layers and then sums and means
# run_ID(layer_vector, "layerID", old_lID, multiLayers)
# run_ID(layer_vector, "layerID", old_lID, sums_means)
# source("scripts/plotsSumsMeans.R")

# Get layers and then plot tables to get side by side layer plots
# Set tabXID to 1
# run_ID(tabX_layer_vector, "tabXID", old_tabXID)
# run_ID(layer_vector, "layerID", old_lID, multiLayers)
# run_ID(layer_vector, "layerID", old_lID, plot_tables)
# source("scripts/plotsLayers.R")

# # Get weather plots
# source("scripts/plotsWeather.R")


# Get layers and then aggregates to get side by side layerAggr plots
# Set tabXID to 2
# run_ID(tabX_layerAggr_vector, "tabXID", old_tabXID)
# run_ID(layer_vector, "layerID", old_lID, multiLayers)
# run_ID(layer_vector, "layerID", old_lID, layerAggr)
# source("scripts/plotsLayers.R")






