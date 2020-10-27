# longitudinal functions

import_covid_schools <- function() {
  q <- "https://analisi.transparenciacatalunya.cat/resource/fk8v-uqfv.json"
  read.socrata(q, stringsAsFactors = F) %>%
    mutate(
      datageneracio = as.character(datageneracio)
    ) %>%
    select(-datacreacio)
}


format_wide <- function(x) {
  x %>% 
    mutate_each_(
      funs(as.numeric), 
      c("personal_positiu_acum", "altres_positiu_acum", "alumn_positiu_acum", "grup_confin", "codcentre")
    ) %>%
    mutate(
      total = personal_positiu_acum + altres_positiu_acum + alumn_positiu_acum,
      personal = personal_positiu_acum + altres_positiu_acum,
      alumnes = alumn_positiu_acum,
      
    ) %>%
    pivot_longer(
      cols = c("total", "personal", "alumnes", "grup_confin"),
      names_to = "population"
    ) %>%
    pivot_wider(
      id_cols = c("codcentre", "population"),
      names_from = datageneracio,
      values_from = value
    )
}

new_cases <- function(x) {
  tot <- readxl::read_xlsx(file.path(proj_dir, "data", "escoles_base.xlsx")) %>%
    filter(`Codi centre` != 1) %>%
    left_join(x,
              by = c("Codi centre" = "codcentre"),
              suffix = c("", "")) %>%
    mutate_at(35:ncol(.), as.numeric)
  # we have acc cases, we compute new cases
  tt <- tot
  num_ <- 35
  no_grup <- - which(tot$population == "grup_confin")
  for (i in (num_ + 1):ncol(tot)) {
    tt[no_grup, i] <- tot[no_grup, i] - apply(tot[no_grup, num_:(i - 1)], 1, max)
  }
  # sometimes the acc cases are lower in the future, i guess they are errors and we set these -1 to 0
  tt[no_grup, num_:ncol(tt)] <- apply(tt[no_grup, num_:ncol(tt)], 2, function(x) ifelse(x < 0, 0, x))
  
  tt
  
}

import_age_groups <- function() {
  q <- "https://analisi.transparenciacatalunya.cat/resource/qwj8-xpvk.json"
  read.socrata(q, stringsAsFactors = F) 
}

prepare_longitudinal <- function() {
  # define vars
  start_schools <- ymd("2020-09-14")
  today <- today()
  correction <- 3
  
  df <- format_wide(import_covid_schools())
  
  tt <- new_cases(df)
  
  wt <- clean_covid(import_covid(start_schools - 14, today - correction))
  
  df_rho <- wt %>%
    select(c(1, 15:ncol(.)))
  k = 2
  for (i in 15:ncol(wt)) {
    df_rho[, k] <- compute_rhoN(wt[, 1:i]) 
    k = k + 1
  }
  
  pb <- import_pop_data()
  
  df_age <- import_age_groups()
}

# other funcs

rho_p <- function(t, e, r, correction) {
  cr = r * correction
  (1 + cr) * t - cr * e
}
