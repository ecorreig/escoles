# Do all the computations and generate nice dataframes

library(lubridate)
library(dplyr)
library(tidyr)
library(sf)

encoding_ <- "UTF-8"
source("data.R", encoding = encoding_)
source("utils.R", encoding = encoding_)
source("calc_funcs.R", encoding = encoding_)
source("maps.R", encoding = encoding_)

# Server keys and stuff; this is gitignored, go get your own ;-)
source("secret.R", encoding = encoding_)

# Settings

days_back <- 14
correction <- 3  # Data from last 3 days is no good

download_drive_file <- F


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
last <- get_24h_cases(covid, end - correction)

# Get all COVID info together
covid <- merge_covid(covid, last, wt)

# Populational data
pb <- import_pop_data()

# Put population and covid data together
jn <- merge_pob_covid(pb, covid)

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

# Compute several other indicators
# TODO: put together
df <- compute_probs(df)


# Some more cleaning and formatting for nicer output
df <- format_outputs(df)

# Import school data
esc <- import_schools(glink, drive = T)
# Add epi data to the school dataframe for the popups
esc <- compute_epi_schools(esc, df)


icones_escoles <- get_icons(esc)

# TODO: move somewhere
school_vars <- c("Denominacio.completa", "Nom.naturalesa", "Nom.municipi", "Nom.localitat", "Estat")
mun_vars <- c("Municipi", "Comarca", "Poblacio", "numcasos", "casos_24h", 
              "rho", "taxa_incidencia_14d", "taxa_casos_nous", "epg", "prob_one_case_class",
              "prob_one_case_school", "prob_closed_school")
new_names <- c("Municipi", "Comarca", "Població", "Casos 14 dies", "Casos 24h", "Rho 7 dies",
               "Incidència 14 dies", "Taxa 24h", "Risc de rebrot", "Prob. cas classe",
               "Prob. cas escola", "Prob. escola tancada")