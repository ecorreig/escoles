# Dependencies

packs <- c(
  "shiny",
  "shinydashboard",
  "leaflet",
  "lubridate",
  "dplyr",
  "sf",
  "RSocrata",
  "googledrive",
  "readxl",
  "stringi",
  "shinythemes",
  "tidyr",
  "shinycssloaders",
  "rmapshaper",
  "plotly",
  "zoo"
)

new.packages <- packs[!(packs %in% installed.packages()[,"Package"])]
if(length(new.packages)) {
  install.packages(new.packages, dependencies=T)
  print(paste0("Succesfully installed packages ", paste(new.packages, collapse = ", ")))
}

print("Done installing packages.")
