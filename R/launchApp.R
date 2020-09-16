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
  
  shinyApp(ui = ui(), server = server)
}
