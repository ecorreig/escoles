# Maps

ipmort_map <- function() {
  # Taken from here (very nice that these maps are open source):
  # https://www.icgc.cat/Administracio-i-empresa/Descarregues/Capes-de-geoinformacio/Base-municipal
  map <- st_read(file.path("mapes", "bm5mv21sh0tpm1_20200601_0.shp"))
  
  # Same as before with the codes
  map$CODIMUNI <- substr(map$CODIMUNI, 1, 5)
  
  # Lookout, need to choose correct encoding for leaflet
  st_transform(map, "+proj=longlat +datum=WGS84")
}

wdt <- 14
hgt <- 12
icones_escoles <- function(esc) {
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