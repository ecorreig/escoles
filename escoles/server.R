# Server

school_vars <- c("Denominacio.completa", "Nom.naturalesa", "Nom.municipi", "Nom.localitat", "Estat")
mun_vars <- c("Municipi", "Comarca", "Poblacio", "numcasos", "casos_24h", 
              "rho", "taxa_incidencia_14d", "taxa_casos_nous", "epg")
new_names <- c("Municipi", "Comarca", "Població", "Casos 14 dies", "Casos 24h", "Rho 7 dies",
               "Incidència 14 dies", "Taxa 24h", "Risc de rebrot")

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
      pal <- colorNumeric(palette = "plasma", domain = df[["epg"]], reverse = T)
    } else if (input$colour == 2) {
      pal <- colorNumeric(palette = "plasma", domain = df[["taxa_incidencia_14d"]], reverse = T)
    } else if (input$colour == 3) {
      pal <- colorNumeric(palette = "plasma", domain = df[["rho"]], reverse = T)
    } else if (input$colour == 4) {
      pal <- colorFactor(palette = "RdYlGn", domain = df[["harvard"]], reverse = T)
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
      clean_schools <- esc[esc$Codi.centre == "1", ]
    } else if (input$school_status == 1) {
      clean_schools <- esc[esc$estat == "Normalitat" | esc$Codi.centre == 1, ]
    } else if (input$school_status == 2) {
      clean_schools <- esc[esc$estat == "Casos" | esc$Codi.centre == 1, ]
    } else if (input$school_status == 3) {
      clean_schools <- esc[esc$estat == "Tancada" | esc$Codi.centre == 1, ]
    } else if (input$school_status == 4) {
      clean_schools <- esc[!esc$estat %in% c("normal", "casos", "tancada"), ]
    } 
  })
  
  
  # Output
  output$school_table <- renderDataTable({
    clean_schools()[, school_vars] %>% rename_all(funs(gsub(".", " ", school_vars, fixed = T)))
  }, 
  options = list(
    pageLength = 5
  )
  )
  
  output$mymap <- renderLeaflet({
    leaflet() %>%
      addProviderTiles(provider = providers$CartoDB.Positron,
                       options = providerTileOptions(updateWhenZooming = FALSE,
                                                     updateWhenIdle = TRUE)) %>%
      setView(lat = 41.7, lng = 2, zoom = 7) %>%
      addPolygons(
        data = df,
        weight = 2,
        smoothFactor = 0.2,
        fillOpacity = .7,
        color = ~ pal()(df[[col()]]),
        label = df$Municipi,
        popup = df$Municipi) %>% 
      addLegend("bottomright", pal = pal(), values = df[[col()]],
                title = tit(),
                opacity = .8
      ) %>%
      addMarkers(as.numeric(clean_schools()$Coordenades.GEO.X),
                 as.numeric(clean_schools()$Coordenades.GEO.Y),
                 popup = as.character(clean_schools()$Denominacio.completa),
                 label = as.character(clean_schools()$Denominacio.completa),
                 icon = icones_escoles(esc)
      )
  }) 
  output$summary_table <- renderDataTable({
    as.data.frame(df)[, mun_vars] %>% rename_all(funs(c(new_names)))
  },
  options = list(
    pageLength = 5
  )
  )
  
}