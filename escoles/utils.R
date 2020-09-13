# Utils

# We need to set stuff to ASCII, otherwise stupid Rstudio server doesn't work - 
# people at Rstudio are not very good at what they do...
make_ascii <- function(x) {
  stringi::stri_replace_all_fixed(
    stringi::stri_trans_general(x, "latin-ascii"), " ", "_"
  )
}

format_per <- function(x) {
  round(x * 100, 2)
}

val_or_none <- function(x) {
  ifelse(is.na(x), "--", x)
}
