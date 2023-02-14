## Manipulations de données pour la formation R - février/2023


#### JOUR 1 ####


#---- Import

# En lien vers le CSV
library(tidyverse)
mediatheques <- read_delim("https://opendata.lillemetropole.fr/api/explore/v2.1/catalog/datasets/ouvrages-acquis-par-les-mediatheques-/exports/csv?lang=fr&timezone=Europe%2FBerlin&use_labels=true&delimiter=%3B", delim = ";")

# En dur vers l'excel
library(readxl)
mediatheques <- read_excel("~/Downloads/ouvrages-acquis-par-les-mediatheques-.xlsx")



#---- Nettoyage

# Observation des données
glimpse(mediatheques)
summary(mediatheques$nb_prets)
table(mediatheques$libelle_support)



#---- Transformation

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

