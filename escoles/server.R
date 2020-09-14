# Server


library(shiny)
library(shinydashboard)
library(leaflet)

encoding_ <- "UTF-8"
source("calcs.R", encoding = encoding_)
source("utils.R", encoding = encoding_)

mun_popup <- function(df) {
  paste0("<h3>", df$Municipi, " (", df$Poblacio," habitants)</h3>  
         <strong> Índex de risc: ", df$epg, "</strong> 
         <p> Casos últims 14 dies: ", df$numcasos, " (", df$taxa_incidencia_14d, " casos per 100k h.) </p>
         <p>Casos últimes 24 hores: ", df$casos_24h, " (", df$taxa_casos_nous, " casos per 100k h.) </p>
         <p>Rho7: ", df$rho, "</p>
         <h5> Probabilitat d'un cas en una classe: ",  df$prob_one_case_class, "%</h5>
         <p>Probabilitat d'un cas a l'escola: ",  df$prob_one_case_school, "%</p>
         <p>Probabilitat escola tancada: ", df$prob_closed_school, "%</p>"
         )
}

esc_popup <- function(esc) {
  ifelse(!is.na(esc$num_alumnes), 
  paste0("<h3>", esc$Denominacio.completa, " (", esc$Nom.naturalesa,") </h3>
         <h2> Estat: ", esc$Estat, "</h2>
         <p> Línies: ", val_or_none(esc$linies), "</p>
         <p> Cursos: ",  val_or_none(esc$cursos), "</p>
         <p> Alumnes per classe: ",  val_or_none(esc$als_per_classe), "</p>
         <strong> Num. total d'alumnes (aprox): ", val_or_none(esc$num_alumnes), "</strong>
         <h5> Probabilitat d'un cas en una classe: ", round(esc$prob_one_case_class, 2), "%</h5>
         <p>Probabilitat d'un cas a l'escola: ",  round(esc$prob_one_case_school, 2), "%</p>
         <p>Probabilitat escola tancada: ",  round(esc$prob_closed_school, 2), "%</p>"
  ),
  paste0("<h3>", esc$Denominacio.completa, " (", esc$Nom.naturalesa,") </h3>
         <h2> Estat: ", esc$Estat, "</h2>
         <strong> No tenim el número total d'alumnes d'aquesta escola, per tant els càlculs són molt aproximats. Estem intentant fer-nos amb aquesta informació, esperem tenir-la aviat. Gràcies! </strong>
         <h5> Probabilitat d'un cas en una classe: ", round(esc$prob_one_case_class, 2), "%</h5>
         <p>Probabilitat d'un cas a l'escola: ",  round(esc$prob_one_case_school, 2), "%</p>
         <p>Probabilitat escola tancada: ",  round(esc$prob_closed_school, 2), "%</p>"
  )
  )
}

school_vars <- c("Denominacio.completa", "Nom.naturalesa", "Nom.municipi", "Estudis", "Estat")
new_school_names <- c("Denominació completa", "Naturalesa", "Municipi", "Estudis*", "Estat")
mun_vars <- c("Municipi", "Comarca", "Poblacio", "numcasos", "casos_24h", 
              "rho", "taxa_incidencia_14d", "taxa_casos_nous", "epg")
new_mun_names <- c("Municipi", "Comarca", "Població", "Casos 14 dies", "Casos 24h", "Rho 7 dies",
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
      pal <-
        colorNumeric(palette = "RdYlGn",
                     domain = df[["epg"]],
                     reverse = T)
    } else if (input$colour == 2) {
      pal <-
        colorNumeric(palette = "RdYlGn",
                     domain = df[["taxa_incidencia_14d"]],
                     reverse = T)
    } else if (input$colour == 3) {
      pal <-
        colorNumeric(palette = "RdYlGn",
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
    } else {
      vals <- NULL
      if (1 %in% input$school_status) {
        vals <- c(vals, "Normalitat")
      }
      if (2 %in% input$school_status) {
        vals <- c(vals, "Casos")
      }
      if (3 %in% input$school_status) {
        vals <- c(vals, "Tancada")
      }
      if (4 %in% input$school_status) {
        vals <- c(vals, "Desconnegut")
      }
      clean_schools <- esc[esc$Estat %in% vals | esc$Codi.centre == "1",]
    }
  })
  
  
  # Output
  output$school_table <- renderDataTable({
    as.data.frame(clean_schools())[, school_vars] %>% rename_all(funs(c(new_school_names)))
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
              zoom = 8) %>%
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
      addAwesomeMarkers(
        layerId = clean_schools()$Codi.centre,
        as.numeric(clean_schools()$Coordenades.GEO.X),
        as.numeric(clean_schools()$Coordenades.GEO.Y),
        popup = esc_popup(clean_schools()),
        label = as.character(clean_schools()$Denominacio.completa),
        icon = get_icons(clean_schools())
      )
  })
  output$summary_table <- renderDataTable({
    as.data.frame(df)[, mun_vars] %>% rename_all(funs(c(new_mun_names)))
  },
  options = list(pageLength = 5))
  
  # Actions
  observeEvent(input$mymap_marker_click, {
    event <- input$mymap_marker_click
    mis_info <- is.na(clean_schools() %>% filter(Codi.centre == event$id) %>% pull(num_alumnes))
    if (!is.null(event) & mis_info) {
      output$school_details <- renderUI({
        # tagList(
        # numericInput("line_num", h3("Número de línies"),
        #              value = 1),
        # numericInput("course_num", h3("Número de cursos"),
        #              value = 1),
        # numericInput("als_per_class", h3("Alumnes per classe"),
        #              value = 25),
        # actionButton("input_1", "Entra els valors"),
        # helpText(
        #   "Si saps la informació de l'escola durant aquest curs, podrem calcular ",
        #   "de forma més acurada les probabilitats de l'escola. ",
        #   "Omple els tres valors d'aquí sobre o el número total ",
        #   "d'alumnes aquí sota."
        # ),
        # sliderInput("student_num", h3("Número total d'alumnes"),
        #             min = 0, max = 2000, value = 300),
        # actionButton("input_2", "Entra el valor")
        # )
        helpText("-----------------")
      })
    }
  })
  # Not working:
  eventReactive(T, {
    print(output)
  })
  eventReactive(output.school_details.input_1, {
    print("input 1!!")
     
    clean_schools() %>% 
      filter(Codi.centre == event$id) %>% 
      mutate(cursos = output$school_details$course_num, 
             linies = output$school_details$line_num, 
             als_per_classe = output$school_details$als_per_class) %>%
      mutate(num_alumnes = cursos * linies * als_per_classe) %>% 
      write.csv(., "escoles_2.csv", row.names = F)
  })
  eventReactive(output.school_details.input_2, {
    print("input 2!!")
    clean_schools() %>% 
      filter(Codi.centre == event$id) %>% 
      mutate(num_alumnes = output$school_details$student_num) %>% 
      write.csv(., "escoles_2.csv", row.names = F)
  })

  
}