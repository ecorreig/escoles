# Utils

# We need to set stuff to ASCII, otherwise stupid Rstudio server doesn't work - 
# people at Rstudio are not very good at what they do...
make_ascii <- function(x) {
  stringi::stri_replace_all_fixed(
    stringi::stri_trans_general(x, "latin-ascii"), " ", "_"
  )
}
