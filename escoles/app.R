library(lubridate)
library(dplyr)
library(tidyr)
library(leaflet)
library(shiny)
library(shinydashboard)
library(sf)

encoding_ <- "UTF-8"

source("server.R", encoding = encoding_)
source("ui.R", encoding = encoding_)
source("data.R", encoding = encoding_)
source("utils.R", encoding = encoding_)
source("calcs.R", encoding = encoding_)
# Server keys and stuff; this is gitignored, go get your own ;-)
source("secret.R", encoding = encoding_)

# Settings

days_back <- 14
correction <- 3  # Data from last 3 days is no good

today <- today()
start <- today - days_back - correction - 1
week <- today - 7 - correction - 1
end <- today - correction

# Import data

# Import cases from gene api
covid <- import_covid(start, end)

# Clean them
wt <- clean_covid(covid)

# Compute rho
wt$rho <- compute_rhoN(wt, N = 7)

# Get cases from last 24h
last <- get_24h_cases(covid)

# Get all COVID info together
covid <- merge_covid(covid, last wt)

# Populational data
pb <- import_pop_data()

# Put population and covid data together
jn <- merge_pob_covid(pob, covid)

# Compute incidence, new cases and EPG every 100.000 people
jn <- compute_epi(jn, num = 10^5)

# Map
map <- import_map()

# Now, finally, put everything together
df <- st_as_sf(jn %>% inner_join(map, by = c("Codi" = "CODIMUNI")))

# Cut values that are too big to make sense
df <- clean_vals(df)

# Compute values of Hardvard guidelines
df$harvard <- compute_harvard(df$casos_24h) 

# Some more cleaning and formatting for nicer output
df <- format_outputs(df)

# Import school data
esc <- import_schools(glink)

# The rest is done at server.R and ui.R

# Do the work
shinyApp(ui, server)

