#estacoes:
n <- readline(prompt = "Indique quantidade de estacoes: ")

est_vec <- c()
est_names <- c()
for (i in 1:n) {
      
      nome <- readline(prompt = paste("Nome da", i, "estacao, 4 letras: "))
      long_vec <- readline(prompt = paste("Longitude da estacao", nome, ": "))
      lat_vec <- readline(prompt = paste("Latitude da estacao", nome, ": "))
      est_vec <- c(est_vec, long_vec, lat_vec)
      est_names <- c(est_names, paste(nome, "_long", sep = ""), paste(nome, "_lat", sep = ""))
      
}

names(est_vec) = c(est_names)

est_ex <- c(-16.917, 32.671, -17.027, 32.7266)
names(est_ex) = c("FNCH_long", "FNCH_lat", "SEAG_long", "SEAG_lat")
