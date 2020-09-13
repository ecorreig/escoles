encoding_ <- "UTF-8"
options(encoding = encoding_)

source("ui.R", encoding = encoding_)
source("server.R", encoding = encoding_)


shinyApp(ui, server)
