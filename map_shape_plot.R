#plot com shapespacial
image(long, lat, matrix(hgt, length(long), length(lat)), asp=1)
plot(land, add = T)
#ou
r <- raster(nrows=length(lat), ncols=length(long), 
            xmn=long_min, xmx=long_max,
            ymn=lat_min ,ymx=lat_max)

#rot_hgt <- matrix_rotate(matrix_rotate(matrix_rotate(hgt)))
#r <- setValues(r, rot_hgt)

#r <-  raster(matrix_rotate(matrix_rotate(matrix_rotate(hgt))), 
#                xmn = long_min, xmx = long_max, ymn = lat_min, ymx = lat_max, CRS("+proj=longlat +datum=WGS84"))   # + plot.axes={ works??????

r <- setValues(r, matrix_rotate(matrix_rotate(matrix_rotate(hgt))))
#plot(r, asp=1)
#plot(land, add = T, asp=1)
bb <- crop(r, land)
r_clipped <- mask(bb, land)

r_clipped <- mask(r, land)
plot(r_clipped)
image(r_clipped, asp=1)
