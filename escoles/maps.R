# Maps

library(fontawesome)

import_map <- function() {
  # Taken from here (very nice that these maps are open source):
  # https://www.icgc.cat/Administracio-i-empresa/Descarregues/Capes-de-geoinformacio/Base-municipal
  map <- st_read(file.path("mapes", "bm5mv21sh0tpm1_20200601_0.shp"))
  
  # Same as before with the codes
  map$CODIMUNI <- substr(map$CODIMUNI, 1, 5)
  
  # Lookout, need to choose correct encoding for leaflet
  st_transform(map, "+proj=longlat +datum=WGS84")
}


get_icons_OBS <- function(esc) {
  wdt <- 14
  hgt <- 12
  icons(
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
}

icon_ <- "school"
icon_set <- leaflet::awesomeIconList(
  
  normal = leaflet::makeAwesomeIcon(icon=icon_, markerColor = "green", iconColor = "white", library = "fa"),
  cases = leaflet::makeAwesomeIcon(icon=icon_, markerColor = "orage", iconColor = "white", library = "fa"),
  closed = leaflet::makeAwesomeIcon(icon=icon_, markerColor = "red", iconColor = "white", library = "fa"),
  unknown = leaflet::makeAwesomeIcon(icon=icon_, markerColor = "black", iconColor = "white", library = "fa")
)

get_icons <- function(esc) {
  return (
    leaflet::makeAwesomeIcon(
      text = fa("school"),
      iconColor = "black",
      markerColor = esc %>% mutate(
        color = case_when(
          Estat == "Normalitat" ~ "green",
          Estat == "Casos" ~ "orange",
          Estat == "Tancada" ~ "red",
          TRUE ~ "black"
        )
      ) %>% pull(color)
    )
  )
}
