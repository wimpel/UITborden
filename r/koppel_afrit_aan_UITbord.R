# aanname: 1 UIT bord per afrit

library(tidyverse)
library(sf)
library(leaflet)
library(leafgl)
library(mapview)
library(igraph)
library(lwgeom)
mapviewOptions(fgb = FALSE)

afritten <- readRDS("./output/afritten.rds")
uitborden <- readRDS("./output/kerngis_UITborden.rds")
alle.borden <- readRDS("./output/kerngis_borden.rds")

# afritten samenvoegen
# maak continue weglijnen
# koppel alle lijndelen welke binnen 2 meter van elkaar liggen samen in een groep
com = igraph::components(igraph::graph.adjlist(sf::st_is_within_distance(afritten, dist = 2)))

# voeg lijndelen van afritten samen op
# - wegnummer/wegnaam
# - dvk letter
# - hierboven bepaald 'membership' van lijnen die binnen 2 meter van elkaar liggen
afritten <- afritten %>%
  dplyr::mutate(groep = com$membership) %>%
  dplyr::group_by(groep, WEGNR_HMP, HECTO_LTTR) %>%
  summarise(wegnaam = paste0(unique(WEGNR_HMP), collapse = ";"),
            richting = paste0(unique(POS_TV_WOL), collapse = ";"),
            naam = paste0(unique(STT_NAAM), collapse = ";"))
# tussenresultaat 1058 afritten

# bepaal het begin;unt van elke afritlijn
afrit.startpunt <- lwgeom::st_startpoint(afritten)

# koppelen UITbord aan afrit
# afstanden UITbord tot afrit wegaslijn

# voor elk UITbord, bepaal de dichtsbijzijnde afrit
afrit.dichtbij <- afritten[sf::st_nearest_feature(uitborden, afritten), ]
# check hoevele unieke afritten we hebben (915, dus sommige afritten hebben meerdere UITborden gekoppeld gekregen)
# length(unique(afrit.dichtbij$groep)) 
#koppel afritinfo aan ieder uitbord
uitborden <- uitborden %>% cbind(sf::st_drop_geometry(afrit.dichtbij))
# voor elk UITbord, trek een lijn naar het dichtsbijzijnde punt op een afrit
lijn.uitbord.afrit <- st_nearest_points(uitborden, afrit.dichtbij, pairwise = TRUE) %>% st_as_sf()
# wat is de afstand van het UITbord naar de dichtsbijzijnde afrit?
uitborden$afstandBordNaarAfrit <- as.numeric(st_length(lijn.uitbord.afrit))
# andersom: voor elke afrit, bepaal het dichtstbijzijnde UITbord
bord.dichtbij <- uitborden[sf::st_nearest_feature(afritten, uitborden), ]
afritten <- afritten %>% cbind(sf::st_drop_geometry(bord.dichtbij))
lijn.uitbord.afrit <- st_nearest_points(afritten, bord.dichtbij, pairwise = TRUE) %>% st_as_sf()
afritten$afstandAfritNaarBord <- as.numeric(st_length(lijn.uitbord.afrit))

#zijn er afritten met meerdere UITborden?
uitborden %>% sf::st_drop_geometry() %>% 
  group_by(afritnaam = paste0(wegnaam, richting, " ", naam)) %>% 
  dplyr::summarise(aantal = n()) %>% 
  dplyr::filter(aantal > 1)
# ja dus
# wat is de afstand van het uitbord naar de afrit.
median(uitborden$afstandBordNaarAfrit)
# [1] 4.9736
# hoe is de verdeling
table(cut(uitborden$afstandBordNaarAfrit, breaks = c(0,5,10,20,50, Inf)))
# (0,5]   (5,10]  (10,20]  (20,50] (50,Inf] 
#   671      243       17       15      367 

# En zijn er UITborden met meerdere afritten?
afritten %>% sf::st_drop_geometry() %>% 
  group_by(UITbordId = globalid) %>% 
  dplyr::summarise(aantal = n()) %>% 
  dplyr::filter(aantal > 1)
# ook ja
# wat is de afstand van het uitbord naar de afrit.
median(afritten$afstandAfritNaarBord)
# [1] 4.569542
# hoe is de verdeling
table(cut(afritten$afstandAfritNaarBord, breaks = c(0,5,10,20,50, Inf)))
# (0,5]   (5,10]  (10,20]  (20,50] (50,Inf] 
#   649      219        8       17      165 

# veilige aanname: UITbord binnen 10 meter van afrit hoort bij de afrit, de rest niet





leaflet() %>%
  addProviderTiles(providers$CartoDB.Positron,
                   group = "OSM licht") %>%
  addWMSTiles( "https://service.pdok.nl/hwh/luchtfotorgb/wms/v1_0?",
               layers = "Actueel_orthoHR",
               options=WMSTileOptions(format = "image/jpeg",
                                      transparent = TRUE,
                                      maxZoom = 20) ,
               group = "PDOK luchtfoto") %>%
  #addGlPoints(data = kerngis.borden, fillColor = "magenta", popup = kerngis.borden$globalid) %>%
  addGlPoints(data = uitbord, fillColor = "blue") %>%
  # addGlPoints(data = bb01.rwsnummer, fillColor = "blue", popup = ~type) %>%
  addPolylines(data = afritten.samen[afritten.samen$afstand <= 10, ], color = "green", fillColor = 1, opacity = 1) %>%
  addPolylines(data = afritten.samen[afritten.samen$afstand > 10, ], color = "red", fillOpacity = 1, opacity = 1) %>% 
  #addGlPolylines(data = dtb.geleide, color = "yellow") %>%
  addLayersControl(
    baseGroups = c("OSM licht", "PDOK luchtfoto"),
    options = layersControlOptions(collapsed = FALSE)) 
