# Bacs à marées - La Rochelle
## Mise en pratique supplémentaire : découverte du géocodage et de la cartographie sous R

# Import packages et données
library(tidyverse)
library(tidygeocoder)
library(leaflet)
bacs_marees <- read_csv("https://opendata.agglo-larochelle.fr/d4c/api/records/2.0/downloadfile/format=csv&resource_id=d1c51784-09df-4cbf-9e74-457fe6651845&use_labels_for_header=true&user_defined_fields=true")

# Obtenir l'adresse à partir de longitude / latitude
long_lat_bacs <- bacs_marees[1:100,] |> 
  reverse_geocode(lat = latitude, long = longitude, method = 'osm', full_results = TRUE)
long_lat_bacs2 <- long_lat_bacs |> 
  select(libelle, house_number, road, postcode, ville, longitude, latitude)

# Cartographie des bacs
leaflet(long_lat_bacs2) |> 
  addTiles() |> 
  setView(lng = 3, lat = 47, zoom = 4.8) |> 
  addMarkers(lng = long_lat_bacs2$longitude, lat = long_lat_bacs2$latitude, 
             label = long_lat_bacs2$libelle, clusterOptions = markerClusterOptions())
