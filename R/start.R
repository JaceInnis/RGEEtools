#' A developer tool that should be deleted with final publish
#'
#' @param path
#'
#' @return
#' @export
#'
#' @examples
start = function(path = "C:\\Users\\jacei\\anaconda3\\envs\\rgee_py"){
  rgee_environment_dir = path
  library(raster)
  library(rgdal)
  library(rgeos)
  library(gdalUtils)
  library(sp)
  library(sf)
  library(leaflet)
  library(mapview)
  library(caret)
  library(rgee)
  library(geojsonio)
  library(remotes)
  library(reticulate)
  library(devtools)
  library(googledrive)
  rgee::ee_Initialize(drive = T)
  library(tidyverse)
  library(ggplot2)
  library(lubridate)
  library(mosaic)
  library(reshape2)
}
