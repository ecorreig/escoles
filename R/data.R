
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
  path_ <- file.path(getwd(), "data", "municipis.xlsx")
  pb <- read_excel(path_)

  # The codes from the API have 6 digits but in here only five (good job, gene).
  # We have discovered that reoving the last number, both codes match, so that's
  # what we are doing here
  pb$Codi <- substr(pb$Codi, 1, 5)

  pb
}

update_data <- function() {
  # Get school covid status
  headers <- "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/85.0.4183.121 Safari/537.36"
  names(headers) <- "user-agent"
  df <- read.csv(url("https://tracacovid.akamaized.net/data.csv", headers = headers), sep = ";")
  # Get shool data
  es <- readxl::read_xlsx(file.path("data", "escoles_base.xlsx"))
  
  # Merge
  tot <-
    es %>% left_join(df,
                     by = c("Codi centre" = "CODCENTRE"),
                     suffix = c("", "")) %>%
    mutate(
      Estat = case_when(
        ESTAT == "Confinat" ~ "Tancada",
        GRUP_CONFIN > 0 ~ "Grups en quarantena",
        TRUE ~ "Normalitat"
      ),
      `Grups en quarantena` = case_when(
        is.na(GRUP_CONFIN) ~ as.integer(0),
        TRUE ~ GRUP_CONFIN
      ),
      DATAGENERACIO = lubridate::dmy_hm(DATAGENERACIO)
      
    )
  
  # Check whether data is new
  data_creacio <- lubridate::now()
  
  # Store if it's new
  files <- list.files(file.path(getwd(), "data",  "daily"))
  name <- make.names(paste0(data_creacio, ".csv"))
  
  # only save on local FIXME (ugly hack)
  if (!name %in% files & Sys.info()["sysname"] == "Windows") { 
    pa <- file.path(file.path(getwd(), "data", "daily", name))
    write.csv(tot, pa, row.names = F)
  }
  
  tot
}

# Import school data
import_schools <- function() {

  esc <- update_data()
  esc %>%  rename_all(funs(make_ascii(names(esc)))) %>%
    mutate(Codi_municipi = as.character(Codi_municipi)) %>%
    mutate(Codi_municipi = ifelse(nchar(Codi_municipi) < 5, paste0("0", Codi_municipi), Codi_municipi))
}

update_schools_DEPRECATED <- function() {
  # Warning: only run locally
  # DEPRECRATED
  source("R/secret.R", encoding = "UTF-8")

  pa_ <- file.path(getwd(), "data")
  drive_auth(mail(), use_oob = T)
  drive_download(glink(), path = file.path(pa_, "escoles.xlsx"), type = "xlsx", overwrite = T)
}

# evo

import_evo <- function() {
  pa_ <- file.path("data", "evo.csv") 
  read.csv(pa_, encoding = "UTF-8") %>% 
    mutate(
      Dia = lubridate::ymd_hms(Dia)
    )
}

update_evo <- function(df) {
  
  # Careful, this updates records from same datetime (TODO: think about this)
  evo <- import_evo() %>% add_row(
    Dia = lubridate::now(),
    `Casos.alumnes` = sum(df$ALUMN_POSITIU, na.rm = T),
    `Alumnes.confinats` = sum(df$ALUMN_CONFIN, na.rm = T),
    `Casos.professionals` = sum(df$PERSONAL_POSITIU + df$ALTRES_POSITIU, na.rm = T),
    `Professionals.confinats` = sum(df$DOCENT_CONFIN + df$ALTRES_CONFIN, na.rm = T),
    `Grups.confinats` = sum(df$GRUP_CONFIN, na.rm = T),
    `Escoles.amb.grups.confinats` = sum(df$GRUP_CONFIN > 0, na.rm = T),
    `Escoles.tancades` = sum(df$ESTAT == "Confinat", na.rm = T)
  )
  
  evo <- evo[!duplicated(evo[, -1]), ]
  
  write.csv(evo, file.path("data", "evo.csv"), row.names = F)
  evo
  
}
