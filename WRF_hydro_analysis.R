#!/usr/bin/env Rscript

#packages:

library(lubridate)
library(zoo)
library(raster)
library(ncdf4)
#library(RNetCDF)
#library(rworldmap)
#library(rworldxtra)
library(maptools)
library(ggplot2)
library(plotKML)
library(plotGoogleMaps)


#limpeza ambiente e objetos:
#rm(list=ls())
#cat("\014")

#####################################
cat("Programado por Ricardo Faria \n
    ")
#####################################

t <- Sys.time()

source("stations_coords_input.R")

#create folders
#system("mkdir kmz Images GIFs graphs GoogleMaps")

#cores dos graficos
rgb.palette.rad <- colorRampPalette(c("lightcyan", "yellow2", "orange", "tomato1", "violetred4", "violetred", "purple"), space = "rgb")

#open .nc
fileNames <- Sys.glob("results/wrfout_LR*")
nc <- nc_open(fileNames)
names(nc$var)           #variav names vamos usar: 
                        #Liquid soil moisture: "SH2O" [mm^3/mm^3] ou [%]
                        #Surface runoff: "SFROFF" [mm] ou [kg m^-2 s^-1]
                        #Subsurface runoff: "UDROFF" [mm] ou [kg m^-2 s^-1]
                        #Max hourly precipitation rate: "RAINNC" [kg m^-2 s^-1]
                        #Clouds: "CLDFRA" [%]
var_names <- c("SH2O",
               "SFROFF",
               "UDROFF",
               "RAINNC",
               "CLDFRA")

#sist. de coordenadas, projecao e coordenadas (N-S, E-O)
proj <- CRS('+proj=longlat +datum=WGS84')
land <- readShapeSpatial("map/PRT_adm3.shp", proj4string = proj)

lat_min <- min(ncvar_get(nc, "XLAT")) 
lat_max <- max(ncvar_get(nc, names(nc$var)[2]))
lat <- unique(as.vector(ncvar_get(nc, "XLAT")))
lat <- as.vector(lat)
lat_index <- which.max(lat[lat<=32.6])

long_min <- min(ncvar_get(nc, "XLONG"))
long_max <- max(ncvar_get(nc, names(nc$var)[3]))
long <- unique(as.vector(ncvar_get(nc, "XLONG")))
long <- as.vector(long)
long_index <- which.max(long[long<=-17.1])

hgt <- ncvar_get(nc, "HGT")[,,1]

hour_list <- c(seq(from = 1, to = 145, by = 6))
times <- c()

max_sh2o_graph <- c()
max_sfroff_graph <- c()
max_udroff_graph <- c()
max_rainnc_graph <- c()
max_cldfra_graph <- c()

coor_sh2o <- c()
coor_sfroff <- c()
coor_udroff <- c()
coor_rainnc <- c()
coor_cldfra <- c()


#ciclo abrir ficheiros
for (i in 1:length(fileNames)){ 
      temp_nc <- nc$filename[i]
      temp_nc <- nc_open(temp_nc)
      variav_sh2o_nc <- ncvar_get(temp_nc, "SH2O", count = c(-1, -1, 1, -1)) # count primeiro nivel de profundidade do solo ~0,3m
      variav_sfroff_nc <- ncvar_get(temp_nc, "SFROFF")
      variav_udroff_nc <- ncvar_get(temp_nc, "UDROFF")
      variav_rainnc_nc <- ncvar_get(temp_nc, "RAINNC")
      variav_cldfra_nc <- ncvar_get(temp_nc, "CLDFRA", start = c(1, 1, 1, 1), count = c(-1, -1, 30, -1))
      
      start <- c(south_north = 1, west_east = 1, Time = 1)
      count <- c(west_east = 1, west_east = 1, Time = 10)
      
      #list of output dates
      times <- append(times, ncvar_get(temp_nc, names(nc$var)[1])[1])
      
      count <- 0
      coor_sh2o_appended <- c()
      coor_sfroff_appended <- c()
      coor_udroff_appended <- c()
      coor_rainnc_appended <- c()
      #ciclo para is buscar valores de todos os 10 mnts e 
      for (j in 1:144) {
            #variav_sh2o <- ncvar_get(temp_nc, "sh2o")[,,j]
            
            #vs
            variav_sh2o <- variav_sh2o_nc[,,j]      # count primeiro nivel de profundidade do solo ~0,3m
            variav_sfroff <- variav_sfroff_nc[,,j]
            variav_udroff <- variav_udroff_nc[,,j]
            variav_rainnc <- variav_rainnc_nc[,,j]
            variav_cldfra <- variav_cldfra_nc[,,,j]   #24/144*60 = 10mnts

            count <- count + 1
            
            print(paste(count, "* 10 minutos = [", count, "in 144]"))                  

            #extrair dados das coorddenadas
            n_l <- 0
            for (l in 1:length(est_ex)/2) {
                  
                  coor_sh2o_appended <- append(coor_sh2o_appended, variav_sh2o_nc[est_ex[l+n_l],est_ex[l+n_l+1],j])
                  assign(paste("coor_sh2o", names(est_ex)[l+n_l], sep = ""), coor_sh2o_appended)
                  coor_sfroff_appended <- append(coor_sfroff_appended, variav_sfroff_nc[est_ex[l+n_l],est_ex[l+n_l+1],j])
                  assign(paste("coor_sfroff", sep = ""), coor_sfroff_appended)
                  coor_udroff_appended <- append(coor_udroff_appended, variav_udroff_nc[est_ex[l+n_l],est_ex[l+n_l+1],j])
                  assign(paste("coor_udroff", sep = ""), coor_udroff_appended)
                  coor_rainnc_appended <- append(coor_rainnc_appended, variav_rainnc_nc[est_ex[l+n_l],est_ex[l+n_l+1],j])
                  assign(paste("coor_rainnc", sep = ""), coor_rainnc_appended)
                  n_l <- n_l + 1
                  
            }
            
      }
      
      
      # valores maximos para graficos
      max_sh2o_graph <- c(max_sh2o_graph, max(variav_sh2o))
      max_sfroff_graph <- c(max_sfroff_graph, max(variav_sfroff))
      max_udroff_graph <- c(max_udroff_graph, max(variav_udroff))
      max_rainnc_graph <- c(max_rainnc_graph, max(variav_rainnc))
      max_cldfra_graph <- c(max_cldfra_graph, max(variav_cldfra))
      
      #fazer lista de matrizes
      assign(paste("variav_sh2o_", as.Date(times[[i]]), sep = ""), variav_sh2o)
      assign(paste("variav_sfroff_", as.Date(times[[i]]), sep = ""), variav_sfroff)
      assign(paste("variav_udroff_", as.Date(times[[i]]), sep = ""), variav_udroff)  
      assign(paste("variav_rainnc_", as.Date(times[[i]]), sep = ""), variav_rainnc)  
      assign(paste("variav_cldfra_", as.Date(times[[i]]), sep = ""), variav_cldfra)  
      
      #fazer lista com valores nas coordenadas
      coor_sh2o <- c(coor_sh2o, coor_sh2o_appended)
      coor_sfroff <- c(coor_sfroff, coor_sfroff_appended)
      coor_udroff <- c(coor_udroff, coor_udroff_appended)
      coor_rainnc <- c(coor_rainnc, coor_rainnc_appended)

      nc_close(temp_nc)
      
}

nc_close(nc)



## Extract Ben Nevis time series
#ben = ncvar_get(nc, "rainfall_amount", start=c(218, 480, 1),
#                count=c(1, 1, -1))
#lala <- append(c(4,6,10), c(1,2,6,0))
## Plot precipitation against day of year
#plot(ben, type="h", main="Ben Nevis precipitation (1983)",
#     xlab="Day of year", ylab="Daily precipitation (mm)", col="darkblue")


x_dias = seq(1, 432, by= 1)
x_horas = seq(1, 24, by= 1)
time_series <- zoo(coor_rainnc)
#unlist

#gráfico
graph_name_png <- paste("graphs/Rad_hour_TS_", format(as.POSIXct(strptime(times[[1]], "%Y-%m-%d_%H:%M:%S")), "%Y-%m-%d"), ".png", sep = "")
png(graph_name_png, width = 5950, height = 4500, units = "px", res = 500)

plot_time_ser <- autoplot(time_series, facets = NULL) + #ggplot
      geom_line() +
      labs (title = "Radiação Solar diária na Ilha da Madeira") +
      scale_x_continuous (name = "Hora") +
      scale_y_continuous (name = "Radiação [W/m^2]")
plot(plot_time_ser)

dev.off()


graph_name_png <- paste("graphs/coor_rainnc", format(as.POSIXct(strptime(times[[1]], "%Y-%m-%d_%H:%M:%S")), "%Y-%m-%d"), ".png", sep = "")
png(graph_name_png, width = 5950, height = 4500, units = "px", res = 500)

plot_day_med <- ggplot(data.frame(coor_rainnc)) +
      geom_line(aes(x = x_dias ,y = coor_rainnc), color = "blue") +
      labs (title = "Radiação Solar diária na Ilha da Madeira") +
      scale_x_continuous (name = "Hora") +
      scale_y_continuous (name = "Radiação [W/m^2]")
plot(plot_day_med)

dev.off()


graph_name_eps <- paste("graphs/Rad_daily_", format(as.POSIXct(strptime(times[[1]], "%Y-%m-%d_%H:%M:%S")), "%Y-%m-%d"), ".pdf", sep = "")
pdf(graph_name_eps, width = 5950, height = 4500)

x = seq(1, length(times), by= 1)
plot(x = x, y = media_day, xlab = paste("Dia Juliano"), ylab = paste("Radiação [W/m^2]"), main = paste("Radiação Solar diária na Ilha da Madeira"), type = "o", col = "blue", lwd = 2)
grid()

dev.off()

graph_name_png <- paste("graphs/Rad_daily_", format(as.POSIXct(strptime(times[[1]], "%Y-%m-%d_%H:%M:%S")), "%Y-%m-%d"), ".png", sep = "")
png(graph_name_png, width = 5950, height = 4500, units = "px", res = 500)

x = seq(1, length(times), by= 1)
plot(x = x, y = media_day, xlab = paste("Dia Juliano"), ylab = paste("Radiação [W/m^2]"), main = paste("Radiação Solar diária na Ilha da Madeira"), type = "o", col = "blue", lwd = 2)
grid()
dev.off()

#equacao rotacao de matriz
matrix_rotate <- function(x)
      t(apply(x, 2, rev))

#source("map_shape_plot.R")

max_axis <- max(unlist(max_graph)) + 50

#ciclo gerar mapas e kmz
for (i in 1:length(times)) {
      
      ##filled contour grafs
      variav_name <- paste(paste("rad_", as.Date(times[[i]]), sep = ""))
      
      name_png = paste("Images/", "Rad_", as.Date(times[[i]]), ".png", sep = "")
      png(name_png, width = 5950, height = 4500, units = "px", res = 500)  #width = 7000 (width = 14000, height = 9000, units = "px", res = 1000)
      
      filled.contour(long, lat, get(variav_name), asp = 1, color = rgb.palette.rad, levels = seq(0, max_axis, 20), # nlevels = 400, #axes = F #(12), nlev=13,
                     plot.title = title(main = as.expression(paste("Radiação Solar diária na Ilha da Madeira a", as.Date(times[[i]]))), xlab = 'Longitude [°]', ylab = 'Latitude [°]'),
                     plot.axes = {axis(1); axis(2); contour(long, lat, hgt, add=TRUE, lwd=0.5, labcex=0.7, levels=c(2, seq(0, 500, 50), seq(500, 1900, 100)), drawlabels=  T, col = "grey30"); grid()},
                     key.title = title(main =  as.expression(paste("[W/m^2]"))))
      
      #plot(getMap(resolution = "high"), add = T)
      #contour(long, lat, hgt, add=TRUE, lwd=1, labcex=1, levels=0.99, drawlabels=FALSE, col="grey30")
      
      dev.off()
      
      ##kmz
      test <-  raster(matrix_rotate(matrix_rotate(matrix_rotate(get(variav_name)))), 
                      xmn = long_min, xmx = long_max, ymn = lat_min, ymx = lat_max, CRS("+proj=longlat +datum=WGS84"))   # + plot.axes={ works??????
      #proj4string(test) <- CRS("+proj=longlat +datum=WGS84") #proj
      
      setwd("kmz")
      system(paste("mkdir", paste("Rad_", as.Date(times[[i]]), sep = "")))
      setwd(paste("Rad_", as.Date(times[[i]]), sep = ""))
      
      #KML(test, file = paste("Rad_", as.Date(times[[i]]), ".kmz", sep = ""), colour = rgb.palette.rad)
      plotKML(obj=test, folder.name="RAD", file.name=paste("Rad_", as.Date(times[[i]]), ".kmz", sep = ""), colour_scale = rgb.palette.rad(400), open.kml = FALSE)
      
      setwd("../../")
      
}

#GIFs
gif_name <- paste("GIFs/", "Rad_", as.Date(times[[i]]), ".gif", sep="")

system(paste("convert -verbose -resize 30% -delay 80 -loop 0", paste("Images/", "*", sep=""), gif_name))


t <- (Sys.time() - t)

cat("Programado por Ricardo Faria \n
    Finalizado em", t, "mnts")

print(t)
