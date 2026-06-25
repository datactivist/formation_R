## Manipulations de données pour la formation R - La Rochelle, 2026


#### APRÈS-MIDI ####


#---- Exécution des manips du matin

# Importer
library(tidyverse)
data <- read_delim("https://public.opendatasoft.com/api/explore/v2.1/catalog/datasets/demographyref-france-prenoms-departement-millesime/exports/csv?lang=fr&refine=birth_year%3A%221900%22&facet=facet(name%3D%22birth_year%22%2C%20disjunctive%3Dtrue)&timezone=Europe%2FBerlin&use_labels=true&delimiter=%3B", delim = ";")

# Renommer
data <- data |> rename(annee_naissance = `Année de naissance`,
                       code_departement = `Code Officiel Département`,
                   	   nom_departement = `Nom Officiel Département`,
                   	   nb_naissances = `Nombre de naissances`)

# Grouper
group_data <- data |> summarise(naissances_sexe = sum(nb_naissances), .by = Sexe)



#---- Visualisation

# data
ggplot(group_data)

# aes
ggplot(group_data, 
       aes(x = naissances_sexe, y = Sexe))

# geom
ggplot(group_data, 
       aes(x = naissances_sexe, y = Sexe)) +
    geom_col() 

# autres paramètres aes
ggplot(group_data, 
       aes(x = naissances_sexe, y = Sexe, fill = Sexe)) +
    geom_col(width = .3)

# labs
ggplot(group_data, 
       aes(x = naissances_sexe, y = Sexe, fill = Sexe)) +
    geom_col(width = .3) +
    labs(x = "Nombre de naissances", 
         y = "Sexe de l'enfant", 
         title = "Nombre de naissances par sexe en 1900")

# theme
ggplot(group_data, 
       aes(x = naissances_sexe, y = Sexe, fill = Sexe)) +
    geom_col(width = .3) +
    labs(x = "Nombre de naissances", 
         y = "Sexe de l'enfant", 
         title = "Nombre de naissances par sexe en 1900") +
    theme_classic()



#---- Cartographie


library(leaflet) #install.packages("leaflet")

# création d'une carte
leaflet() 

# ajout d'un fond de carte
leaflet() |> 
  addTiles() 
    
# ajout d'un élément spatial
    #marqueur
leaflet() |> 
  addTiles() |> 
  addMarkers(lng = -3.7, lat = 40.4)
    #cercle fixe
leaflet() |> 
  addTiles() |> 
  addCircles(lng = -3.7, lat = 40.4)
    #cercle de 500m autour d'un point
leaflet() |> 
  addTiles() |> 
  addCircleMarkers(lng = -3.7, lat = 40.4)

    #polygone
#librairies nécessaires
library(osmdata) #install.packages("osmdata")
library(sf) #install.packages("sf")
# récupération des contours via OSM
madrid_osm <- opq(bbox = "Madrid, Spain") |> 
    add_osm_feature(key = "boundary", value = "administrative") |> 
    add_osm_feature(key = "admin_level", value = "8") |> 
    osmdata_sf()
# mise en forme des données
madrid_boundary <- madrid_osm$osm_multipolygons |> 
    st_make_valid()
# cartographie
leaflet() |> 
    addTiles() |> 
    addPolygons(data = madrid_boundary)

# personnalisation des paramètres
leaflet() |> 
  addTiles() |> 
  addCircleMarkers(lng = -3.7, lat = 40.4, radius = 50, 
                   color = "black", opacity = 0.8,
                   fillColor = "red", fillOpacity = 0.4)


#---- Exercices finaux


### Exercice n°1 : cartographies des places de stationnement

# Import des données
data <- read_csv("https://opendata.agglo-larochelle.fr/d4c/api/records/2.0/downloadfile/format=csv&resource_id=c42ead3c-828b-4bbc-9c44-fb26ec5968d1&use_labels_for_header=true&user_defined_fields=true")

# Préparation des données
prep_data <- data |> 
    mutate(percent_places_dispo = round(nb_places_disponibles / nb_places * 100, 1))

# Cartographie
prep_data |> 
    leaflet() |> 
    addProviderTiles(provider = "Esri.WorldGrayCanvas") |> 
    addCircleMarkers(lng = ~xlong, lat = ~ylat, 
                     radius = ~percent_places_dispo/10,
                     label = ~nom, color = "#b7375d",
                     opacity = 0.8, fillOpacity = 0.4)


### Exercice n°2 : évolution du nombre d'actes de reconnaissance délivrés

# Import des données
data <- read_csv("https://opendata.agglo-larochelle.fr/d4c/api/records/2.0/downloadfile/format=csv&resource_id=95974ab3-7371-47ab-be81-6a29b113e5f3&use_labels_for_header=true&user_defined_fields=true")

# Préparation des données
prep_data <- data |> 
    summarise(ar_annee = sum(ar_nombre), .by = ar_evenement_annee) |> 
    na.omit()

# Graphique
prep_data |> 
    ggplot(aes(x = ar_evenement_annee, y = ar_annee)) +
    geom_line(col = "#b7375d") +
    geom_point(col = "#b7375d") +
    labs(title = "Évolution du nombre d'actes de reconnaissance délivrés",
         caption = "Données du portail open data de La Rochelle - Etat civil – Acte de reconnaissance",
         x = "Année", y = "Nombre d'actes délivrés") +
    theme_bw()


### Exercice n°3 : heatmap des résultats aux municipales 2026

# Import des données
library(readxl)
tour1 <- read_csv("https://opendata.agglo-larochelle.fr/d4c/api/records/2.0/downloadfile/format=csv&resource_id=277ac3b4-2515-4aa3-9e78-21977503a133&use_labels_for_header=true&user_defined_fields=true")
tour2 <- read_csv("https://opendata.agglo-larochelle.fr/d4c/api/records/2.0/downloadfile/format=csv&resource_id=a25b26e9-fdce-40c5-9dd2-80cfc0ca738c&use_labels_for_header=true&user_defined_fields=true")

# Préparation des données
tour1 <- tour1 |> 
    select(liste_alias, pourcentage) |> 
    mutate(tour = "tour 1")
tour2 <- tour2 |> 
    select(liste_alias, pourcentage) |> 
    mutate(tour = "tour 2")
all <- bind_rows(tour1, tour2)

# Graphique
all |> 
    ggplot(aes(x = tour, y = liste_alias, fill = pourcentage)) +
    geom_tile() +
    geom_text(aes(label = paste0(round(pourcentage, 1), "%")), 
              color = "black") +
    scale_fill_gradient(low = "white", high = "red") +
    labs(title = "Résultats aux élections municipales de 2026, La Rochelle", 
         caption = "Données du portail open data de La Rochelle - Elections - Municipales 2026 Ville de La Rochelle",
         x = NULL, y = "Liste", fill = "% voix") +
    theme_light() +
    theme(plot.title.position = "plot")


#---- Bilans de journée


library(tidyverse)
data_barplot <- tibble(categorie = c("Compréhension", "Intérêt", "Fatigue", "Plaisir"), 
                       valeur = c(5, 2, 3, 5))

data_barplot |> 
    ggplot(aes(x = categorie, y = valeur)) +
    geom_col(fill = "steelblue") +
    labs(title = "Bilan de la journée : X", x = NULL, y = "Score") +
    coord_flip()
