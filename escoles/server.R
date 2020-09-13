# Server


library(shiny)
library(shinydashboard)
library(leaflet)

encoding_ <- "UTF-8"
source("calcs.R", encoding = encoding_)

mun_popup <- function(df) {
  paste0("<h3>", df$Municipi, " (", df$Poblacio," habitants)</h3>  
         <strong> Índex de risc: ", df$epg, "</strong> 
         <p> Casos últims 14 dies: ", df$numcasos, " (", df$taxa_incidencia_14d, " casos per 100k h.) </p>
         <p>Casos últimes 24 hores: ", df$casos_24h, " (", df$taxa_casos_nous, " casos per 100k h.) </p>
         <p>Rho7: ", df$rho, "</p>
         <h5> Probabilitat d'un cas en una classe: ", round(100 * df$prob_one_case_class, 2), "%</h5>
         <p>Probabilitat d'un cas a l'escola: ", round(100 * df$prob_one_case_school, 2), "%</p>
         <p>Probabilitat escola tancada: ", round(100 * df$prob_closed_school, 2), "%</p>"
         )
}

val_or_none <- function(x) {
  ifelse(is.na(x), "--", x)
}

esc_popup <- function(esc) {
  paste0("<h3>", esc$Denominacio.completa, " </h3>
         <p> Tipologia: ", esc$Nom.naturalesa, "</p>
         <p> Línies: ", val_or_none(esc$linies), "</p>
         <p> Cursos: ",  val_or_none(esc$cursos), "</p>
         <p> Alumnes per classe: ",  val_or_none(esc$als_per_classe), "</p>
         <h5> Probabilitat d'un cas en una classe: ", round(100 * esc$prob_one_case_class, 2), "%</h5>
         <p>Probabilitat d'un cas a l'escola: ", round(100 * esc$prob_one_case_school, 2), "%</p>
         <p>Probabilitat escola tancada: ", round(100 * esc$prob_closed_school, 2), "%</p>"
  )
}

server <- function(input, output, session) {
  # Colour scale based input
  col <- reactive({
    if (input$colour == 1) {
      col <- "epg"
    } else if (input$colour == 2) {
      col <- "taxa_incidencia_14d"
    } else if (input$colour == 3) {
      col <- "rho"
    } else if (input$colour == 4) {
      col <- "harvard"
    } else {
      stop("I don't understand the input, shithead.")
    }
  })
  
  pal <- reactive({
    if (input$colour == 1) {
      pal <-
        colorNumeric(palette = "plasma",
                     domain = df[["epg"]],
                     reverse = T)
    } else if (input$colour == 2) {
      pal <-
        colorNumeric(palette = "plasma",
                     domain = df[["taxa_incidencia_14d"]],
                     reverse = T)
    } else if (input$colour == 3) {
      pal <-
        colorNumeric(palette = "plasma",
                     domain = df[["rho"]],
                     reverse = T)
    } else if (input$colour == 4) {
      pal <-
        colorFactor(palette = "RdYlGn",
                    domain = df[["harvard"]],
                    reverse = T)
    } else {
      stop("I don't understand the input, shithead.")
    }
  })
  # FIXME: this is very stupid
  tit <- reactive({
    if (input$colour == 1) {
      tit <- "Risc de rebrot"
    } else if (input$colour == 2) {
      tit <- "Taxa de positius"
    } else if (input$colour == 3) {
      tit <- "Rho"
    } else if (input$colour == 4) {
      tit <- "Guia de Harvard"
    } else {
      stop("I don't understand the input, shithead.")
    }
  })
  
  # School type based input
  clean_schools <- reactive({
    if (is.null(input$school_status)) {
      clean_schools <- esc[esc$Codi.centre == "1",]
    } else if (input$school_status == 1) {
      clean_schools <-
        esc[esc$Estat == "Normalitat" | esc$Codi.centre == 1,]
    } else if (input$school_status == 2) {
      clean_schools <- esc[esc$Estat == "Casos" | esc$Codi.centre == 1,]
    } else if (input$school_status == 3) {
      clean_schools <-
        esc[esc$Estat == "Tancada" | esc$Codi.centre == 1,]
    } else if (input$school_status == 4) {
      clean_schools <-
        esc[!esc$Estat %in% c("normal", "casos", "tancada"),]
    }
  })
  
  
  # Output
  output$school_table <- renderDataTable({
    as.data.frame(clean_schools())[, school_vars] %>% rename_all(funs(gsub(".", " ", school_vars, fixed = T)))
  },
  options = list(pageLength = 5,
                 stateSave = TRUE))
  
  output$mymap <- renderLeaflet({
    leaflet() %>%
      addProviderTiles(
        provider = providers$CartoDB.Positron,
        options = providerTileOptions(updateWhenZooming = FALSE,
                                      updateWhenIdle = TRUE)
      ) %>%
      setView(lat = 41.7,
              lng = 2,
              zoom = 7) %>%
      addPolygons(
        data = df,
        weight = 2,
        smoothFactor = 0.2,
        fillOpacity = .7,
        color = ~ pal()(df[[col()]]),
        label = df$Municipi,
        popup = mun_popup(df)
      ) %>%
      addLegend(
        "bottomright",
        pal = pal(),
        values = df[[col()]],
        title = tit(),
        opacity = .8
      ) %>%
      addMarkers(
        as.numeric(clean_schools()$Coordenades.GEO.X),
        as.numeric(clean_schools()$Coordenades.GEO.Y),
        popup = esc_popup(clean_schools()),
        label = as.character(clean_schools()$Denominacio.completa),
        icon = icones_escoles
      )
  })
  output$summary_table <- renderDataTable({
    as.data.frame(df)[, mun_vars] %>% rename_all(funs(c(new_names)))
  },
  options = list(pageLength = 5))
  
}