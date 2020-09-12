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
pb <- readxl::read_excel("data/municipis.xlsx")

# The codes from the API have 6 digits but in here only five (good job, gene).
# We have discovered that reoving the last number, both codes match, so that's
# what we are doing here
pb$Codi <- substr(pb$Codi, 1, 5)

# Put population and covid data together
jn <- merge_pob_covid(pob, covid)

# Compute incidence, new cases and EPG every 100.000 people
jn <- compute_epi(jn, num = 10^5)

# Maps

map <- ipmort_map()

# Now, finally, put everything together
df <- st_as_sf(jn %>% inner_join(map, by = c("Codi" = "CODIMUNI")))

# Cut values that are too big to make sense
df <- clean_vals(df)

# Compute values of Hardvard guidelines
df <- df %>% mutate(harvard = cut(casos_24, 
                                  breaks = c(-Inf, 1, 10, 25, Inf), 
                                  labels = c("1-verd", "2-groc", "3-taronja", "4-vermell"), 
                                  right = F))
df$harvard <- compute_harvard(df$casos_24h) 

# Some more cleaning and formatting for nicer output
df <- format_outputs(df)

# Import school data
esc <- import_schools(glink)

# The rest is done at server.R and ui.R

# Do the work
shinyApp(ui, server)

