# Handle data

# COVID cases
import_covid <- function(start, end) {
  # TODO: filter by date already in the query
  p <- "https://analisi.transparenciacatalunya.cat/resource/jj6z-iyrp.json"
  q <- "?$where=resultatcoviddescripcio='Positiu PCR'"
  l <- paste0(p, q)
  covid <- RSocrata::read.socrata(l, stringsAsFactors = F)
  
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
  
  df
}

import_pop_data <- function() {
  pb <- readxl::read_excel("data/municipis.xlsx")
  
  # The codes from the API have 6 digits but in here only five (good job, gene).
  # We have discovered that reoving the last number, both codes match, so that's
  # what we are doing here
  pb$Codi <- substr(pb$Codi, 1, 5)
  
  pb
}

# Import school data
import_schools <- function(glink, drive) {
  if (drive) {
    googledrive::drive_download(glink, type = "csv", overwrite = T)
  }
  
  esc <- read.csv(file.path("totcat_nivells_junts.csv"), sep = ",", dec=".", encoding = "UTF-8")
  esc %>% 
    rename_all(funs(make_ascii(names(esc)))) %>% 
    mutate(Codi.municipi = as.character(Codi.municipi)) %>% 
    mutate(Codi.municipi = ifelse(nchar(Codi.municipi) < 5, paste0("0", Codi.municipi), Codi.municipi))
}

