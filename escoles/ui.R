# UI

library(shinydashboard)
library(shiny)
library(leaflet)

css <- HTML("
  .navbar-default {
    background-color: #77eb9f;
      border-color: #E7E7E7;
  }")


ui <- navbarPage(
  "Escoles - COVID-19",
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
                 selected = NULL
               ),
               helpText(
                 "Alerta: si cliques per veure les escoles en situació",
                 "de normalitat, pot ser que l'aplicació vagi molt lenta."
               )
             ),
             mainPanel(
               fluidRow(box(
                 width = 12, dataTableOutput(outputId = "school_table")
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
           helpText("Lorem ipsum")),
  tags$head(tags$style(css))
)