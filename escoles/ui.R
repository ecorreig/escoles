# UI

library(shinydashboard)
library(shiny)  
library(leaflet)

ui <- dashboardPage(
  skin = "green",
  dashboardHeader(title = "COVID-19 ESCOLES"),
  dashboardSidebar(
    selectInput("colour", h3("Escala de colors"), 
                choices = list("Risc de rebrot" = 1, 
                               "Taxa de positius" = 2,
                               "Rho" = 3, 
                               "Guia de Harvard" = 4), 
                selected = 1),
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
  dashboardBody(
    fluidRow(box(width = 10, dataTableOutput(outputId = "school_table"))),
    fluidRow(box(width = 10, leafletOutput(outputId = "mymap"))),
    fluidRow(box(width = 10, dataTableOutput(outputId = "summary_table"))),
    tags$style(type = "text/css", "#map {height: calc(100vh - 80px) !important;}")
  ),
  
  leafletOutput("mymap", height = 1000)
  
)
