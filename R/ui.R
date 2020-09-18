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
  options(spinner.color="#0275D8", spinner.color.background="#ffffff", spinner.size=.4)
  navbarPage(title = "Escoles - COVID-19",
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
                   width = 12, shinycssloaders::withSpinner(dataTableOutput(outputId = "school_table"), type = 5)
                 )),
                 fluidRow(box(
                   width = 12, helpText(a("*Pots trobar la significació dels codis aquí", 
                                          href = "http://ensenyament.gencat.cat/web/.content/home/arees-actuacio/centres-serveis-educatius/centres/directoris-centres/codisnivellseducatius.pdf",
                                          target="_blank"))
                 )),
                 fluidRow(box(
                   width = 12, shinycssloaders::withSpinner(leafletOutput(outputId = "mymap", height = 700), type = 5)
                 )),
                 fluidRow(box(
                   width = 12, shinycssloaders::withSpinner(dataTableOutput(outputId = "summary_table"), type = 5)
                 )),
                 tags$style(type = "text/css", "#map {height: calc(100vh - 80px) !important;}")
               )
             )),
    tabPanel("Documentació",
             uiOutput("docs")),
    tags$head(tags$style(head_css()), 
              tags$link(rel = "shortcut icon", 
                        href = "https://www.projecteorbita.cat/wp-content/uploads/2020/09/logo_icon_sense_fons.png")),
    tags$body(tags$style(map_css()))
  )
} 