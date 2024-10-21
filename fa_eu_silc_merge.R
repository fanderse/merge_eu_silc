################################################################################
# Merge EU-SILC files. 
# program takes paths to files as user input and has the option to
# add or not add register data, in case storage size matters
# main function works for both individual and household level data
# in a last step, composite individual and household level data can
# be merged into one dataset
# author: Florian Andersen
# last updated: Oct 21 2024
################################################################################

# only required package
library(dplyr)

# please specify path to files
base_path <- ""
setwd(base_path)

# would you like to merge register files?
# "y" for yes, "n" for no
# I recommend merging them!
m <- "y"

# please specify file names
file_names_data <- c(
  "",
  "",
  "",
  ""
)

# please specify file names
file_names_registers <- c(
  "",
  "",
  "",
  ""
)

j <- 1

# create function to load and merge csv files
bind_rows_silc <- function(file_names_data, base_path) {
  # initialize an empty list to store data frames
  data_list <- list()
  
  # loop through each file name
  for (file_name in file_names_data) {
    # build the full file path
    file_path <- file.path(base_path, file_name)
    
    # read indiividual csv
    data <- read.csv(file_path)
    
    # append to data list
    data_list[[length(data_list) + 1]] <- data
    # run gc() to free space during the loop
    gc()
    
    # combine data frames in the list into one
    combined_data <- bind_rows(data_list)
    
    # rename rows from register files to the names in the data files
    # for the merge, we use (1) personal ID, (2) country ID, and
    # (3) year as the row identifiers
    
    if (m == "y") {
      file_path <- file.path(base_path, file_names_registers[j])
      register <- read.csv(file_path)
      if (colnames(register)[1] == "RB010") {
      combined_data <- full_join(combined_data, register,
                                 by = c("PB030" = "RB030",
                                        "PB020" = "RB020",
                                        "PB010" = "RB010"))
      
    } else {
      combined_data <- full_join(combined_data, register,
                                 by = c("HB030" = "DB030",
                                        "HB020" = "DB020",
                                        "HB010" = "DB010"))
    }
                             
    }
    
    j <- j+1 
  }

  # remove duplicates (if any)
  combined_data <- distinct(combined_data)
  
  # clean up the workspace
  rm(data_list)
  gc()
  
  return(combined_data)
}

################################################################################
# run function to create composite EU-SILC file with
# multiple annual waves and optional register data
# _p refers to "personal files"
# user may wish to use _h for household files
silc_p <- bind_rows_silc(file_names_data, base_path)

# in case the user created two composite files, one holding household-level info
# and the other holding individua-level info, both files can easily be merged into one using:
# silc_h_p <- full_join(silc_h, silc_p, by = "HB030" = "RB040",
#                                             "HB020" = "RB020",
#                                             "HB010" = "RB010")
# the _h_p refers to "household" and "person", thus indicating a data file
# that includes both levels

save(silc_p, file = "silc_p.Rdata")



