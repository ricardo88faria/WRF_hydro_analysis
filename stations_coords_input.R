#estacoes:
n <- readline(prompt = "Indique quantidade de estacoes: ")

est_vec <- c()
est_names <- c()
est_names_list <- c()
for (i in 1:n) {
      
      nome <- readline(prompt = paste("Nome da", i, "estacao, 4 letras: "))
      est_names_list <- append(nome_list, nome)
      long_vec <- readline(prompt = paste("Longitude da estacao", nome, ": "))
      lat_vec <- readline(prompt = paste("Latitude da estacao", nome, ": "))
      est_vec <- c(est_vec, long_vec, lat_vec)
      est_names <- c(est_names, paste(nome, "_long", sep = ""), paste(nome, "_lat", sep = ""))
      
}

names(est_vec) = c(est_names)
