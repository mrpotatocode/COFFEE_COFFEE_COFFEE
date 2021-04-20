library(tidyverse)
library(data.table)
library(readxl)
library(here)

#function for fread (data.table)
read_plus <- function(flnm) {
  read_csv(flnm) %>% 
    mutate(filename = flnm) %>% 
    rename_with(str_to_title)}

#tasting note folder
tasting_folder <- "inputs/data/Conformed/"

SCAA_Notes <-  
  #load tasting notes
  read_xlsx(here::here(tasting_folder,'SCAA_TastingNotes.xlsx'))

###UPDATED FOR PAPER, JUST LOAD A STATIC CSV, that way the values in the paper do not update

#load all data from Automatic_Drip
#raw_data <-  
#  list.files(path = "../../Automatic_Drip/R/outputs/",
#             pattern = "*.csv",
#             full.names = T) %>% 
#  map_df(~read_plus(.))

raw_data <- read_csv('data/paper_dataset.csv')