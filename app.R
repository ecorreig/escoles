library(dplyr)
library(ggplot2)
library(sf)
library(leaflet)
library(shiny)

df <- read.csv(file.path("data", "comarques_setmanal.csv"), sep = ";", encoding = "UTF-8")
df <- df[df$RESIDENCIA == "No", ]
df$RESIDENCIA <- NULL

df$DATA_INI <- lubridate::ymd(df$DATA_INI)
df$DATA_FI <- lubridate::ymd(df$DATA_FI)
ultim_dia <- max(df$DATA_FI)
df <- df[df$DATA_FI %in% c(ultim_dia, ultim_dia - 7), ]

cols_ <- c("IEPG_CONFIRMAT", "TAXA_CASOS_CONFIRMAT")
tend <- df[df$DATA_FI == ultim_dia, cols_] / df[df$DATA_FI == ultim_dia - 7, cols_] - 1
# A l'alta ribagorça estan molt bé!
tend$IEPG_CONFIRMAT[is.na(tend$IEPG_CONFIRMAT)] <- 0 
tend$TAXA_CASOS_CONFIRMAT[is.na(tend$TAXA_CASOS_CONFIRMAT)] <- 0
names(tend) <- c("Tendència_IEPG", "Tendència taxa casos")

abs_cols_ <- c("CASOS_CONFIRMAT", "PCR", "INGRESSOS_TOTAL", "INGRESSOS_CRITIC", "EXITUS")
abs <- df %>% group_by(NOM) %>% summarise_at(abs_cols_, sum, na.rm = TRUE)

rel_cols_ <- c("NOM", "CODI", "IEPG_CONFIRMAT", "R0_CONFIRMAT_M", "TAXA_CASOS_CONFIRMAT", "TAXA_PCR", "PERC_PCR_POSITIVES")
rel <- df[df$DATA_FI == ultim_dia, rel_cols_]

tot <- merge(abs, rel)
tot <- cbind.data.frame(tot, tend)

map <- st_read(file.path("mapes", "shapefiles_catalunya_comarcas.shp"))
tmap <- map
tmap$geometry <- NULL

tot[tot$NOM == "BAGES", abs_cols_] <- tot[tot$NOM == "BAGES", abs_cols_] + tot[tot$NOM == "MOIANÈS", abs_cols_]
tot <- tot[-which(tot$NOM == "MOIANÈS"), ]

esc <- read.csv(file.path("escoles", "totcat_nivells_junts.csv"), sep = ";", dec=",")
esc$estat <- "normal"

df <- st_as_sf(merge(tot, map, by.x = "CODI", by.y = "comarca"))

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
pal <- colorNumeric(palette = "plasma", domain = df$IEPG_CONFIRMAT, reverse = T)

lflet <- leaflet() %>%
  addProviderTiles(provider = providers$CartoDB.Positron) %>%
  setView(lat = 42, lng = 2, zoom = 8) %>%
  addPolygons(
    data = df,
    weight = 2,
    smoothFactor = 0.2,
    fillOpacity = .7,
    color = ~ pal(IEPG_CONFIRMAT)
  ) %>%
  addMarkers(
    esc$Coordenades.GEO.X,
    esc$Coordenades.GEO.Y,
    popup = as.character(esc$Denominació.completa),
    label = as.character(esc$Denominació.completa),
    icon = icones_escoles
)

r_colors <- rgb(t(col2rgb(colors()) / 255))
names(r_colors) <- colors()
ui <- fluidPage(
  leafletOutput("mymap"),
  p()
)

server <- function(input, output, session) {
  output$mymap <- renderLeaflet({lflet})
}

shinyApp(ui, server)

runGitHub( "Projecte-Orbita/escoles.git", "ecorreig")

