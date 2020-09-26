
tryCatch(
  {
    source(file.path("R", "utils.R"), encoding = "UTF-8")
    },
  error = function(cond) {
    source(file.path("utils.R"), encoding = "UTF-8")
  }
)


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
.marker-cluster-custom-green {
  background-color: rgba(50, 186, 26, 1);
}
.marker-cluster-custom-orange {
  background-color: rgba(255,165,0, 1);
}
.leaflet-popup-content-wrapper, .leaflet-popup-tip {
    opacity: .95;
}
.leaflet-container a {
    color: #0078A8!important;
}
.leaflet-popup-content {
    line-height: 1;
    display: block;
    background: #fff;
    color: #000;
    margin: 7px;
    margin-bottom: 20px;
    padding: 9px 10px;
    border-radius: 8px;
    width: 450px;
    min-height: 200px;
    max-width: 100%;
    max-height: calc(100% - 20px);
    overflow: auto;
    box-sizing: border-box;
    z-index: 99;
    user-select: auto;
    pointer-events: auto;
    box-shadow = 3px 3px rgba(0,0,0,0.25);
}
ul {
  list-style-type: none;
  margin: 5px;
  padding: 0;
}

.leaflet-container a.leaflet-popup-close-button {
  content: 'Tanca';
  cursor: pointer;
  position: absolute;
  top: 90%;
  left: 40%;
  padding: 5px 5px;
  margin: 12px 0;
  transform: translate(0%, -50%);
  text-align: center;
  width: 50px;
  height: 14px;
  font: 16px/14px Tahoma, Verdana, sans-serif;
  color: #c3c3c3;
  text-decoration: none;
  font-weight: bold;
  background: transparent;
  
}
h3 {
    margin-top: 5px;
    margin-bottom: 10.5px;
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
                 width = 4,
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
                   selected = 1:3
                 ),
                 helpText(
                   "Alerta: si cliques per veure els centres educatius en situació",
                   "de normalitat, pot ser que l'aplicació vagi lenta."
                 ),
                 h3("Evolució"),
                 plotly::plotlyOutput(outputId = "evo1"),
                 plotly::plotlyOutput(outputId = "evo2"),
                 helpText("*CEs = Centres educatius")

               ),
               mainPanel(
                 fluidRow(shinydashboard::box(width = 12, h5("Mapa de l'estat dels centres educatius de Catalunya segons la incidència de COVID19"))),
                 fluidRow(shinydashboard::box(
                   width = 12, shinycssloaders::withSpinner(leaflet::leafletOutput(outputId = "mymap", height = 700), type = 5)
                 )),
                 fluidRow(shinydashboard::box(
                   width = 12, helpText("*A l'escala de colors, hem tallat els indicadors epidemiològics a valors límit quan eren desorbitats, però quan apretes sobre els territoris encara et sortiran els valors orginals.")
                 )),
                 fluidRow(shinydashboard::box(width = 12, h3("Taula de situació de centres educatius"))),
                 fluidRow(shinydashboard::box(
                   width = 12, shinycssloaders::withSpinner(DT::dataTableOutput(outputId = "school_table"), type = 5)
                 )),
                 fluidRow(shinydashboard::box(
                   width = 12, helpText(a("*Pots trobar la significació dels codis aquí",
                                          href = "http://ensenyament.gencat.cat/web/.content/home/arees-actuacio/centres-serveis-educatius/centres/directoris-centres/codisnivellseducatius.pdf",
                                          target="_blank"))
                 )),
                 fluidRow(shinydashboard::box(width = 12, h3("Taula de situació de municipis"))),
                 fluidRow(shinydashboard::box(
                   width = 12, shinycssloaders::withSpinner(DT::dataTableOutput(outputId = "summary_table"), type = 5)
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