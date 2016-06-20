

load("outputs/showcase/01_inputs.rda")


idx <- raster(dem)
idx[] <- 1:200
plot(dem); text(idx, cex = 0.5)


demx <- raster(dem)
demx[] <- 1000
demx[c(10,30,50,70,90,110,130,150,170, 190)] <- 1020
demx[c(10,30,50,70,90,110,130,150,170, 191)] <- 1070
demx[c(10,30,50,70,90,110,130,150,170, 190)] <- 1020
demx[c(11,31,51,71,91,111,131,151,171,191)] <- 1070
demx[c(12,32,52,72,92,112,132,152,172,192)] <- 1170
demx[c(13,33,53,73,93,113,133,153,173,193)] <- 1220
demx[c(14,34,54,74,94,114,134,154,174,194)] <- 1220
demx[c(15,35,55,75,95,115,135,155,175,195)] <- 1200
demx[c(16,36,56,76,96,116,136,156,176,196)] <- 1150
demx[c(17,37,57,77,97,117,137,157,177,197)] <- 1100
demx[c(18,38,58,78,98,118,138,158,178,198)] <- 1080
demx[c(19,39,59,79,99,119,139,159,179,199)] <- 1030
plot(demx)


waterwaysx <- raster(dem)
waterwaysx[c(73,72,71,70,69,68,48,28,8)] <- 1
plot(waterwaysx)


roads <- raster(dem)
roads[] <- 0
plot(roads)
roads[c(181,182,183,184,185,186,187,188,189,169,149)] <- 1


bordersx <- raster(dem)
bordersx[] <- 0
plot(bordersx)
bordersx[c(17,37,38,58,59,60)] <- 1
plot(bordersx); text(idx, cex = 0.5)


layersOut <- c("lulc", "dem", "waterways", "roads", "borders", "idx")
save(list = layersOut, file = "outputs/showcase/01_inputs.rda")



