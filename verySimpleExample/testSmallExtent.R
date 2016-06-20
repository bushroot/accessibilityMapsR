

# Libraries
library(raster)
library(rgdal)
library(rgeos)
library(gdistance)

# Options
rasterOptions(progress = "text", timer = T, overwrite = T)
options("max.print"=200)


# ToDos:
  # Update to 16 directions
  # Add the additional distance due to the slope (geometry)
  # Add slope to cars (slower driving) 

# Change from km/h to to m/s


# Data -------------------------------------------------------------------------

load("outputs/showcase/01_inputs.rda")



# Transition -------------------------------------------------------------------
# Create an empty transition layer
trSpeed <- transition(dem, function(x){0}, directions = 16)

# Get index of adjacent cells in transition matrix
adj <- adjacent(dem, cells = 1:ncell(dem), directions = 16, pairs = T)



# DEM --------------------------------------------------------------------------

# Calculate the altitudinal differences between cells
getAltDiff <- function(x) {x[2] - x[1]}
plot(dem); text(dem, cex=0.5)
trAltDiff <- transition(dem, getAltDiff, directions = 16, symm = F) 
plot(raster(trAltDiff)); text(dem, cex=0.3)

# Get the slope (geocorrection devides altit. difference by the horiz. distance)
slope <- geoCorrection(trAltDiff) 
# trSlope[adjacencyFromTransition(trSlope)]
plot(raster(slope)); text(raster(abs(slope)), cex=0.5, digits = 1)



# LULC -------------------------------------------------------------------------

# Assign walking speed (km/h) according to the lulc type
  # file.edit("input/tz/parameters/speedLulc.csv")
speedClassesLulc <- read.csv("input/tz/parameters/speedLulc.csv")
speedClassesLulc
speedLulc <- subs(lulc, speedClassesLulc, "class", "speed")
plot(lulc); text(speedLulc, cex = 0.5, digits = 1)

# Create transition based on lulc
trLulc <- transition(x = speedLulc, 
                     transitionFunction = function(x) mean(x), 
                     directions = 16, 
                     symm = T)
plot(raster(trLulc)); text(raster(trLulc), cex = 0.5, digits = 1)

# Use Tobler's hiking function to define speed (km/h) as a function of slope
  # Instead of the a constant max speed, take the speed from the lulc layer 
trLulcSlope <- trLulc
trLulcSlope[adj] <- (trLulc[adj] + 1) /3.6 * exp(-3.5 * abs(slope[adj] + 0.05)) 
plot(raster(trLulcSlope)); text(raster(trLulcSlope), cex = 0.5, digits = 1)



# Waterways -------------------------------------------------------------------.

# Replace NA by 0 for in order to enable computation
waterways[is.na(waterways[])] <- 0

# Get the transition layer indices of the differen waterway types
adjWaterways <- adj[waterways[adj[, "to"]] == 1 | waterways[adj[, "from"]] == 1, ]

# Assign speed values to transition layer for each waterw type
trWaterways <- trSpeed
trWaterways[adjWaterways] <- 0.5 / 3.6
plot(raster(trWaterways)); text(raster(trWaterways), cex = 0.5, digits = 1)



# Roads ------------------------------------------------------------------------

# Replace NA by 0 for in order to enable computation
roads[is.na(roads[])] <- 0

# Get the adjacent cells of border cells that lead to roads
adjRoads <- adj[roads[adj[, "to"]] == 1 | roads[adj[, "from"]] == 1, ]

# Assign speed values to transition layer for each waterw type
trRoads <- trSpeed
trRoads[adjRoads] <- 60 / 3.6
plot(raster(trRoads)); text(raster(trRoads), cex = 0.5)




# Borders ----------------------------------------------------------------------

# Replace NA by 0 for in order to enable computation
borders[is.na(borders[])] <- 0

# Get the adjacent cells of border cells
# adjBorders <- adj[borders[adj[, "to"]] == 1]
adjBorders <- adj[borders[adj[, "to"]] == 1 | borders[adj[, "from"]] == 1, ]

# Assign speed values to transition layer for each waterw type
trBorders <- trSpeed



trBorders[adjBorders] <- 0
plot(raster(trBorders))



# Conductance ------------------------------------------------------------------

# Combine all transion layer to one sinle layer 
trSpeed[adj] <- trLulc[adj]  
plot(raster(trSpeed)); text(raster(trSpeed), cex = 0.5)

trSpeed[adjWaterways] <- trWaterways[adjWaterways]
plot(raster(trSpeed)); text(raster(trSpeed), cex = 0.5)

trSpeed[adjRoads] <- trRoads[adjRoads]
plot(raster(trSpeed)); text(raster(trSpeed), cex = 0.5)

trSpeed[adjBorders] <- trBorders[adjBorders]
plot(raster(trSpeed)); text(raster(trSpeed), cex = 0.5, digits = 2)

# Correct transition values
conductance	<- geoCorrection(trSpeed,	scl = FALSE)
plot(raster(conductance)); text(raster(conductance)*100, cex = 0.5, digits = 2)
plot(raster(conductance)); text(idx, cex = 0.5)



# Catchment --------------------------------------------------------------------

# Create cost-accumulation layers
accumCost <- accCost(conductance, c(353859.1, 9565067))
plot(accumCost); contour(accumCost, add = T)

# Define catchment based on maximum travel time
maxTravelTime <- 3600
catchment <- accumCost
catchment[catchment > maxTravelTime] <- NA



# Export data ------------------------------------------------------------------


