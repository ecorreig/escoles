library(shiny)
library(shinydashboard)
library(leaflet)
library(lubridate)
library(dplyr)
library(sf)
library(RSocrata)
library(googledrive)
library(readxl)
library(stringi)
library(shinythemes)
library(tidyr)
library(shinycssloaders)
library(rmapshaper)

print("Done loading packages.")

launchApp <- function (wd) {

  script_path <- file.path(wd, "R")

  for (file in list.files(script_path)) {
    source(file.path(script_path, file), encoding = "UTF-8", local = T)
  }

  # Get data
  temp <- get_covid_data()

  # Init stuff
  globalObjects = ls(.GlobalEnv)
  if(".aecay.df" %in%  globalObjects){
    oldDataset = .GlobalEnv$.aecay.df
  }

  .GlobalEnv$.aecay.df = temp

  globalObjects = ls(.GlobalEnv)
  if(".aecay.esc" %in%  globalObjects){
    oldDataset = .GlobalEnv$.aecay.esc
  }

  .GlobalEnv$.aecay.esc = get_school_data(temp)

  # Run
  shinyApp(ui = ui(), server = server)
}
