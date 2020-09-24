#' Math stuff


compute_rho <- function(x) {
  # Compute rho according to biocomcmoomsm (keep forgetting the name)
  # https://biocomsc.upc.edu/en/shared/avaluacio_risc.pdf
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
  # EPG and ratio bigger than 500 is ridiculous. TODO: think about this number. Ask maybe?
  num_ <- 500 
  num_rho <- 5
  df %>% mutate(
    clean_epg = ifelse(epg > num_, num_, epg),
    clean_taxa_incidencia_14d = ifelse(taxa_incidencia_14d > num_, num_, taxa_incidencia_14d),
    clean_rho = ifelse(rho > num_rho, num_rho, rho)
  )

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


compute_probs <- function(df) {
  # How does covid affect children compared to adults? 
  # Number taken from here: https://www.nature.com/articles/s41591-020-0962-9
  # TODO: review, update
  # Update: This is not so in adolescents; where it's 1, we put it to .6 but needs review
  ratio_covid_children <- .6
  
  # Compute the probability of cases at schools
  # Total number of students (from here: https://www.diarimes.com/noticies/actualitat/catalunya/2019/09/04/el_curs_escolar_comencara_amb_581_534_alumnes_723_nous_mestres_professors_68117_3029.html)
  # TODO: maybe use 1331225 from http://ensenyament.gencat.cat/ca/departament/estadistiques/xifres-clau/?
  student_num <- 1581534
  students_per_class <- 25  # No one believes that but ok
  school_num <- 5545
  tax_num <- 10^5

  # TODO: get number of students per municipality instead of just dividing
  
  df %>% mutate(
    students_with_covid = Poblacio / sum(Poblacio) * student_num * taxa_incidencia_14d / tax_num * ratio_covid_children,
    prevalence = numcasos / Poblacio * ratio_covid_children,
    prob_one_case_class = prob_one_case_class(prevalence, students_per_class),
    prob_one_case_school = prob_one_case_school(prevalence, num_students = student_num / school_num),
    prob_closed_school = prob_closed_school(prevalence, num_students = student_num / school_num)
  )

}

prob_one_case_class <- function(prev, stud_class = 25) {
  # Function to compute the probability of one case
  1 - dpois(0, stud_class * prev)
}

prob_one_case_school <- function(prev, num_students = NULL, num_lines = NULL, num_courses = NULL, stud_class = 25) {
  if (is.null(num_students)) {
    1 - dpois(0, num_lines * num_courses * stud_class * prev)
  } else {
    1 - dpois(0, num_students * prev)
  }
}

prob_closed_school <- function(prev, num_students = NULL, num_lines = NULL, num_courses = NULL, stud_class = 25) {
  # TODO: put this together with the previous one
  
  # In principle the school is closed after 2-3 classes are affected. We assume it's 2
  if (is.null(num_students)) {
    1 - ppois(1, num_lines * num_courses * stud_class * prev)
  } else {
    1 - ppois(1, num_students * prev)
  }
}

get_course_size <- function(code) {
  default_course_size = 2
  course_sizes <- list(
    "EINF1C" = 3,
    "EINF2C" = 3,
    "EPRI" = 6,
    "ESO" = 4
    # assume the rest is 2 (TODO: update this)
  )
  
  if (code %in% names(course_sizes)) {
    return(course_sizes[[code]])
  } else {
    return(default_course_size)
  }
}

get_school_courses <- function(x) {
  code <- strsplit(x, " ", fixed = T)[[1]]
  tot <- 0
  for (cod in code) {
    tot <- tot + get_course_size(cod)
  }
  as.integer(tot)
}

get_school_size <- function(codes) {
  sapply(codes, get_school_courses)
}


compute_epi_schools <- function(esc, df) {
  # TODO: clean this
  
  default_line_num <- as.integer(2)
  default_als_per_classe <- as.integer(25)
  
  
  cols_ <- c("cursos", "linies", "als_per_classe")
  esc %>% left_join(as.data.frame(df) %>%
                       select(
                           prevalence,
                           prob_one_case_class,
                           prob_one_case_school,
                           prob_closed_school,
                           Codi
                         
                       ),
                     by = c("Codi_municipi" = "Codi")) %>% mutate(
                       als_per_classe = case_when(
                         !is.na(als_per_classe) ~ as.integer(als_per_classe),
                         TRUE ~ default_als_per_classe
                       ),
                       prob_one_case_class = case_when(
                         !is.na(als_per_classe) ~ prob_one_case_class(prevalence, als_per_classe) * 100,
                         TRUE ~ prob_one_case_class
                       ),
                       num_alumnes = as.integer(num_alumnes),
                       cursos = case_when(
                         !is.na(cursos) ~ as.integer(cursos),
                         TRUE ~ get_school_size(Estudis)
                       ),
                       linies = case_when(
                         !is.na(linies) ~ as.integer(linies),
                         TRUE ~ default_line_num
                       ) ,
                       num_alumnes = case_when(
                         !is.na(num_alumnes) ~ num_alumnes,
                         complete.cases(cursos, linies, als_per_classe) ~ cursos * linies * als_per_classe,
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


compute_percentages <- function(df, esc) {
  infected <- function(x) sum(x > 0)
  st_as_sf(esc %>% 
    group_by(Codi_municipi) %>%
    summarise(n = n(), infected = infected(Grups_en_quarantena)) %>%
    select(Codi_municipi, n, infected) %>%
    right_join(df, by = c("Codi_municipi" = "Codi")))
}

# Evolution

get_evo <- function(evo) {
  import_evo() %>% 
    mutate(
      `Casos alumnes` = round(zoo::na.approx(`Casos alumnes`)),
      `Alumnes confinats` = round(zoo::na.approx(`Alumnes confinats`)),
      `Casos professionals` = round(zoo::na.approx(`Casos professionals`)),
      `Professionals confinats` = round(zoo::na.approx(`Professionals confinats`))
    )
}

