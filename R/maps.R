#' Maps
#' @export
#' 
#' @importFrom sf st_read st_transform
#' @import fontawesome


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

get_icons <- function(esc) {
  size <- 20
    # Rest of icons
    leaflet::makeAwesomeIcon(
      text = fa("school"),
      iconColor = "black",
      markerColor = esc %>% mutate(
        color = case_when(
          Codi.centre == "1" ~ "blue",
          Estat == "Normalitat" ~ "green",
          Estat == "Casos" ~ "orange",
          Estat == "Tancada" ~ "red",
          TRUE ~ "black"
        )
      ) %>% pull(color)
    )
 }

get_icons___ <- function(esc) {
  size <- 20
    icons(
      iconUrl = "icones/logo_icon.png",
      iconWidth = size,
      iconHeight = size,
      iconAnchorX = size / 2,
      iconAnchorY = size / 2
    )
}
