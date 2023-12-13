library(tidyverse)
library(sf)
library(leaflet)
library(leafgl)
library(mapview)
mapviewOptions(fgb = FALSE)
sf.punt <- sf::st_read("i:/brondata/dtb/20230320-shapefile/d40fz/d40fz_sym.shp",
                       query = "SELECT * FROM d40fz_sym WHERE OMSCHR IN('verkeersbord zonder kabel')") %>% 
  sf::st_transform(4326)
mapview(sf.punt)

# borden nite handig

# geleiderail
lijn.dtb <- lapply(
  list.files(path = "I:/brondata/dtb/20230320-shapefile", pattern = ".*lin\\.shp$", recursive = TRUE, full.names = TRUE),
  function(x) {
    laagnaam <- gsub("(.*)\\.shp", "\\1", basename(x))
    sqlquery = paste0("SELECT * FROM ", laagnaam, " WHERE CTE IN ('R030103', 'R030101')")
    sf::st_read(x, query = sqlquery)
  })
dtb.geleide <- dplyr::bind_rows(lijn.dtb) %>% sf::st_transform(4326)
saveRDS(dtb.geleide, "./output/dtb_geleiderail.rds")

lijn.dtb <- lapply(
  list.files(path = "I:/brondata/dtb/20230320-shapefile", pattern = ".*lin\\.shp$", recursive = TRUE, full.names = TRUE),
  function(x) {
    laagnaam <- gsub("(.*)\\.shp", "\\1", basename(x))
    sqlquery = paste0("SELECT * FROM ", laagnaam, " WHERE CTE IN ('R030103', 'R030101')")
    sf::st_read(x, query = sqlquery)
  })
dtb.geleide <- dplyr::bind_rows(lijn.dtb) %>% sf::st_transform(4326)
saveRDS(dtb.geleide, "./output/dtb_geleiderail.rds")

vlak.dtb <- lapply(
  list.files(path = "I:/brondata/dtb/20230320-shapefile", pattern = ".*reg\\.shp$", recursive = TRUE, full.names = TRUE),
  function(x) {
    laagnaam <- gsub("(.*)\\.shp", "\\1", basename(x))
    sqlquery = paste0("SELECT * FROM ", laagnaam, " WHERE CTE IN ('R030303')")
    sf::st_read(x, query = sqlquery)
  })
dtb.rimob <- dplyr::bind_rows(vlak.dtb) %>% sf::st_transform(4326)
saveRDS(dtb.geleide, "./output/dtb_rimob.rds")



#sf::st_layers(list.files(path = "I:/brondata/dtb/20230320-shapefile", pattern = ".*lin\\.shp$", recursive = TRUE, full.names = TRUE)[1])
