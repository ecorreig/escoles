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

# Comute the probability of cases at schools
# Total number of students (from here: https://www.diarimes.com/noticies/actualitat/catalunya/2019/09/04/el_curs_escolar_comencara_amb_581_534_alumnes_723_nous_mestres_professors_68117_3029.html)
# TODO: maybe use 1331225 from http://ensenyament.gencat.cat/ca/departament/estadistiques/xifres-clau/?
student_num <- 1581534
students_per_class <- 20  # No one believes that but ok
students_per_line <- 150
school_num <- 5545
tax_num <- 10^5
  
# How does covid affect children compared to adults? 
# Number taken from here: https://www.nature.com/articles/s41591-020-0962-9
# TODO: review, update
ratio_covid_children <- .4

compute_probs <- function(df) {

  # TODO: get number of students per municipality instead of just dividing
  
  df %>% mutate(
    students_with_covid = Poblacio / sum(Poblacio) * student_num * taxa_incidencia_14d / tax_num * ratio_covid_children,
    prevalence = numcasos / Poblacio,
    prob_one_case_class = prob_one_case_class(prevalence, students_per_class),
    prob_one_case_school = prob_one_case_school(prevalence, num_students = student_num / school_num),
    prob_closed_school = prob_closed_school(prevalence, num_students = student_num / school_num)
  )

}


# Function to compute the probability of one case

prob_one_case_class <- function(prev, stud_class = students_per_class) {
  1 - dpois(0, stud_class * prev)
}

prob_one_case_school <- function(prev, num_students = NULL, num_lines = NULL, num_courses = NULL, stud_class = students_per_class) {
  if (is.null(num_students)) {
    1 - dpois(0, num_lines * num_courses * stud_class * prev)
  } else {
    1 - dpois(0, num_students * prev)
  }
}

prob_closed_school <- function(prev, num_students = NULL, num_lines = NULL, num_courses = NULL, stud_class = students_per_class) {
  # TODO: put this together with the previous one
  
  # In principle the school is closed after 2-3 classes are affected. We assume it's 2
  if (is.null(num_students)) {
    1 - ppois(1, num_lines * num_courses * stud_class * prev)
  } else {
    1 - ppois(1, num_students * prev)
  }
}


compute_epi_schools <- function(esc, df) {
  # TODO: clean this
  cols_ <- c("cursos", "linies", "als_per_classe")
  esc %>% left_join(as.data.frame(df) %>%
                       select(
                           prevalence,
                           prob_one_case_class,
                           prob_one_case_school,
                           prob_closed_school,
                           Codi
                         
                       ),
                     by = c("Codi.municipi" = "Codi")) %>% mutate(
                       prob_one_case_class = case_when(
                         !is.na(als_per_classe) ~ prob_one_case_class(prevalence, als_per_classe) * 100,
                         TRUE ~ prob_one_case_class
                       ),
                       num_alumnes = as.integer(num_alumnes),
                       cursos = as.integer(cursos),
                       linies = as.integer(linies),
                       als_per_classe = as.integer(als_per_classe),
                       num_alumnes = case_when(
                         !is.na(num_alumnes) ~ num_alumnes,
                         complete.cases(esc %>% select(cursos, linies, als_per_classe)) ~ cursos * linies * als_per_classe,
                         TRUE ~ NA_integer_
                       ),
                       prob_one_case_school = case_when(
                         !is.na(num_alumnes) ~ prob_one_case_school(prevalence, num_alumnes) * 100,
                         TRUE ~ prob_one_case_school
                       ),
                       prob_closed_school = case_when(
                         !is.na(num_alumnes) ~ prob_closed_school(prevalence, num_alumnes) * 100,
                         TRUE ~ prob_closed_school
                       )
                     ) 
}



