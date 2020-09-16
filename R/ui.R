# UI

#' @import leaflet
#' @import shinydashboard
#' @import shiny
#' @importFrom shinythemes shinytheme


head_css <- function() {
  HTML(
    "
  .navbar-default {
    background-color: #77eb9f;
      border-color: #E7E7E7;
  }
  #img-id{
    position: fixed;
    right: 10px;
    top: 5px;
}
"
  )
} 
map_css <- function() {
  HTML(
    "
  .awesome-marker-icon-blue {
display:none;
}
.awesome-marker-shadow {
display:none;
}
.po-popup {
  font-weight: bold;
}
.leaflet-container {
    background-color:rgba(255,255,255,)!important;
}
  "
  )
} 

ui <- function() {

  navbarPage(title = div(
    div(
      id = "img-id",
      img(src = "https://www.projecteorbita.cat/wp-content/uploads/2020/02/logo_orbita_700x250-2.png", 
          height = 40, width = 100)
    ), "Escoles - COVID-19"),
    theme = shinythemes::shinytheme("yeti"),
    tabPanel("Principal",
             sidebarLayout(
               sidebarPanel(
                 width = 3,
                 selectInput(
                   "colour",
                   h3("Escala de colors"),
                   choices = list(
                     "Risc de rebrot" = 1,
                     "Taxa de positius" = 2,
                     "Rho" = 3,
                     "Guia de Harvard" = 4
                   ),
                   selected = 1
                 ),
                 checkboxGroupInput(
                   "school_status",
                   h3("Situació escoles"),
                   choices = list(
                     "Normalitat" = 1,
                     "Casos" = 2,
                     "Tancada" = 3,
                     "Desconnegut" = 4
                   ),
                   selected = c(2, 3)
                 ),
                 helpText(
                   "Alerta: si cliques per veure les escoles en situació",
                   "de normalitat, pot ser que l'aplicació vagi lenta."
                 ) # ,
                 # uiOutput("school_details")
                 
               ),
               mainPanel(
                 fluidRow(box(
                   width = 12, dataTableOutput(outputId = "school_table")
                 )),
                 fluidRow(box(
                   width = 12, helpText(a("*Pots trobar la significació dels codis aquí", 
                                          href = "http://ensenyament.gencat.cat/web/.content/home/arees-actuacio/centres-serveis-educatius/centres/directoris-centres/codisnivellseducatius.pdf",
                                          target="_blank"))
                 )),
                 fluidRow(box(
                   width = 12, leafletOutput(outputId = "mymap", height = 700)
                 )),
                 fluidRow(box(
                   width = 12, dataTableOutput(outputId = "summary_table")
                 )),
                 tags$style(type = "text/css", "#map {height: calc(100vh - 80px) !important;}")
               )
             )),
    tabPanel("Documentació",
             uiOutput("docs")),
    tags$head(tags$style(head_css())),
    tags$body(tags$style(map_css()))
  )
} 