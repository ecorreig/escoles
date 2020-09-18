#' Handle data

#' @importFrom googledrive drive_auth drive_download
#' @importFrom RSocrata read.socrata
#' @importFrom readxl read_excel
#' @importFrom tidyr pivot_wider drop_na
#' @import dplyr


import_covid <- function(start, end) {
  # Import COVID cases from API
  # TODO: filter by date already in the query
  p <- "https://analisi.transparenciacatalunya.cat/resource/jj6z-iyrp.json"
  q <- "?$where=resultatcoviddescripcio='Positiu PCR'"
  l <- paste0(p, q)
  covid <- read.socrata(l, stringsAsFactors = F)
  
  covid$data <- ymd(covid$data)
  covid <- covid[(covid$data > start & covid$data < end), ]
  
  covid
}

clean_covid <- function(covid) {
  tidyr::pivot_wider(
    covid %>% 
      mutate_at("numcasos", as.numeric) %>%
      group_by(data, municipicodi) %>% 
      summarise_at("numcasos", sum, na.rm = TRUE),
    id_cols = "municipicodi",
    names_from = "data",
    values_from = "numcasos"
  ) %>% filter(!is.na(municipicodi)) %>%
    mutate_all(., ~ replace(., is.na(.), 0))
}

reformat_covid <- function(wt) {
  # Obsolete?
  wt %>%  pivot_longer(-"municipicodi") %>%
    pivot_wider(names_from = municipicodi, values_from = value) %>%
    mutate_at(-1, cumsum) %>%
    pivot_longer(-"name", names_repair = c("unique")) %>%
    rename_all(funs(c("name", "code", "value"))) %>%
    pivot_wider(names_from = name, values_from = value)
}

get_24h_cases <- function(covid, end) {
  covid[(covid$data > end), c("municipicodi", "numcasos")] %>%
    mutate_at("numcasos", as.numeric) %>%
    group_by(municipicodi) %>%
    summarise(across(numcasos, sum, na.rm = TRUE)) %>%
    rename("casos_24h" = "numcasos")
}

merge_covid <- function(covid, last, wt) {
  covid %>% 
    mutate(across("numcasos", as.numeric)) %>% 
    group_by(municipicodi) %>% 
    summarise(across("numcasos", sum, na.rm = TRUE)) %>% 
    full_join(last, by = "municipicodi") %>% 
    full_join(wt[, c("municipicodi", "rho")]) %>% 
    mutate(across(c(casos_24h, rho), ~replace(., is.na(.), 0))) %>% 
    drop_na
}

merge_pob_covid <- function(pb, covid) {
  pb %>% rename_all(funs(make_ascii(names(pb)))) %>%
    full_join(covid, by = c("Codi" = "municipicodi")) %>% 
    filter(!is.na(Poblacio)) %>% 
    mutate(across(c(numcasos, casos_24h, rho), ~replace(., is.na(.), 0)))
}

format_outputs <- function(df) {
  df$rho <- round(df$rho, 2)
  df$taxa_incidencia_14d <- round(df$taxa_incidencia_14d)
  df$taxa_casos_nous <- round(df$taxa_casos_nous)
  df$epg <- round(df$epg)
  df$prob_one_case_class <- format_per(df$prob_one_case_class)
  df$prob_one_case_school <- format_per(df$prob_one_case_school)
  df$prob_closed_school <- format_per(df$prob_closed_school)
  
  df
}

import_pop_data <- function() {
  path_ <- system.file("extdata", "municipis.xlsx", package = "EscolesCovid", mustWork = T)
  print(path_)
  pb <- read_excel(path_)
  
  # The codes from the API have 6 digits but in here only five (good job, gene).
  # We have discovered that reoving the last number, both codes match, so that's
  # what we are doing here
  pb$Codi <- substr(pb$Codi, 1, 5)
  
  pb
}

# Import school data
import_schools <- function(glink, drive) {
  
  if (drive) {
    drive_auth(mail(), use_oob = T)
    drive_download(glink, type = "csv", overwrite = T)
  }
  
  pa_ <- system.file("extdata", "totcat_nivells_junts.csv", package = "EscolesCovid", mustWork = T)
  esc <- read.csv(pa_, sep = ",", dec=".", encoding = "UTF-8")
  esc %>% 
    rename_all(funs(make_ascii(names(esc)))) %>% 
    mutate(Codi.municipi = as.character(Codi.municipi)) %>% 
    mutate(Codi.municipi = ifelse(nchar(Codi.municipi) < 5, paste0("0", Codi.municipi), Codi.municipi))
}

