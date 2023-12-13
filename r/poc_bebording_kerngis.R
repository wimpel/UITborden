library(tidyverse)
library(sf)
library(leaflet)
library(leafgl)
#devtools::install_github("r-spatial/leafgl")
library(mapview)
mapviewOptions(fgb = FALSE)
kerngis.borden <- dplyr::bind_rows(
  lapply(list.files("i:/brondata/kerngis_droog/droog", 
                    pattern = ".*\\.gdb$", 
                    full.names = TRUE),
         function(x) {
           data <- sf::st_read(dsn = x, layer = "pWegmeubilair")
           names(data) <- tolower(names(data))
           st_geometry(data) <- "shape"
           #return(data %>% dplyr::filter(grepl("BB0[12]", type)) %>% st_transform(4326))
           return(data %>% st_transform(4326))
         }))

# borden met BB01 in type en/of rwsnummer
kerngis.uit <- kerngis.borden %>% dplyr::filter(grepl("B[BM]01", type, ignore.case = TRUE) | 
                                                  grepl("B[BM]01", rwsnummer, ignore.case  = TRUE))

# # test
# bb01.rwsnummer <- kerngis.borden %>% 
#   dplyr::filter(!grepl("B[BM]01", type)) %>%
#   dplyr::filter(grepl("B[BM]01", rwsnummer, ignore.case  = TRUE))
# 
# # levert alleen OWN data op
# # uitbord.rwsnummer <- kerngis.borden %>% 
# #   dplyr::filter(!grepl("B[BM]01", type)) %>%
# #   dplyr::filter(grepl("uit-bord|uitbord", rwsnummer, ignore.case  = TRUE))
# 
# # geen relevante matches
# # afrit.rwsnummer <- kerngis.borden %>% 
# #   dplyr::filter(!grepl("B[BM]01", type)) %>%
# #   dplyr::filter(grepl("afrit", rwsnummer, ignore.case  = TRUE))

#mapview::mapview(kerngis.uit)
# /test

saveRDS(kerngis.borden, "./output/kerngis_borden.rds")
saveRDS(kerngis.uit, "./output/kerngis_UITborden.rds")

kerngis.geleide <- dplyr::bind_rows(
  lapply(list.files("i:/brondata/kerngis_droog/droog", 
                    pattern = ".*\\.gdb$", 
                    full.names = TRUE),
         function(x) {
           data <- sf::st_read(dsn = x, layer = "lGeleideconstructie")
           names(data) <- tolower(names(data))
           st_geometry(data) <- "shape"
           #return(data %>% dplyr::filter(grepl("BB0[12]", type)) %>% st_transform(4326))
           return(data %>% st_transform(4326))
         }))

kerngis.geleide <- kerngis.geleide %>% 
  sf::st_zm(drop = TRUE) %>% 
  sf::st_cast(to = "LINESTRING")
unique(st_geometry_type(test))
# drop lines with length <0.1
kerngis.geleide <- kerngis.geleide[as.numeric(st_length(kerngis.geleide)) > 0.1,]
saveRDS(kerngis.geleide, "./output/kerngis_geleiderail.rds")


#names(st_geometry(test)) = NULL
leaflet() %>% addTiles() %>% addPolylines(data = test) #addGlPolylines(data = test[1:100,])
leaflet() %>% addTiles() %>% addGlPolylines(data = kern)

names(st_geometry(test))



str(afritten.snelweg)
str(test)
kerngis.geleide2 <- kerngis.geleide %>% sf::st_cast("LINESTRING") %>% st_as_sf()

str(kerngis.geleide %>% st_zm(drop = TRUE))

mapview(kerngis.geleide2)

mapview(kerngis.geleide[1:100,])

list.files("i:/brondata/kerngis_droog/droog", 
           pattern = ".*\\.gdb$", 
           full.names = TRUE)
testfile <- "i:/brondata/kerngis_droog/droog/ON_KGD.gdb"
sf::st_layers(testfile)

st_geometry_type(test)
lGeleideconstructie
