#!/usr/bin/env Rscript

#packages:
library(sp)
library(rgdal)

#####################################
print("Programado por Ricardo Faria")
#####################################


setwd("input/data/")

file_data <- Sys.glob(paste0("*coords*"))

coords <- read.csv(file_data[1],
                  #skip = 2,
                  #nrows=length(data) - 7,
                  header = TRUE, 
                  stringsAsFactors=FALSE,
                  #colClasses=c("Data", "Hora", "Valor", NA),
                  sep= ";"
                  #quote = "\"")
)

xy <- data.frame(X = c(coords$Coordx), Y = c(coords$Coordy))
coordinates(xy) <- c("X", "Y")
proj4string(xy) <- CRS("+proj=utm +zone=28 +ellps=intl +units=m +towgs84=-160.410,-21.066,-99.282,2.437,-17.250,-7.446,0.168 +wktext +no_defs ")  ##for example madeira Portugal - Madeira Region - Madeira, Porto Santo e Desertas - onshore" (espg:1314)

res <- spTransform(xy, CRS("+proj=longlat +datum=WGS84"))

coords$Coordx <- res@coords[,1]
coords$Coordy <- res@coords[,2]

write.csv(coords, paste0("degree_", file_data[1]), row.names = F)

setwd("../../")
