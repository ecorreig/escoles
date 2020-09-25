

server <- function(input, output, session) {
  
  get_icons <- function(esc) {
    
    # I want to avoid using fontawesome package because it's hard to install
    school <- "<svg style='height:0.8em;top:.04em;position:relative;' viewBox='0 0 640 512'><path d='M0 224v272c0 8.84 7.16 16 16 16h80V192H32c-17.67 0-32 14.33-32 32zm360-48h-24v-40c0-4.42-3.58-8-8-8h-16c-4.42 0-8 3.58-8 8v64c0 4.42 3.58 8 8 8h48c4.42 0 8-3.58 8-8v-16c0-4.42-3.58-8-8-8zm137.75-63.96l-160-106.67a32.02 32.02 0 0 0-35.5 0l-160 106.67A32.002 32.002 0 0 0 128 138.66V512h128V368c0-8.84 7.16-16 16-16h96c8.84 0 16 7.16 16 16v144h128V138.67c0-10.7-5.35-20.7-14.25-26.63zM320 256c-44.18 0-80-35.82-80-80s35.82-80 80-80 80 35.82 80 80-35.82 80-80 80zm288-64h-64v320h80c8.84 0 16-7.16 16-16V224c0-17.67-14.33-32-32-32z'/></svg>"
    
    leaflet::makeAwesomeIcon(
      text = school,
      iconColor = "black",
      markerColor = esc %>% mutate(
        color = case_when(
          Codi_centre == "1" ~ "blue",
          Estat == "Normalitat" ~ "green",
          Estat == "Grups en quarantena" ~ "orange",
          Estat == "Tancada" ~ "red",
          TRUE ~ "black"
        )
      ) %>% pull(color)
    )
  }

  df <- .aecay.df
  esc <- .aecay.esc
  evo <- .aecay.evo

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
      clean_schools <- esc[esc$Estat %in% vals | esc$Codi_centre == "1",]
    }
  })


  # Output
  output$mymap <- renderLeaflet({
    
    norm_esc <- clean_schools()[clean_schools()$Estat == "Normalitat"  | clean_schools()$Codi_centre == "1", ]
    alt_esc <- clean_schools()[clean_schools()$Estat != "Normalitat"  | clean_schools()$Codi_centre == "1", ]
    
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
        clusterOptions = markerClusterOptions(
          disableClusteringAtZoom=12,
          iconCreateFunction=JS("function (cluster) {    
    var childCount = cluster.getChildCount(); 
    var c = ' marker-cluster-custom';  
    return new L.DivIcon({ html: '<div><span>' + childCount + '</span></div>', className: 'marker-cluster' + c, iconSize: new L.Point(40, 40) });

  }")
          ),
        layerId = as.character(norm_esc$Codi_centre),
        as.numeric(norm_esc$Coordenades_GEO_X),
        as.numeric(norm_esc$Coordenades_GEO_Y),
        popup = esc_popup(norm_esc),
        popupOptions = popup_options(),
        label = as.character(norm_esc$Denominacio_completa),
        icon = get_icons(norm_esc)
      ) %>%
      addAwesomeMarkers(
        layerId = as.character(alt_esc$Codi_centre),
        as.numeric(alt_esc$Coordenades_GEO_X),
        as.numeric(alt_esc$Coordenades_GEO_Y),
        popup = esc_popup(alt_esc),
        popupOptions = popup_options(),
        label = as.character(alt_esc$Denominacio_completa),
        icon = get_icons(alt_esc)
      ) %>%
      addMarkers(
        lat = 41.0,
        lng = 2.1,
        icon =   icons(
          iconUrl = file.path(getwd(), "icons", "logo_icon.png"),
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
  output$school_table <- DT::renderDataTable({
    withProgress(
      DT::datatable(
        as.data.frame(clean_schools())[, school_vars] %>%
          rename_all(funs(c(new_school_names))),
        selection = "single",
        options = list(pageLength = 5,
                       stateSave = TRUE)
      )
    )
  })

  output$summary_table <- DT::renderDataTable({
    withProgress(
      DT::datatable(
        as.data.frame(df %>%
                        mutate(
                          per_quarantena = paste0(round(infected / n * 100, 2), "% (", infected, "/", n, ")")
                        )) %>%
          select(all_of(mun_vars)) %>%
          arrange(desc(epg)) %>%
          rename_all(funs(c(new_mun_names))),
        selection = "single",
        options = list(pageLength = 5,
                       stateSave = TRUE)
      )
    )  
  })


  output$docs <- renderUI({
    HTML(docs)
  })
  output$quisom <- renderUI({
    HTML(orbita_popup)
  })
  
  output$evo1 <- renderPlotly({
    fig <- plot_ly(evo, x = ~ Dia)
    fig <- fig %>% add_trace(y = ~ `Casos alumnes`, name = "Casos en alumnes", type = "scatter", mode = "lines")
    fig <- fig %>% add_trace(y = ~ `Casos professionals`, name = "Casos en personal", type = "scatter", mode = "lines")
    fig <- fig %>% add_trace(y = ~ `Alumnes confinats`, name = "Alumnes confinats", type = "scatter", mode = "lines")
    fig <- fig %>% add_trace(y = ~ `Professionals confinats`, name = "Professional confinat", type = "scatter", mode = "lines")
    fig <- fig %>% layout(title = "Casos i confinaments en alumnes i professionals",
                          yaxis = list(title = ""),
                          legend = list(x = 0.01, y = 0.99))
    fig
  })
  output$evo2 <- renderPlotly({
    fig2 <- plot_ly(evo, x = ~ Dia)
    fig2 <- fig2 %>% add_trace(y = ~ `Grups confinats`, name = "Grups confiants", type = "scatter", mode = "lines")
    fig2 <- fig2 %>% add_trace(y = ~ `Escoles amb grups confinats`, name = "CEs* amb grups confinats", type = "scatter", mode = "lines")
    fig2 <- fig2 %>% add_trace(y = ~ `Escoles tancades`, name = "CEs* tancats", type = "scatter", mode = "lines")
    fig2 <- fig2 %>% layout(title = "Confinaments i tancaments de CEs*",
                            yaxis = list(title = ""),
                            legend = list(x = 0.01, y = 0.99))
    fig2
  })
  
  
  # Actions
  
  # Schools
  prev_vals <- reactiveValues()

  observeEvent(input$school_table_rows_selected, {
    row_selected = clean_schools()[input$school_table_rows_selected,]
    proxy <- leafletProxy('mymap')
    proxy %>% 
      setView(lng=row_selected$Coordenades_GEO_X, 
              lat=row_selected$Coordenades_GEO_Y + .05, # so that the popup is correctly displayed, 
              zoom = 12) %>%
      addPopups(layerId = as.character(row_selected$Codi_centre),
        lng=row_selected$Coordenades_GEO_X, 
                lat=row_selected$Coordenades_GEO_Y,
                popup = esc_popup(row_selected), 
                options = popup_options())
        
    if(!is.null(prev_vals))
    {
      proxy %>% 
        removePopup(layerId = as.character(prev_vals$school$Codi_centre))
    }
    # set new value to reactiveVal 
    prev_vals$school <- row_selected
      
  })
  
  # Municipis
  # Schools
  # prev_mun <- reactiveVal()
  # 
  # observeEvent(input$summary_table_rows_selected, {
  #   row_selected = df[input$summary_table_rows_selected,]
  #   loc <- sf::st_bbox(row_selected$geometry)
  #   x <- (loc[1] + loc[3]) / 2
  #   y <- (loc[2] + loc[4]) / 2
  #   proxy <- leafletProxy('mymap')
  #   proxy %>% 
  #     setView(lng=x, 
  #             lat=y, 
  #             zoom = 12) %>%
  #     addPopups(layerId = row_selected$Codi_centre,
  #               lng=x, 
  #               lat=y + .05, # so that the popup is correctly displayed
  #               mun_popup(row_selected), 
  #               options = popup_options())
  #   
  #   if(!is.null(prev_mun()))
  #   {
  #     proxy %>% removePopup(layerId = prev_mun()$Codi_centre)
  #   }
  #   # set new value to reactiveVal 
  #   prev_mun(row_selected)
  #   
  # })

  # Working, but not useful
  # observeEvent(input$mymap_marker_click, {
  #   clickId <- input$mymap_marker_click$id
  #   rowId <- which(clean_schools()$Codi_centre == clickId)
  #   DT::dataTableProxy("school_table") %>%
  #     selectRows(rowId) %>%
  #     selectPage(which(input$school_table_rows_all == rowId) %/% input$school_table_state$length + 1)
  # })
  
  

  
  
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