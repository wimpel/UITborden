library(tidyverse)
library(sf)
library(leaflet)
library(leafgl)
library(mapview)
mapviewOptions(fgb = FALSE)

afritten.snelweg <- readRDS("./output/afritten.rds")
geleiderail <- readRDS("./output/kerngis_geleiderail.rds")
leaflet() %>%
  addProviderTiles(providers$CartoDB.Positron,
                   group = "OSM licht") %>%
  addWMSTiles( "https://service.pdok.nl/hwh/luchtfotorgb/wms/v1_0?",
               layers = "Actueel_orthoHR",
               options=WMSTileOptions(format="image/jpeg",
                                      transparent=TRUE,
                                      maxZoom = 20) ,
               group = "PDOK luchtfoto") %>%
  #addGlPoints(data = kerngis.borden, fillColor = "magenta", popup = kerngis.borden$globalid) %>%
  # addGlPoints(data = kerngis.uit, fillColor = "blue", popup = ~type) %>%
  # addGlPoints(data = bb01.rwsnummer, fillColor = "blue", popup = ~type) %>%
  # addGlPolylines(data = afritten.snelweg, color = "red") %>% 
  addGlPolylines(data = geleiderail, color = "yellow", popup = ~globalid) %>%
  #addGlPolylines(data = dtb.geleide, color = "yellow") %>%
  addLayersControl(
    baseGroups = c("OSM licht", "PDOK luchtfoto"),
    options = layersControlOptions(collapsed = FALSE)) 

mapview::mapview(kerngis.borden[kerngis.borden$globalid == "{B4B51FEF-D9BF-4B9E-A24C-389B8EBF942B}", ])
mapview::mapview(kerngis.borden[kerngis.borden$code == "WW" & kerngis.borden$type == "ANWB", ])

leaflet() %>% addTiles() %>% addGlPolylines(data = kerngis.geleide2[1:100,], weight = 100, opacity = 1, color = "blue")
