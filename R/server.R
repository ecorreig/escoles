# Server

#' @import leaflet
#' @import shiny
#' @import shinydashboard


server <- function(input, output, session) {

  df <- .aecay.df
  esc <- .aecay.esc

  # Colour scale based input
  col <- reactive({
    if (input$colour == 1) {
      col <- "clean_epg"
    } else if (input$colour == 2) {
      col <- "clean_taxa_incidencia_14d"
    } else if (input$colour == 3) {
      col <- "clean_rho"
    } else if (input$colour == 4) {
      col <- "harvard"
    }
  })

  pal <- reactive({
    if (input$colour == 1) {
      pal <-
        colorNumeric(palette = palette,
                     domain = df[["clean_epg"]],
                     reverse = rev)
    } else if (input$colour == 2) {
      pal <-
        colorNumeric(palette = palette,
                     domain = df[["clean_taxa_incidencia_14d"]],
                     reverse = rev)
    } else if (input$colour == 3) {
      pal <-
        colorNumeric(palette = palette,
                     domain = df[["clean_rho"]],
                     reverse = rev)
    } else if (input$colour == 4) {
      pal <-
        colorFactor(palette = "RdYlGn",
                    domain = df[["harvard"]],
                    reverse = T)
    }

  })
  # FIXME: this is very stupid
  tit <- reactive({
    if (input$colour == 1) {
      tit <- "Risc de rebrot*"
    } else if (input$colour == 2) {
      tit <- "Taxa de positius*"
    } else if (input$colour == 3) {
      tit <- "Rho*"
    } else if (input$colour == 4) {
      tit <- "Guia de Harvard"
    }
  })

  # School type based input
  clean_schools <- reactive({
    if (is.null(input$school_status)) {
      clean_schools <- esc[esc$Codi_centre == "1",]
    } else {
      vals <- NULL
      if (1 %in% input$school_status) {
        vals <- c(vals, "Normalitat")
      }
      if (2 %in% input$school_status) {
        vals <- c(vals, "Grups en quarantena")
      }
      if (3 %in% input$school_status) {
        vals <- c(vals, "Tancada")
      }
      if (4 %in% input$school_status) {
        vals <- c(vals, "Desconnegut")
      }
      clean_schools <- esc[esc$Estat %in% vals,]
    }
  })


  # Output
  output$mymap <- renderLeaflet({
    withProgress(
    leaflet(options = leafletOptions(preferCanvas = TRUE)) %>%
      addProviderTiles(
        provider = providers$CartoDB.Voyager,
        options = providerTileOptions(updateWhenZooming = FALSE,
                                      updateWhenIdle = TRUE)
      ) %>%
      setView(lat = 41.7,
              lng = 2,
              zoom = 8) %>%
      addPolygons(
        data = df,
        weight = 2,
        smoothFactor = 0.2,
        fillOpacity = .7,
        color = ~ pal()(df[[col()]]),
        label = df$Municipi,
        popup = mun_popup(df),
        popupOptions = popup_options()
      ) %>%
      addLegend(
        "bottomright",
        pal = pal(),
        values = df[[col()]],
        title = tit(),
        opacity = .8
      ) %>%
      addAwesomeMarkers(
        clusterOptions = markerClusterOptions(disableClusteringAtZoom=11),
        layerId = clean_schools()$Codi_centre,
        as.numeric(clean_schools()$Coordenades_GEO_X),
        as.numeric(clean_schools()$Coordenades_GEO_Y),
        popup = esc_popup(clean_schools()),
        popupOptions = popup_options(),
        label = as.character(clean_schools()$Denominacio_completa),
        icon = get_icons(clean_schools())
      ) %>%
      addMarkers(
        lat = 41.0,
        lng = 2.1,
        icon =   icons(
          iconUrl = system.file("extdata", "logo_icon.png", package = "EscolesCovid", mustWork = T),
          iconWidth = 40,
          iconHeight = 40,
          iconAnchorX = 40 / 2,
          iconAnchorY = 40 / 2
        ),
        popup = orbita_popup,
        popupOptions = popup_options(),
        label = "Projecte Òrbita"
      )
    )
  })
  output$school_table <-
    renderDataTable({
      as.data.frame(clean_schools())[, school_vars] %>%
        rename_all(funs(c(new_school_names)))
    },   options = list(pageLength = 5,
                        stateSave = TRUE))

  output$summary_table <- renderDataTable({
      withProgress( as.data.frame(df)[, mun_vars] %>%
                      arrange(desc(epg)) %>%
                      rename_all(funs(c(new_mun_names))))

  },
  options = list(pageLength = 5))


  output$docs <- renderUI({
    HTML(docs)
  })
  output$quisom <- renderUI({
    HTML(orbita_popup)
  })

  # Actions
  # NOT WORKING -------------------------

  # observeEvent(input$mymap_marker_click, {
  #   event <- input$mymap_marker_click
  #   mis_info <- is.na(clean_schools() %>% filter(Codi.centre == event$id) %>% pull(num_alumnes))
  #   if (!is.null(event) & mis_info) {
  #     output$school_details <- renderUI({
  #       tagList(
  #       numericInput("line_num", h3("Número de línies"),
  #                    value = 1),
  #       numericInput("course_num", h3("Número de cursos"),
  #                    value = 1),
  #       numericInput("als_per_class", h3("Alumnes per classe"),
  #                    value = 25),
  #       actionButton("input_1", "Entra els valors"),
  #       helpText(
  #         "Si saps la informació de l'escola durant aquest curs, podrem calcular ",
  #         "de forma més acurada les probabilitats de l'escola. ",
  #         "Omple els tres valors d'aquí sobre o el número total ",
  #         "d'alumnes aquí sota."
  #       ),
  #       sliderInput("student_num", h3("Número total d'alumnes"),
  #                   min = 0, max = 2000, value = 300),
  #       actionButton("input_2", "Entra el valor")
  #       )
  #       helpText("-----------------")
  #     })
  #   }
  # })
  # # Not working:
  # eventReactive(T, {
  #   print(output)
  # })
  # eventReactive(output.school_details.input_1, {
  #   print("input 1!!")
  #
  #   clean_schools() %>%
  #     filter(Codi.centre == event$id) %>%
  #     mutate(cursos = output$school_details$course_num,
  #            linies = output$school_details$line_num,
  #            als_per_classe = output$school_details$als_per_class) %>%
  #     mutate(num_alumnes = cursos * linies * als_per_classe) %>%
  #     write.csv(., "escoles_2.csv", row.names = F)
  # })
  # eventReactive(output.school_details.input_2, {
  #   print("input 2!!")
  #   clean_schools() %>%
  #     filter(Codi.centre == event$id) %>%
  #     mutate(num_alumnes = output$school_details$student_num) %>%
  #     write.csv(., "escoles_2.csv", row.names = F)
  # })


}