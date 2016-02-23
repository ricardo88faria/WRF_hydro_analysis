#!/usr/bin/env Rscript

#packages:

library(lubridate)
library(zoo)
library(reshape2)
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
rm(list=ls())
cat("\014")

#####################################
cat("Programado por Ricardo Faria \n
    ")
#####################################

t <- Sys.time()

#create folders
#system("mkdir kmz Images GIFs graphs GoogleMaps")

#cores dos graficos
rgb.palette.rad <- colorRampPalette(c("lightcyan", "yellow2", "orange", "tomato1", "violetred4", "violetred", "purple"), space = "rgb")
rgb.palette.rain <- colorRampPalette(c("snow1", "lightsteelblue1", "yellowgreen", "orange", "tomato1", "violetred4"), space = "rgb")


#open .nc
fileNames <- Sys.glob("results/wrfout_LR*")
nc <- nc_open(fileNames)
names(nc$var)           
#variav names vamos usar: 
#Liquid soil moisture: "SH2O" [mm^3/mm^3] ou [%]
#Surface runoff: "SFROFF" [mm] ou [kg m^-2 s^-1]
#Subsurface runoff: "UDROFF" [mm] ou [kg m^-2 s^-1]
#Max hourly precipitation rate: "RAINNC" [kg m^-2 s^-1]
#Clouds: "CLDFRA" [%]

units_name <- c("[mm^3/mm^3]",
                "[kg m^-2 s^-1]",
                "[kg m^-2 s^-1]",
                "[mm]")

var_names <- c("sh2o",
               "sfroff",
               "udroff",
               "rainnc")

#sist. de coordenadas, projecao e coordenadas (N-S, E-O)
proj <- CRS('+proj=longlat +datum=WGS84')
land <- readShapeSpatial("map/PRT_adm3.shp", proj4string = proj)

#topography from ncfile
hgt <- ncvar_get(nc, "HGT")[,,1]

lat_min <- min(ncvar_get(nc, "XLAT")) 
lat_max <- max(ncvar_get(nc, names(nc$var)[2]))
lat <- unique(as.vector(ncvar_get(nc, "XLAT")))

long_min <- min(ncvar_get(nc, "XLONG"))
long_max <- max(ncvar_get(nc, names(nc$var)[3]))
long <- unique(as.vector(ncvar_get(nc, "XLONG")))

#coords transformation
#source("stations_coords_input.R")
est_vec <- c(-16.917, 32.671, -17.027, 32.7266)
names(est_vec) <- c("FNCH_long", "FNCH_lat", "SEAG_long", "SEAG_lat")
est_names_list <- c("FNCH", "SEAG")

n_l <- 0
lat_index <- c()
long_index <- c()
for (l in 1:length(est_names_list)) {  #est_vec[l+n_l],est_ex[l+n_l+1]
      
      lat_index_temp <- 0
      lat <- as.vector(lat)
      lat_index_temp <- which.max(lat[lat <= est_vec[l+n_l+1]])
      lat_index <- append(lat_index, lat_index_temp)
      
      long_index_temp <- 0
      long <- as.vector(long)
      long_index_temp <- which.max(long[long <= est_vec[l+n_l]])
      long_index <- c(long_index, long_index_temp)
      
      n_l <- n_l + 1
      
}

#time 144 spacements
hour_list <- c(seq(from = 1, to = 145, by = 6))
seq_i <- c(seq(from = 1, to = 145-6, by = 6))
seq_f <- c(seq(from = 6, to = 145, by = 6))
interv_min <- 24/length(nc$dim$Time$vals)*60
times <- c()

max_sh2o_graph <- c()
max_sfroff_graph <- c()
max_udroff_graph <- c()
max_rainnc_graph <- c()

coor_sh2o <- c()
coor_sfroff <- c()
coor_udroff <- c()
coor_rainnc <- c()

SH2O_hd <- 0
SH2O_hd_dataf <- data.frame(row.names = seq(1, 24, by=1))

for (i in 1:length(est_names_list)) {
      
      assign(paste("coor_sh2o_f_", est_names_list[i], sep = ""), c())
      assign(paste("coor_sfroff_f_", est_names_list[i], sep = ""), c())
      assign(paste("coor_udroff_f_", est_names_list[i], sep = ""), c())
      assign(paste("coor_rainnc_f_", est_names_list[i], sep = ""), c())
      
}

#ciclo abrir ficheiros
for (i in 1:length(fileNames)){ 
      temp_nc <- nc$filename[i]
      temp_nc <- nc_open(temp_nc)
      variav_sh2o_nc <- ncvar_get(temp_nc, "SH2O", count = c(-1, -1, 1, -1)) # count primeiro nivel de profundidade do solo ~0,3m
      variav_sfroff_nc <- ncvar_get(temp_nc, "SFROFF")
      variav_udroff_nc <- ncvar_get(temp_nc, "UDROFF")
      variav_rainnc_nc <- ncvar_get(temp_nc, "RAINNC")
      #variav_cldfra_nc <- ncvar_get(temp_nc, "CLDFRA", start = c(1, 1, 1, 1), count = c(-1, -1, 30, -1))
      
      start <- c(south_north = 1, west_east = 1, Time = 1)
      count <- c(west_east = 1, west_east = 1, Time = 10)
      
      #list of output dates
      times <- c(times, ncvar_get(temp_nc, names(nc$var)[1])[1])   #times <- ncvar_get(temp_nc, names(nc$var)[1])[1]
      data <- ncvar_get(temp_nc, names(nc$var)[1])[1]
      
      for (i in 1:length(est_names_list)) {
            
            assign(paste("coor_sh2o_", est_names_list[i], sep = ""), c())
            assign(paste("coor_sfroff_", est_names_list[i], sep = ""), c())
            assign(paste("coor_udroff_", est_names_list[i], sep = ""), c())
            assign(paste("coor_rainnc_", est_names_list[i], sep = ""), c())
            
      }
      variav_sh2o <- 0
      variav_sfroff <- 0
      variav_udroff <- 0
      variav_rainnc <- 0
      count <- 0
      #ciclo para is buscar valores de todos os 10 mnts e 
      for (j in 1:length(temp_nc$dim$Time$vals)) {
            #variav_sh2o <- ncvar_get(temp_nc, "sh2o")[,,j]
            
            #vs
            variav_sh2o <- variav_sh2o + variav_sh2o_nc[,,j]      # count primeiro nivel de profundidade do solo ~0,3m
            variav_sfroff <- variav_sfroff + variav_sfroff_nc[,,j]
            variav_udroff <- variav_udroff + variav_udroff_nc[,,j]
            variav_rainnc <- variav_rainnc + variav_rainnc_nc[,,j]
            
            count <- count + 1
            
            print(paste(count, "* 10 minutos = [", count, "in 144]"))                  
            
            #extrair dados das coorddenadas
            n_l <- 0
            for (l in 1:length(est_names_list)) {
                  
                  coor_sh2o_appended <- c()
                  coor_sfroff_appended <- c()
                  coor_udroff_appended <- c()
                  coor_rainnc_appended <- c()
                  
                  coor_sh2o_appended <- append(coor_sh2o_appended, variav_sh2o_nc[long_index[l],lat_index[l],j])
                  assign(paste("coor_sh2o_", est_names_list[l], sep = ""), c(get(paste("coor_sh2o_", est_names_list[l], sep = "")), coor_sh2o_appended))
                  coor_sfroff_appended <- append(coor_sfroff_appended, variav_sfroff_nc[long_index[l],lat_index[l],j])
                  assign(paste("coor_sfroff_", est_names_list[l], sep = ""), c(get(paste("coor_sfroff_", est_names_list[l], sep = "")), coor_sfroff_appended))
                  coor_udroff_appended <- append(coor_udroff_appended, variav_udroff_nc[long_index[l],lat_index[l],j])
                  assign(paste("coor_udroff_", est_names_list[l], sep = ""), c(get(paste("coor_udroff_", est_names_list[l], sep = "")), coor_udroff_appended))
                  coor_rainnc_appended <- append(coor_rainnc_appended, variav_rainnc_nc[long_index[l],lat_index[l],j])
                  assign(paste("coor_rainnc_", est_names_list[l], sep = ""), c(get(paste("coor_rainnc_", est_names_list[l], sep = "")), coor_rainnc_appended))
                  
                  n_l <- n_l + 1
                  
            }
            
      }
      
      #media diaria
      variav_sh2o <- variav_sh2o/count
      variav_sfroff <- variav_sfroff/count
      variav_udroff <- variav_udroff/count
      variav_rainnc <- variav_rainnc/count
      
      
      # valores maximos para graficos
      max_sh2o_graph <- c(max_sh2o_graph, max(variav_sh2o))
      max_sfroff_graph <- c(max_sfroff_graph, max(variav_sfroff))
      max_udroff_graph <- c(max_udroff_graph, max(variav_udroff))
      max_rainnc_graph <- c(max_rainnc_graph, max(variav_rainnc))
      
      #fazer lista de matrizes
      assign(paste("variav_sh2o_", as.Date(data), sep = ""), variav_sh2o)
      assign(paste("variav_sfroff_", as.Date(data), sep = ""), variav_sfroff)
      assign(paste("variav_udroff_", as.Date(data), sep = ""), variav_udroff)  
      assign(paste("variav_rainnc_", as.Date(data), sep = ""), variav_rainnc)  
      
      #fazer lista com valores nas coordenadas
      for (l in 1:length(est_names_list)) {
            
            assign(paste("coor_sh2o_f_", est_names_list[l], sep = ""), c(get(paste("coor_sh2o_f_", est_names_list[l], sep = "")), get(paste("coor_sh2o_", est_names_list[l], sep = ""))))
            assign(paste("coor_sfroff_f_", est_names_list[l], sep = ""), c(get(paste("coor_sfroff_f_", est_names_list[l], sep = "")), get(paste("coor_sfroff_", est_names_list[l], sep = ""))))
            assign(paste("coor_udroff_f_", est_names_list[l], sep = ""), c(get(paste("coor_udroff_f_", est_names_list[l], sep = "")), get(paste("coor_udroff_", est_names_list[l], sep = ""))))
            assign(paste("coor_rainnc_f_", est_names_list[l], sep = ""), c(get(paste("coor_rainnc_f_", est_names_list[l], sep = "")), get(paste("coor_rainnc_", est_names_list[l], sep = ""))))
            
            #assign(paste("coor_sh2o_f_", est_names_list[l], sep = ""), do.call(rbind, list(get(paste("coor_sh2o_", est_names_list[l], sep = "")))))
            
      }
      
      #coor_sh2o <- c(coor_sh2o, coor_sh2o_appended)
      #coor_sfroff <- c(coor_sfroff, coor_sfroff_appended)
      #coor_udroff <- c(coor_udroff, coor_udroff_appended)
      #coor_rainnc <- c(coor_rainnc, coor_rainnc_appended)
      
      nc_close(temp_nc)
      
}

nc_close(nc)

#fazer vector de datas inicial ate final
start <- as.POSIXct(format(as.POSIXct(strptime(times[1], "%Y-%m-%d_%H:%M:%S")), "%Y-%m-%d"))
interval_sec <- 60*interv_min
end <- start + as.difftime(length(times), units="days")
x_axis <- seq(from=start, by=interval_sec, to=end)
x_axis <- x_axis[-1]

#para ggplot
for (i in 1:length(est_names_list)) {
      
      for (j in 1:length(var_names)) {
            
            assign(paste("ts_data_", var_names[j], "_", est_names_list[i], sep = ""), data.frame(Data = x_axis, var_name = get(paste("coor_", var_names[j], "_f_", est_names_list[i], sep = ""))))
            
      }
      
}

#para ggplot 2 ou mais variaveis
for (j in 1:length(var_names)) {
      
      testo <- data.frame(Data = x_axis)
      
      for (i in 1:length(est_names_list)) {
            
            testo$"temp" <- get(paste("coor_", var_names[j], "_f_", est_names_list[i], sep = ""))
            colnames(testo)[length(testo)] <- c(paste(est_names_list[i]))
            
      }
      
      assign(paste("coor_", "f_", var_names[j], sep = ""), melt(testo, id="Data"))
      
}

#gráficos
for (i in 1:length(var_names)) {
      
      graph_name_png <- paste("graphs/coor_", var_names[i],"_", format(as.POSIXct(strptime(times[[1]], "%Y-%m-%d_%H:%M:%S")), "%Y-%m-%d"), ".png", sep = "")
      png(graph_name_png, width = 5950, height = 4500, units = "px", res = 500)
      
      graph <- ggplot(data=get(paste("coor_", "f_", var_names[i], sep = "")), aes(x=Data, y=value, colour=variable)) +
            geom_line()
      plot(graph)
      
      dev.off()
      
}


for (i in 1:length(est_names_list)) {
      
      for (j in 1:length(var_names)) {
            
            graph_name_png <- paste("graphs/coor_",est_names_list[i], "_" , var_names[j],"_", format(as.POSIXct(strptime(times[[1]], "%Y-%m-%d_%H:%M:%S")), "%Y-%m-%d"), ".png", sep = "")
            png(graph_name_png, width = 5950, height = 4500, units = "px", res = 500)
            
            variav <- get(paste("ts_data_", var_names[j], "_", est_names_list[i], sep = ""))
            #var_names <- paste(var_names[i])
            graph <- ggplot(variav) +
                  geom_line(aes(x = Data, y = var_name), color = "blue") +
                  labs (title = paste("Constante", var_names[j])) +
                  scale_x_datetime(name = "Data") +   #name = "Data"
                  scale_y_continuous(name = var_names[j])
            plot(graph)
            
            dev.off()
            
      }
      
}


#equacao rotacao de matriz
matrix_rotate <- function(x)
      t(apply(x, 2, rev))

#source("map_shape_plot.R")

max_axis <- max(unlist(max_graph)) + 50

#ciclo gerar mapas e kmz
for (i in 1:length(times)) {
      
      for (j in 1:length(var_names)) {
            
            ##filled contour grafs
            variav_name <- paste("variav_", var_names[j], "_", as.Date(times[i]), sep = "")
            max_axis <- max(get(paste("max_", var_names[j], "_graph", sep = "")))
            levl <- max_axis/20
            
            name_png = paste("Images/", variav_name, ".png", sep = "")
            png(name_png, width = 5950, height = 4500, units = "px", res = 500)  #width = 7000 (width = 14000, height = 9000, units = "px", res = 1000)
            
            filled.contour(long, lat, get(variav_name), asp = 1, color = rgb.palette.rain, levels = seq(0, max_axis, levl), # nlevels = 400, #axes = F #(12), nlev=13,
                           plot.title = title(main = as.expression(paste("Média diária da variável", var_names[j], as.Date(times[i]))), xlab = 'Longitude [°]', ylab = 'Latitude [°]'),
                           plot.axes = {axis(1); axis(2); plot(land, bg = "transparent", border="grey30", lwd=0.5, add = T); grid()},
                           key.title = title(main =  as.expression(paste(units_name[j]))))
            
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
}

#GIFs
gif_name <- paste("GIFs/", "Rad_", as.Date(times[[i]]), ".gif", sep="")

system(paste("convert -verbose -resize 30% -delay 80 -loop 0", paste("Images/", "*", sep=""), gif_name))


t <- (Sys.time() - t)

cat("Programado por Ricardo Faria \n
    Finalizado em", t, "mnts")

print(t)
