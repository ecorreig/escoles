#' Maps
#' 
#' @importFrom sf st_read st_transform


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

