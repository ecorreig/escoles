library(lubridate)
library(dplyr)
library(tidyr)
library(leaflet)
library(shiny)
library(shinydashboard)
library(sf)

options(shiny.reactlog=TRUE) 

days_back <- 14
correction <- 3  # Data from last 3 days is no good

deploy <- T

if (deploy) {
  encoding <- "UTF-8"
} else {
  encoding <- "latin1"
}

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

jn <- pb %>% full_join(aa, by = c("Codi" = "municipicodi")) %>% 
  filter(!is.na(Població)) %>% 
  mutate(across(c(numcasos, casos_24h, rho), ~replace(., is.na(.), 0)))

num_ <- 10^5
jn <- jn %>% 
  mutate(taxa_incidencia_14d = numcasos / Població * num_, 
         taxa_casos_nous = casos_24h / Població * num_,
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

dt_df <- df %>% select(-one_of(c("geometry", "harvard")))


esc <- read.csv(file.path("escoles", "totcat_nivells_junts.csv"), sep = ";", dec=",", encoding = "UTF-8")
esc$estat <- "normal"

wdt <- 14
hgt <- 12
icones_escoles <- icons(
  iconUrl = esc %>% mutate(
    icona = case_when(
      estat == "normal" ~ "icones/escola_verda.png",
      estat == "casos" ~ "icones/escola_taronja.png",
      estat == "tancada" ~ "icones/escola_vermella.png",
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
                selected = 1)
  ), 
  dashboardBody(
    fluidRow(box(width = 12, leafletOutput(outputId = "mymap"))),
    fluidRow(box(width = 12, dataTableOutput(outputId = "summary_table"))),
    tags$style(type = "text/css", "#map {height: calc(100vh - 80px) !important;}")
  ),

  leafletOutput("mymap", height = 1000)
)

server <- function(input, output, session) {
  
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
      )
      # addMarkers(
      #   esc$Coordenades.GEO.X,
      #   esc$Coordenades.GEO.Y,
      #   popup = as.character(esc$Denominació.completa),
      #   label = as.character(esc$Denominació.completa),
      #   icon = icones_escoles
      # ) 
  })
  output$summary_table <- renderDataTable({
    DT::dataTableProxy(outputId = 'tbl') %>%
      DT::hideCols(hide = c("geometry", "harvard"))
    df
  }
  )  
}

shinyApp(ui, server)
