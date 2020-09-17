#' Maps
#' 
#' @importFrom sf st_read st_transform
#' @import fontawesome


import_map <- function() {
  # Taken from here (very nice that these maps are open source):
  # https://www.icgc.cat/Administracio-i-empresa/Descarregues/Capes-de-geoinformacio/Base-municipal
  map <- st_read(system.file("extdata", "bm5mv21sh0tpm1_20200601_0.shp", package = "EscolesCovid", mustWork = T))
  
  # Same as before with the codes
  map$CODIMUNI <- substr(map$CODIMUNI, 1, 5)
  
  # Lookout, need to choose correct encoding for leaflet
  st_transform(map, "+proj=longlat +datum=WGS84")
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

