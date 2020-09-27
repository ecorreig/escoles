
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
  per_q_old <- ifelse(
    !is.na(df$n), 
    paste0(round(df$infected / df$n * 100, 2), "% (", df$infected, "/", df$n, ")"), 
    "Cap centre educatiu"
  )
  per_q <- ifelse(
    !is.na(df$n), 
    paste0(df$infected, " de ", df$n, " CEs amb confinaments (", round(df$infected / df$n * 100, 2), "%)"), 
    "Cap centre educatiu"
  ) 
  paste0("<div class='popup'>
  <h3>", df$Municipi, " (", df$Poblacio," hab.)</h3>
  <div class='indicators'>
  <h4>Índex de risc: <strong>", df$epg, "</strong> </h4>
  <p>&rho;<sub>7</sub>: ", df$rho, "</p>
  <h4><strong>", per_q, "</strong></h4>
  </div>
<strong>Casos acumulats</strong>
<ul>
  <li>14 dies: ", df$numcasos, " (", df$taxa_incidencia_14d, " per 100k h.)</li>
  <li>24 hores: ", df$casos_24h, " (", df$taxa_casos_nous, " per 100k h.)</li>
</ul>
<br>
<strong>Probabilitats de mínim un cas:</strong>
<ul>
  <li>En una classe: ", df$prob_one_case_class, "%</li> 
  <li>En una escola: ",  df$prob_one_case_school, "%</li>
</ul>
</div>"
  )
}

esc_popup <- function(esc) {
         paste0("
         <div class='popup'>
         <h3>", esc$Denominacio_completa, " (", esc$Nom_naturalesa,") </h3>
         <h2> Estat: <strong>", esc$Estat, "</strong></h2>
         <strong>Quarantenes:</strong>
            <ul>
              <li>Grups: ", esc$Grups_en_quarantena, "</li> 
              <li>Alumnes: ",   esc$ALUMN_CONFIN, "</li>
              <li>Personal: ",   esc$DOCENT_CONFIN  + esc$ALTRES_CONFIN, "</li>
            </ul>
          <strong>Positius:</strong>
            <ul>
              <li>Alumnes: ",   esc$ALUMN_POSITIU, "</li>
              <li>Personal: ",   esc$PERSONAL_POSITIU  + esc$ALTRES_POSITIU, "</li>
            </ul>
            <strong>Probabilitats de mínim un cas:</strong>
            <ul>
              <li>En una classe: ", round(esc$prob_one_case_class, 2), "</li> 
              <li>En una escola: ",   round(esc$prob_one_case_school, 2), "</li>
            </ul>
                </div>"
         )
}

orbita_popup <- "
<p> Aquest mapa ha estat creat pel<a target='_blank' class='po-popup' href=''http://projecteorbita.cat'> Projecte Òrbita</a>, un equip d'investigació i desenvolupament que elabora eines de detecció de necessitats específiques d'aprenentatge. </p>

<p> Aquest curs us oferim a escoles i instituts un seguiment continu de l'alumnat del centre, posant especial èmfasi en les vessants emocional i adaptativa, a més de la cognitiva, perquè pugueu monitoritzar l'estat d'ànim, la inclusió i l'aprenentatge dels infants i adolescents del vostre centre educatiu.</p>

<p>Si us interessa el que fem i voleu que ens reunim amb la vostra escola o institut per presentar-vos el projecte, escriviu-nos a info@projecteorbita.cat. </p>

<p>Esperem que us sigui d'utilitat!</p>
<strong>Equip Òrbita </strong><br>
<a target='_blank' href='http://projecteorbita.cat'> projecteorbita.cat </a>
"

popup_options <- function() {
  popupOptions(
    closeButton="Tanca"
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
    "per_num",
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
    "% CEs amb quarantenes",
    "Info CEs amb quarantenes"
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

link_logo <- function() {
  "https://www.projecteorbita.cat/wp-content/uploads/2020/02/logo_orbita_700x250-2.png"
}
