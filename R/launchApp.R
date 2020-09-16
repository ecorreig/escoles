#' launches the EscolesOrbita app
#'
#' @export launchApp
#'
#' @return shiny application object
#'
#' @example \dontrun {launchApp()}
#'
#' @import shiny
#' @import shinydashboard


launchApp <- function() {
  
  shinyApp(ui = ui(), server = server)
}
