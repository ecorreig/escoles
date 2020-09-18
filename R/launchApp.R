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
