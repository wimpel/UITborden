library(sf)
library(tidyverse)
library(mapview)
mapviewOptions(fgb = FALSE)
# inladen a en c afritten van rijkswegen nwb
afritten.nwb <- sf::st_read("i:/brondata/nwb/01-12-2023/Wegvakken/Wegvakken.shp",
                            query = "SELECT * FROM wegvakken WHERE WEGBEHSRT IN ('R') AND HECTO_LTTR IN ('a', 'c')") %>%
  sf::st_transform(4326)
# inladen weggeg wegcategorie en filteren op wegvakken van autosnelwegen
autosnelwegen.weggeg <- sf::st_read("i:/brondata/weggeg/wegvak-01-12-2023/01-12-2023/Wegcat formeel/wegcat_formeel.shp") %>%
  dplyr::filter(OMSCHR %in% "Autosnelweg")
# toevoegen wegcategorie aan nwb en filteren
afritten.snelweg <- afritten.nwb %>%
  dplyr::filter(WVK_ID %in% autosnelwegen.weggeg$WVK_ID)
# view
mapview::mapview(autosnelwegen.weggeg)
mapview::mapview(afritten.snelweg)
# opslaan
saveRDS(afritten.snelweg, "./output/afritten.rds")
