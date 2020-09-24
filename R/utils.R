
make_ascii <- function(x) {
  # We need to set stuff to ASCII, otherwise stupid Rstudio server doesn't work - 
  # people at Rstudio are not very good at what they do...
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
  per_q <- paste0(round(df$infected / df$n * 100, 2), "% (", df$infected, "/", df$n, ")")
  paste0("<h3>", df$Municipi, " (", df$Poblacio," habitants)</h3>  
         <strong> Índex de risc: ", df$epg, "</strong> 
         <p> Casos últims 14 dies: ", df$numcasos, " (", df$taxa_incidencia_14d, " casos per 100k h.) </p>
         <p>Casos últimes 24 hores: ", df$casos_24h, " (", df$taxa_casos_nous, " casos per 100k h.) </p>
         <p>Rho7: ", df$rho, "</p>
         <p>Percentatge escoles amb grups en quarantena: ", per_q, "</p>
         <h5> Probabilitat d'un cas en una classe: ",  df$prob_one_case_class, "%</h5>
         <p>Probabilitat d'un cas a l'escola: ",  df$prob_one_case_school, "%</p>"
  )
}

esc_popup <- function(esc) {
         paste0("<h3>", esc$Denominacio_completa, " (", esc$Nom_naturalesa,") </h3>
         <h2> Estat: ", esc$Estat, "</h2>
         <p> Grups en quarantena: ", esc$Grups_en_quarantena, "</p>
         <p> Alummnes en quarantena: ", esc$ALUMN_CONFIN, "</p>
         <p> Personal en quarantena: ", esc$DOCENT_CONFIN + esc$ALTRES_CONFIN, "</p>
         <p> Alumnes positius: ", esc$ALUMN_POSITIU, "</p>
         <p> Personal positiu: ", esc$PERSONAL_POSITIU + esc$ALTRES_POSITIU, "</p>
         <h5> Probabilitat d'un cas en una classe: ", round(esc$prob_one_case_class, 2), "%</h5>
         <p>Probabilitat d'un cas a l'escola: ",  round(esc$prob_one_case_school, 2), "%</p>"
         )
}

orbita_popup <- "
<p> Aquest mapa ha estat creat pel<a target='_blank' class='po-popup' href=''http://projecteorbita.cat'> Projecte Òrbita</a>, un equip d'investigació i desenvolupament que elabora eines de detecció de necessitats específiques d'aprenentatge. </p>

<p> Aquest curs us oferim un seguiment continu de l'alumnat de la vostra escola, posant especial èmfasi en les vessats emocional i adaptatives, a més de la cognitiva, perquè pugueu fer un seguiment continu de l'estat d'ànim, la inclusió i l'aprenentatge dels infants i adolescents del vostre centre educatiu.</p>

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
  c("Denominacio_completa",
    "Nom_naturalesa",
    "Nom_municipi",
    "Estudis",
    "Estat", 
    "prob_one_case_class", 
    "prob_one_case_school")
new_school_names <-
  c("Nom",
    "Titularitat",
    "Municipi",
    "Estudis*",
    "Estat", 
    "Prob. cas classe", 
    "Prob. cas escola")
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
    "epg",
    "per_quarantena"
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
    "Risc de rebrot",
    "% escoles amb quarantenes"
  )

# from here: https://learnui.design/tools/data-color-picker.html
palette <- c(
  "#32ba1a",
  "#64ab00",
  "#839b00",
  "#9b8800",
  "#ae7400",
  "#be5c00",
  "#c93e00",
  "#cf0402",
  "#cf0402",
  "#fc0502",
  "#fc0502",
  "#cd003d",
  "#cd003d",
  "#8b004d",
  "#8b004d",
  "#460a41",
  "#460a41",
  "#12011f"
)

rev <- FALSE

correct_num <- function(col, num) {
  if (!is.factor(col)) {
    col
  } else {
    ifelse(col < num, col, num)
  }
}

analytics_tag <- function() {
"
<!-- Global site tag (gtag.js) - Google Analytics -->
<script async src='https://www.googletagmanager.com/gtag/js?id=UA-158198403-2'></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());

  gtag('config', 'UA-158198403-2');
</script>
"
}
