# Evolution plots

evo_plot_1 <- function(evo) {
  fig <- plot_ly(evo, x = ~ Dia)
  fig <- fig %>% add_trace(y = ~ `Casos.alumnes`, name = "Casos en alumnes", type = "scatter", mode = "lines")
  fig <- fig %>% add_trace(y = ~ `Casos.professionals`, name = "Casos en personal", type = "scatter", mode = "lines")
  fig <- fig %>% add_trace(y = ~ `Alumnes.confinats`, name = "Alumnes confinats", type = "scatter", mode = "lines")
  fig <- fig %>% add_trace(y = ~ `Professionals.confinats`, name = "Professional confinat", type = "scatter", mode = "lines")
  fig <- fig %>% layout(title = "Alumnes i professionals",
                        yaxis = list(title = ""),
                        legend = list(x = 0.01, y = 0.99))
  fig
}

evo_plot_2 <- function(evo) {
  fig2 <- plot_ly(evo, x = ~ Dia)
  fig2 <- fig2 %>% add_trace(y = ~ `Grups.confinats`, name = "Grups confiants", type = "scatter", mode = "lines")
  fig2 <- fig2 %>% add_trace(y = ~ `Escoles.amb.grups.confinats`, name = "CEs* amb grups confinats", type = "scatter", mode = "lines")
  fig2 <- fig2 %>% add_trace(y = ~ `Escoles.tancades`, name = "CEs* tancats", type = "scatter", mode = "lines")
  fig2 <- fig2 %>% layout(title = "Centres educatius",
                          yaxis = list(title = ""),
                          legend = list(x = 0.01, y = 0.99))
  fig2
}
