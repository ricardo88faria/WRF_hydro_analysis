#!/usr/bin/env Rscript

#packages:
library(raster)
#library(rts)
library(ncdf4)
library(maptools)

#limpeza ambiente e objetos:
rm(list=ls())
cat("\014")

#####################################
cat("Programado por Ricardo Faria \n
    ")
#####################################

source("matrix_rotation.R")

# palete
rgb.palette.rain <- colorRampPalette(c("snow1", "lightsteelblue1", "yellowgreen", "orange", "tomato1", "violetred4"), space = "rgb")

# madeira shapefile
proj <- CRS("+proj=longlat +datum=WGS84 +towgs84=-160.410,-21.066,-99.282,2.437,-17.250,-7.446,0.168 +wktext +no_defs ") #CRS('+proj=longlat +datum=WGS84')
land <- readShapeSpatial("input/map/PRT_adm2.shp", proj4string = proj)

land_hydro <- readShapeSpatial("input/map/rede_hydro/rede_hidr_principal.shp")
proj4string(land_hydro)=CRS("+init=epsg:3061")
land_hydro = spTransform(land_hydro,CRS("+init=epsg:4326")) 


# load data krig vs wrf
krig_20fev <- raster("ord_krig20fev/w001001.adf")
#projection(krig_20fev) <- proj
krig_20fev <- projectRaster(krig_20fev, crs = proj)

#wrf_20fev_nc <- nc_open("input/results/wrfout_LREC_hydro_d03_2010-02-20_00_00_00.nc")
#wrf_20fev_nc <- nc_open("input/results/smeso_madeira_20fev_ERA_V38/RUN_Hydro_ReSun_param_V38/wrfout_LREC_hydro_d03_2010-02-20_00_00_00.nc")
wrf_20fev_nc <- nc_open("input/results/smeso_madeira_20fev_ERA_V38/RUN_G_param_V38/wrfout_LREC_hydro_d03_2010-02-20_00_00_00.nc")
wrf_20fev <- ncvar_get(wrf_20fev_nc, "RAINNC")
wrf_20fev <- wrf_20fev[,,144]-wrf_20fev[,,1]
lat <- unique(as.vector(ncvar_get(wrf_20fev_nc, "XLAT")))
long <- unique(as.vector(ncvar_get(wrf_20fev_nc, "XLONG")))


# crop data to land
rasterOptions(timer = T, progress = "text")
krig_20fev <- crop(krig_20fev, extent(land))
krig_20fev <- mask(krig_20fev, land)

wrf_20fev_rast <- raster(mat_rot(mat_rot(mat_rot(wrf_20fev))), 
                         xmn = long[1], xmx = long[100], ymn = lat[1], ymx = lat[90], CRS("+proj=longlat +datum=WGS84"))
wrf_20fev_rast <- disaggregate(wrf_20fev_rast, fact=c(4, 4), method='bilinear')
wrf_20fev_rast <- crop(wrf_20fev_rast, extent(land))
wrf_20fev_rast <- mask(wrf_20fev_rast, land)


# plot

plot_long_krig <- seq(krig_20fev@extent[1], krig_20fev@extent[2], by = res(krig_20fev)[1])
plot_lat_krig <- seq(krig_20fev@extent[3], krig_20fev@extent[4], by = res(krig_20fev)[2])
filled.contour(plot_long_krig[1:length(plot_long_krig)-1], 
               plot_lat_krig[1:length(plot_lat_krig)-1],
               mat_rot(as.matrix(krig_20fev)), 
               xlim = range(plot_long_krig), ylim = range(plot_lat_krig),
               asp = 1, color = rgb.palette.rain, levels = seq(0, 550, 500/20),
               plot.title = title(main = as.expression(paste("Precipitação acumulada na Ilha da Madeira no dia 20 de Fev. de 2010")), xlab = 'Longitude [°]', ylab = 'Latitude [°]'),
               plot.axes = {axis(1); 
                 axis(2); 
                 grid(NULL,NULL,lty = 5, lwd = 0.5);
                 plot(land_hydro, col="blue", lwd=3, add = T);
                 plot(land, bg = "transparent", border="grey30", lwd=0.5, add = T)},
               key.title = title(main = as.expression(paste("[mm]"))))

plot_long <- seq(wrf_20fev_rast@extent[1], wrf_20fev_rast@extent[2], by = res(wrf_20fev_rast)[1])
plot_lat <- seq(wrf_20fev_rast@extent[3], wrf_20fev_rast@extent[4], by = res(wrf_20fev_rast)[2])
filled.contour(plot_long[1:length(plot_long)-1], 
               plot_lat[1:length(plot_lat)-1],
               mat_rot(as.matrix(wrf_20fev_rast)), 
               xlim = range(plot_long_krig), ylim = range(plot_lat_krig),
               asp = 1, color = rgb.palette.rain, levels = seq(0, 550, 500/20),
               plot.title = title(main = as.expression(paste("Precipitação acumulada na Ilha da Madeira no dia 20 de Fev. de 2010")), xlab = 'Longitude [°]', ylab = 'Latitude [°]'),
               plot.axes = {axis(1); 
                 axis(2); 
                 grid(NULL,NULL,lty = 5, lwd = 0.5);
                 plot(land_hydro, col="blue", lwd=3, add = T);
                 plot(land, bg = "transparent", border="grey30", lwd=0.5, add = T)},
               key.title = title(main = as.expression(paste("[mm]"))))

