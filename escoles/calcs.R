# Math stuff

# Compute rho according to biocomcmoomsm (keep forgetting the name)
# https://biocomsc.upc.edu/en/shared/avaluacio_risc.pdf
compute_rho <- function(x) {
  rowSums(x[, (ncol(x) - 3):ncol(x)]) / pmax(rowSums(x[, (ncol(x) - 7):(ncol(x) - 4)]), 1)
}

compute_rhoN <- function(wt, N = 7) {
  # This function needs to be more robust on wt (FIXME)
  rho <- 0
  for (i in 1:N) {
    rho <- rho + compute_rho(wt[, 2:(ncol(wt) - i + 1)]) / N
  }
  rho
}

compute_epi <- function(jn, num) {
  jn %>% 
    mutate(taxa_incidencia_14d = numcasos / Poblacio * num, 
           taxa_casos_nous = casos_24h / Poblacio * num,
           epg = taxa_incidencia_14d * rho
    )
}

clean_vals <- function(df) {
  # EPG and ratio bigger than 500 is ridiculous
  df$epg[df$epg > 500] <- 500
  df$taxa_incidencia_14d[df$taxa_incidencia_14d > 500] <- 500
  
  df
}

compute_harvard <- function(x) {
  # From here: https://globalepidemics.org/wp-content/uploads/2020/07/pandemic_resilient_schools_briefing_72020.pdf
  cut(
    x, 
    breaks = c(-Inf, 1, 10, 25, Inf), 
    labels = c("1-verd", "2-groc", "3-taronja", "4-vermell"), 
    right = F
  )
}