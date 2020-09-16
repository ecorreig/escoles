#' Utils
#' @importFrom stringi stri_replace_all_fixed stri_trans_general
#' @importFrom leaflet popupOptions


# We need to set stuff to ASCII, otherwise stupid Rstudio server doesn't work - 
# people at Rstudio are not very good at what they do...
make_ascii <- function(x) {
  stri_replace_all_fixed(
    stri_trans_general(x, "latin-ascii"), " ", "_"
  )
}

format_per <- function(x) {
  round(x * 100, 2)
}

val_or_none <- function(x) {
  ifelse(is.na(x), "--", x)
}

mun_popup <- function(df) {
  paste0("<h3>", df$Municipi, " (", df$Poblacio," habitants)</h3>  
         <strong> Índex de risc: ", df$epg, "</strong> 
         <p> Casos últims 14 dies: ", df$numcasos, " (", df$taxa_incidencia_14d, " casos per 100k h.) </p>
         <p>Casos últimes 24 hores: ", df$casos_24h, " (", df$taxa_casos_nous, " casos per 100k h.) </p>
         <p>Rho7: ", df$rho, "</p>
         <h5> Probabilitat d'un cas en una classe: ",  df$prob_one_case_class, "%</h5>
         <p>Probabilitat d'un cas a l'escola: ",  df$prob_one_case_school, "%</p>
         <p>Probabilitat escola tancada: ", df$prob_closed_school, "%</p>"
  )
}

esc_popup <- function(esc) {
  ifelse(!is.na(esc$num_alumnes), 
         paste0("<h3>", esc$Denominacio.completa, " (", esc$Nom.naturalesa,") </h3>
         <h2> Estat: ", esc$Estat, "</h2>
         <p> Línies: ", val_or_none(esc$linies), "</p>
         <p> Cursos: ",  val_or_none(esc$cursos), "</p>
         <p> Alumnes per classe: ",  val_or_none(esc$als_per_classe), "</p>
         <strong> Num. total d'alumnes (aprox): ", val_or_none(esc$num_alumnes), "</strong>
         <h5> Probabilitat d'un cas en una classe: ", round(esc$prob_one_case_class, 2), "%</h5>
         <p>Probabilitat d'un cas a l'escola: ",  round(esc$prob_one_case_school, 2), "%</p>
         <p>Probabilitat escola tancada: ",  round(esc$prob_closed_school, 2), "%</p>"
         ),
         paste0("<h3>", esc$Denominacio.completa, " (", esc$Nom.naturalesa,") </h3>
         <h2> Estat: ", esc$Estat, "</h2>
         <strong> No tenim el número total d'alumnes d'aquesta escola, per tant els càlculs són molt aproximats. Estem intentant fer-nos amb aquesta informació, esperem tenir-la aviat. Gràcies! </strong>
         <h5> Probabilitat d'un cas en una classe: ", round(esc$prob_one_case_class, 2), "%</h5>
         <p>Probabilitat d'un cas a l'escola: ",  round(esc$prob_one_case_school, 2), "%</p>
         <p>Probabilitat escola tancada: ",  round(esc$prob_closed_school, 2), "%</p>"
         )
  )
}

orbita_popup <- "
<p> Aquest mapa ha estat creat pel<a target='_blank' class='po-popup' href=''http://projecteorbita.cat'> Projecte Òrbita</a>, un equip d'investigació i desenvolupament que elabora eines de detecció i intervenció de dificultats d'aprenentatge. </p>

<p>Si us interessa el què fem i voleu que vinguem a la vostra escola a presentar el projecte, escriviu-nos a info@projecteorbita.cat. </p>

<p>Esperem que us sigui d'utilitat!</p>
<strong>Equip Òrbita </strong><br>
<a target='_blank' href='http://projecteorbita.cat'> projecteorbita.cat </a>
"

popup_options <- function() {
  popupOptions(
    style = list(
      "box-shadow" = "3px 3px rgba(0,0,0,0.25)",
      "padding" = "10px"
    )
  )
} 

school_vars <-
  c("Denominacio.completa",
    "Nom.naturalesa",
    "Nom.municipi",
    "Estudis",
    "Estat")
new_school_names <-
  c("Denominació completa",
    "Naturalesa",
    "Municipi",
    "Estudis*",
    "Estat")
mun_vars <-
  c(
    "Municipi",
    "Comarca",
    "Poblacio",
    "numcasos",
    "casos_24h",
    "rho",
    "taxa_incidencia_14d",
    "taxa_casos_nous",
    "epg"
  )
new_mun_names <-
  c(
    "Municipi",
    "Comarca",
    "Població",
    "Casos 14 dies",
    "Casos 24h",
    "Rho 7 dies",
    "Incidència 14 dies",
    "Taxa 24h",
    "Risc de rebrot"
  )

# from here: https://learnui.design/tools/data-color-picker.html
palette <- c("#32ba1a",
             "#64ab00",
             "#839b00",
             "#9b8800",
             "#ae7400",
             "#be5c00",
             "#c93e00",
             "#cf0402")
rev <- FALSE

