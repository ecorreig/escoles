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
.marker-cluster-custom {
  background-color: rgba(50, 186, 26, 1);
}
  "
  )
}

ui <- function() {
  options(spinner.color="#0275D8", spinner.color.background="#ffffff", spinner.size=.4)
  navbarPage(title = "Centres educatius - COVID-19",
    theme = shinythemes::shinytheme("yeti"),
    tabPanel("Principal",
             sidebarLayout(
               sidebarPanel(
                 width = 3,
                 selectInput(
                   "colour",
                   h3("Indicador epidemiològic*"),
                   choices = list(
                     "Risc de rebrot" = 1,
                     "Taxa de positius" = 2,
                     "Rho" = 3,
                     "Guia de Harvard" = 4
                   ),
                   selected = 1
                 ),
                 helpText(
                   "*Pots trobar definicions dels indicadors epidemiològics a la pestanya 'Documentació'."
                 ),
                 checkboxGroupInput(
                   "school_status",
                   h3("Situació centres educatius"),
                   choices = list(
                     "Normalitat" = 1,
                     "Grups en quarentena" = 2,
                     "Tancada" = 3,
                     "Desconnegut" = 4
                   ),
                   selected = c(2, 3)
                 ),
                 helpText(
                   "Alerta: si cliques per veure els centres educatius en situació",
                   "de normalitat, pot ser que l'aplicació vagi lenta."
                 ) # ,
                 # uiOutput("school_details")

               ),
               mainPanel(
                 fluidRow(box(width = 12, h5("Mapa de l'estat dels centres educatius de Catalunya segons la incidència de COVID19"))),
                 fluidRow(box(
                   width = 12, shinycssloaders::withSpinner(leafletOutput(outputId = "mymap", height = 700), type = 5)
                 )),
                 fluidRow(box(
                   width = 12, helpText("*A l'escala de colors, hem tallat els indicadors epidemiològics a valors límit quan eren desorbitats, però quan apretes sobre els territoris encara et sortiran els valors orginals.")
                 )),
                 fluidRow(box(width = 12, h3("Taula de situació de centres educatius"))),
                 fluidRow(box(
                   width = 12, shinycssloaders::withSpinner(dataTableOutput(outputId = "school_table"), type = 5)
                 )),
                 fluidRow(box(
                   width = 12, helpText(a("*Pots trobar la significació dels codis aquí",
                                          href = "http://ensenyament.gencat.cat/web/.content/home/arees-actuacio/centres-serveis-educatius/centres/directoris-centres/codisnivellseducatius.pdf",
                                          target="_blank"))
                 )),
                 fluidRow(box(width = 12, h3("Taula de situació de municipis"))),
                 fluidRow(box(
                   width = 12, shinycssloaders::withSpinner(dataTableOutput(outputId = "summary_table"), type = 5)
                 )),
                 tags$style(type = "text/css", "#map {height: calc(100vh - 80px) !important;}")
               )
             )),
    tabPanel("Documentació",
             fluidRow(column(width = 2, ""), column(width = 8, uiOutput("docs")), column(width = 2, ""))),
    tabPanel("Qui som", fluidRow(column(width = 2, ""), column(width = 8, uiOutput("quisom")), column(width = 2, ""))),
    tags$head(tags$style(head_css()),
              HTML(analytics_tag()),
              tags$link(rel = "shortcut icon",
                        href = "https://www.projecteorbita.cat/wp-content/uploads/2020/09/logo_icon_sense_fons.png")),
    tags$body(tags$style(map_css()))
  )
}