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
library(plotly)
library(DT)

launchApp <- function (wd) {

  script_path <- file.path(wd, "R")

  for (file in list.files(script_path)) {
    source(file.path(script_path, file), encoding = "UTF-8", local = T)
  }

  # Get data
  df <- get_covid_data()
  esc <- get_school_data(df)
  df <- compute_percentages(df, esc)
  evo <- get_evo(esc)
  
  # Init stuff
  globalObjects = ls(.GlobalEnv)
  if(".aecay.df" %in%  globalObjects){
    oldDataset1 = .GlobalEnv$.aecay.df
  }
  .GlobalEnv$.aecay.df <- df
  
  globalObjects = ls(.GlobalEnv)
  if(".aecay.esc" %in%  globalObjects){
    oldDataset2 = .GlobalEnv$.aecay.esc
  }
  .GlobalEnv$.aecay.esc <- esc
  
  globalObjects = ls(.GlobalEnv)
  if(".aecay.esc" %in%  globalObjects){
    oldDataset2 = .GlobalEnv$.aecay.esc
  }
  .GlobalEnv$.aecay.evo <- evo

  # Run
  shinyApp(ui = ui(), server = server)
}

# launchApp("server")