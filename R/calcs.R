# Do all the computations and generate nice dataframes

#' @importFrom lubridate today ymd
#' @importFrom dplyr %>%
#' @importFrom sf st_as_sf


get_covid_data <- function() {
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
  format_outputs(df)
}

get_school_data <- function(df) {

  # Import school data
  esc <- import_schools()
  # Add epi data to the school dataframe for the popups
  compute_epi_schools(esc, df)
}
