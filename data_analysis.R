#!/usr/bin/env Rscript

#packages:
#library(zoo)
#library(matrixStats)
#library(ggplot2)
library(tools)

#####################################
print("Programado por Ricardo Faria")
#####################################


setwd("input/data/")

for (i in 1:length(est_names_list)) {
      
      file_data <- Sys.glob(paste0("*", est_names_list[i], "*"))
      
      dados <- read.csv(file_data,
                        skip = 2,
                        #nrows=length(data) - 7,
                        header = TRUE, 
                        stringsAsFactors=FALSE,
                        #colClasses=c("Data", "Hora", "Valor", NA),
                        sep= "\t"
                        #quote = "\"")
      )
      
      if (file_ext(file_data) == "xls") {
            
            print("exists .xls")
            dados$Data <- as.POSIXct(paste(dados$Data, dados$Hora), format="%Y-%m-%d %H:%M:%S")
            dados$Data <- round(dados$Data, "hours") 
            
      } else if (file_ext(file_data) == "txt") {
            
            print("exists .txt")
            dados[,3] <- 0.2*dados[,3]
            dados[,1] <- as.POSIXct(paste(dados[,1], dados[,2]), format="%m/%d/%y %H:%M:%S")
            dados$Date <- round(dados$Date, "mins") 

      }
      
      dados <- dados[,c(1, 3)]
      colnames(dados) <- c("Data", "Value")
      
      #iguala os formatos de datas(puxa 1 hora para baixo para igual ao formato do as.POSIXct):
      #dados$Data <- as.POSIXct(paste(dados[1], dados[2]), format="%Y-%m-%d %H:%M:%S")
      #dados$Data <- round(dados$Data, "hours") 
      
      #dados$Hora = NULL
      #dados$X = NULL
      
      
      #definicao de intervalo de tempo:
      data_i <- times[1]
      data_f <- times[length(times)]
      #int_temp = format(seq(as.POSIXlt(data_i), as.POSIXlt(data_f), by = "hour"), "%Y-%m-%d %H:%M:%S")
      #hora solar:
      int_temp = format(seq(ISOdate(format(as.POSIXlt(data_i), "%Y"),format(as.POSIXlt(data_i), "%m"),format(as.POSIXlt(data_i), "%d"),format(as.POSIXlt(data_i), "%H"),format(as.POSIXlt(data_i), "%M"),format(as.POSIXlt(data_i), "%S")),
                            ISOdate(format(as.POSIXlt(data_f), "%Y"),format(as.POSIXlt(data_f), "%m"),format(as.POSIXlt(data_f), "%d"),format(as.POSIXlt(data_f), "%H"),format(as.POSIXlt(data_f), "%M"),format(as.POSIXlt(data_f), "%S")), "hour"), "%Y-%m-%d %H:%M:%S")
      #x = summary(int_temp)
      #int_temp = int_temp[2:x[1]]
      
      int_data <- data.frame(Data=int_temp)
      #int_temp$Data <- as.character(int_temp$Data)
      #int_data = int_data[-1,]
      int_data <- data.frame(Data=int_data)
      #int_temp <- subset(int_temp, Data >= data_i & Data <= data_f)
      #int_data$Valor = NA
      
      int_dados <- subset(dados, Data >= data_i & Data <= data_f)
      int_dados <- data.frame(int_dados)
      
      #juncao sequencia de tempo hora a hora aos medidos:
      if (file_ext(file_data) == "txt") {
            
            hour_sum <- colSums(matrix(int_dados$Value, nrow=6))
            int_dados <- data.frame(int_temp, hour_sum)
            
            merged <- data.frame(int_dados)
            
      } else if (file_ext(file_data) == "xls") {
            
            merged <- merge(int_dados, int_data, by = "Data", sort = F, fill = NA, all = T)
            
      }
      
      assign(paste0("data_", est_names_list[i]), merged)
      
      #if ( !is.null(file.exists(file_data)) ) {
      #      assign(paste("dados_", est_names_list[i], sep = ""), NA)
      #} else if (file.exists(file_data) == T) {
            
}

setwd("../../")
