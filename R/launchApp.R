#' launches the EscolesOrbita app
#'
#' @export launchApp
#'
#' @return shiny application object
#'
#' @examples \dontrun {launchApp()}
#'
#' @import shiny
#' @import shinydashboard


launchApp <- function() {
  
  # Get data
  df <- get_covid_data()
  esc <- get_school_data(df)
  df <- compute_percentages(df, esc)
  evo <- get_evo()
  
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
    oldDataset2 = .GlobalEnv$.aecay.evo
  }
  .GlobalEnv$.aecay.evo <- evo

  
  # Run
  shinyApp(ui = ui(), server = server)
}
