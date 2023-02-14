## Manipulations de données pour la formation R - février/2023


#### JOUR 2 ####



#---- Dérouillage matinal

# Import
library(tidyverse)
carrefour_bus <- read_delim("https://opendata.lillemetropole.fr/api/explore/v2.1/catalog/datasets/carrefour-feu-avec-priorite-bus/exports/csv?lang=fr&timezone=Europe%2FBerlin&use_labels=true&delimiter=%3B", ";")
dim(carrefour_bus)

# combien y a-t-il de carrefours en poste de commandement ?
table(carrefour_bus$Gestion)
carrefour_bus %>% filter(Gestion == "en_PC") %>% nrow()

# créer un nouvel objet avec les carrefours de Lambersart ayant reçu plus de 50 appels un dimanche, et sommer le nombre d’appels au nombre d’actions
subdf <- carrefour_bus %>% filter(Commune == "LAMBERSART", 
                                  `Nombre appels` > 50, 
                                  `Jour de la semaine` == "DIMANCHE") %>% 
    mutate(somme_appels_actions = `Nombre appels` + `Nombre d'actions`)




#---- Exécution des manips du jour 1

# En lien vers le CSV
mediatheques <- read_delim(file = "https://opendata.lillemetropole.fr/api/explore/v2.1/catalog/datasets/ouvrages-acquis-par-les-mediatheques-/exports/csv?lang=fr&timezone=Europe%2FBerlin&use_labels=true&delimiter=%3B", delim = ";")

# Renommer
names(mediatheques)
mediatheques <- mediatheques %>% 
    rename(annee_publication = `Année de publication`,
           date_reception = `date de reception`,
           bibliotheque = Bibliothèque,
           type_document = `Type de document`)
names(mediatheques)

# Sélectionner
med_select1 <- mediatheques %>% select(-auteur, -type_document)
med_select1 <- mediatheques %>% select(-c(auteur, type_document))
med_select2 <- mediatheques %>% select(editeur:nb_prets)
med_select3 <- mediatheques %>% select(titre, 1, 2, 4, type_document, 5:9, 11)

# Filtrer
med_filter1 <- mediatheques %>% filter(libelle_support == "Affiche")
med_filter2 <- mediatheques %>% filter(annee_publication >= "1950" & annee_publication <= "1960")
mediatheques %>% filter(type_document == "Musiques nouvelles" & nb_prets >= 1) %>% nrow()

# Créer
mediatheques <- mediatheques %>% mutate(nb_prets10 = nb_prets + 10)
mediatheques <- mediatheques %>% mutate(annee_reception = format(as.Date(date_reception, format="%Y-%m-%d"),"%Y")) # ou
mediatheques <- mediatheques %>% mutate(annee_reception = substr(date_reception, 1, 4))

# Résumer
mediatheques %>% summarise(moy = mean(nb_prets),
                   med = median(nb_prets))
mediatheques %>% summarise(etendue = range(nb_prets))

# Grouper
mediatheques %>% group_by(libelle_support) %>% summarise(n = n())
mediatheques %>% group_by(annee_publication) %>% summarise(nb_prets_total = sum(nb_prets))
mediatheques <- mediatheques %>% group_by(titre) %>% mutate(nb_acquis = n()) %>% ungroup()




#---- Visualisation

# data
ggplot(mediatheques)

# aes
ggplot(mediatheques, 
       aes(x = nb_prets, y = nb_acquis))

# geom
ggplot(mediatheques, 
       aes(x = nb_prets, y = nb_acquis)) +
    geom_point() #+ geom_smooth()

# autres paramètres aes
ggplot(mediatheques, 
       aes(x = nb_prets, y = nb_acquis, col = annee_reception)) +
    geom_point(shape = 2)

# labs
ggplot(mediatheques, 
       aes(x = nb_prets, y = nb_acquis, col = annee_reception)) +
    geom_point(shape = 2) +
    labs(x = "Nombre de prêts", 
         y = "Nombre d’acquisitions", 
         title = "Acquisitions et prêts des médiathèques depuis 2019")

# theme
ggplot(mediatheques, 
       aes(x = nb_prets, y = nb_acquis, col = annee_reception)) +
    geom_point(shape = 2) +
    labs(x = "Nombre de prêts", 
         y = "Nombre d’acquisitions", 
         title = "Acquisitions et prêts des médiathèques depuis 2019") +
    theme_minimal()
ggplot(mediatheques, 
       aes(x = nb_prets, y = nb_acquis, col = annee_reception)) +
    geom_point(shape = 2) +
    labs(x = "Nombre de prêts", 
         y = "Nombre d’acquisitions", 
         title = "Acquisitions et prêts des médiathèques depuis 2019") +
    theme_classic()
ggplot(mediatheques, 
       aes(x = nb_prets, y = nb_acquis, col = annee_reception)) +
    geom_point(shape = 2) +
    labs(x = "Nombre de prêts", 
         y = "Nombre d’acquisitions", 
         title = "Acquisitions et prêts des médiathèques depuis 2019") +
    theme_dark()



