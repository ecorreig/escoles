library(lubridate)
library(dplyr)
library(tidyr)
library(leaflet)
library(shiny)
library(shinydashboard)
library(sf)

days_back <- 14
correction <- 3  # Data from last 3 days is no good

today <- today()
start <- today - days_back - correction - 1
week <- today - 7 - correction - 1
end <- today - correction

# TODO: filter also by date
p <- "https://analisi.transparenciacatalunya.cat/resource/jj6z-iyrp.json"
q <- "?$where=resultatcoviddescripcio='Positiu PCR'"
l <- paste0(p, q)
df <- RSocrata::read.socrata(l, stringsAsFactors = F)

df$data <- ymd(df$data)
df <- df[(df$data > start & df$data < end), ]


wt <- tidyr::pivot_wider(
  df %>% 
    mutate_at("numcasos", as.numeric) %>%
    group_by(data, municipicodi) %>% 
    summarise_at("numcasos", sum, na.rm = TRUE),
  id_cols = "municipicodi",
  names_from = "data",
  values_from = "numcasos"
) %>% filter(!is.na(municipicodi)) %>%
  mutate_all(., ~ replace(., is.na(.), 0))

# Obsolete?
acc_wt <- wt %>%  pivot_longer(-"municipicodi") %>%
  pivot_wider(names_from = municipicodi, values_from = value) %>%
  mutate_at(-1, cumsum) %>%
  pivot_longer(-"name", names_repair = c("unique")) %>%
  rename_all(funs(c("name", "code", "value"))) %>%
  pivot_wider(names_from = name, values_from = value)

compute_rho <- function(x) {
  rowSums(x[, (ncol(x) - 3):ncol(x)]) / pmax(rowSums(x[, (ncol(x) - 7):(ncol(x) - 4)]), 1)
}
rho <- 0
for (i in 1:7) {
  rho <- rho + compute_rho(wt[, 2:(ncol(wt) - i + 1)]) / 7
}
wt$rho <- rho

last <- df[(df$data > end - correction), c("municipicodi", "numcasos")] %>%
  mutate_at("numcasos", as.numeric) %>%
  group_by(municipicodi) %>%
  summarise(across(numcasos, sum, na.rm = TRUE))
names(last)[2] <- "casos_24h"

tt <- df %>% 
  mutate(across("numcasos", as.numeric)) %>% 
  group_by(municipicodi) %>% 
  summarise(across("numcasos", sum, na.rm = TRUE))

aa <- tt %>% 
  full_join(last, by = "municipicodi") %>% 
  full_join(wt[, c("municipicodi", "rho")]) %>% 
  mutate(across(c(casos_24h, rho), ~replace(., is.na(.), 0))) %>% 
  drop_na

pb <- readxl::read_excel("data/municipis.xlsx")
pb$Codi <- substr(pb$Codi, 1, 5)

# Otherwise stupid Rstudio server doesn't work - people at Rstudio are not very good at what they do...
make_ascii <- function(x) {
  stringi::stri_replace_all_fixed(
    stringi::stri_trans_general(x, "latin-ascii"), " ", "_"
  )
}

jn <- pb %>% rename_all(funs(make_ascii(names(pb)))) %>%
  full_join(aa, by = c("Codi" = "municipicodi")) %>% 
  filter(!is.na(Poblacio)) %>% 
  mutate(across(c(numcasos, casos_24h, rho), ~replace(., is.na(.), 0)))

num_ <- 10^5
jn <- jn %>% 
  mutate(taxa_incidencia_14d = numcasos / Poblacio * num_, 
         taxa_casos_nous = casos_24h / Poblacio * num_,
         epg = taxa_incidencia_14d * rho
  )

map <- st_read(file.path("mapes", "bm5mv21sh0tpm1_20200601_0.shp"))
map$CODIMUNI <- substr(map$CODIMUNI, 1, 5)

df <- st_transform(st_as_sf(jn %>% inner_join(map, by = c("Codi" = "CODIMUNI"))), "+proj=longlat +datum=WGS84") 

# Posem el risc de rebrot més gran de 500 a 500
df$epg[df$epg > 500] <- 500
# Posem la incidència de més de 500 a 500
df$taxa_incidencia_14d[df$taxa_incidencia_14d > 500] <- 500

# Calculem les guies de harvard
df$harvard <- cut(
  df$casos_24h, 
  breaks = c(-Inf, 1, 10, 25, Inf), 
  labels = c("1-verd", "2-groc", "3-taronja", "4-vermell"), 
  right = F
)

# Netegem
df$Codi <- NULL
df$Altitud <- NULL
df$Superfície <- NULL
df$NOMMUNI <- NULL
df$AREAOFI <- NULL
df$AREAPOL <- NULL
df$CODICOMAR <- NULL
df$CODIPROV <- NULL
df$VALIDDE <- NULL
df$DATAALTA <- NULL
df$rho <- round(df$rho, 2)
df$taxa_incidencia_14d <- round(df$taxa_incidencia_14d)
df$taxa_casos_nous <- round(df$taxa_casos_nous)
df$epg <- round(df$epg)

glink <- "https://docs.google.com/spreadsheets/d/1JWJUgxpY4z1zb1I65xc6paNRJbxU8bYJsEcH2X8pbPU"
googledrive::drive_download(glink, type = "csv", overwrite = T)
esc <- read.csv(file.path("totcat_nivells_junts.csv"), sep = ",", dec=".", encoding = "UTF-8")
esc <- esc %>% rename_all(funs(make_ascii(names(esc))))

wdt <- 14
hgt <- 12
icones_escoles <- icons(
  iconUrl = esc %>% mutate(
    icona = case_when(
      Estat == "Normalitat" ~ "icones/escola_verda.png",
      Estat == "Casos" ~ "icones/escola_taronja.png",
      Estat == "Tancada" ~ "icones/escola_vermella.png",
      TRUE ~ "icones/escola_negra.png"
    )
  ) %>% pull(icona),
  iconWidth = wdt, iconHeight = hgt,
  iconAnchorX = wdt/2, iconAnchorY = hgt/2,
)

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
    fluidRow(box(width = 12, dataTableOutput(outputId = "school_table"))),
    fluidRow(box(width = 12, leafletOutput(outputId = "mymap"))),
    fluidRow(box(width = 12, dataTableOutput(outputId = "summary_table"))),
    tags$style(type = "text/css", "#map {height: calc(100vh - 80px) !important;}")
  ),

  leafletOutput("mymap", height = 1000)
)

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
                 icon = icones_escoles
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

shinyApp(ui, server)

