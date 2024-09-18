## Manipulations de données pour la formation R - La Rochelle, 2024


#### MATIN ####


#---- Import


# En lien vers le CSV
library(tidyverse) #install.packages("tidyverse") à éxecuter dans la console si pas déjà installé
data <- read_delim("https://public.opendatasoft.com/api/explore/v2.1/catalog/datasets/demographyref-france-prenoms-departement-millesime/exports/csv?lang=fr&refine=birth_year%3A%221900%22&facet=facet(name%3D%22birth_year%22%2C%20disjunctive%3Dtrue)&timezone=Europe%2FBerlin&use_labels=true&delimiter=%3B", delim = ";")

# En dur vers l'excel
library(readxl) #install.packages("readxl") à éxecuter dans la console si pas déjà installé
data <- read_excel("~/Downloads/demographyref-france-prenoms-departement-millesime.xlsx")



#---- Nettoyage

# Observation des données
glimpse(data)
summary(data$`Nombre de naissances`)



#---- Transformation

# Renommer
data <- data |> rename(annee_naissance = `Année de naissance`,
                       code_departement = `Code Officiel Département`,
                   	   nom_departement = `Nom Officiel Département`,
                   	   nb_naissances = `Nombre de naissances`)

# Sélectionner
dat_select1 <- data |> select(-c(annee_naissance, `Année triable`))
dat_select2 <- data |> select(Sexe:nb_naissances)

# Filtrer
dat_filter1 <- data |> filter(Sexe == "Féminin")
dat_filter2 <- data |> filter(nom_departement == "Aisne" | nom_departement == "Gironde")

# Créer
data <- data |> mutate(nb_naissances10 = nb_naissances * 10)
data <- data |> mutate(taux = nb_naissances / sum(nb_naissances) *100)

# Résumer
data |> summarise(moy = mean(nb_naissances),
               	  med = median(nb_naissances))
data |> summarise(etendue = range(nb_naissances))

# Grouper
group_data <- data |> summarise(naissances_sexe = sum(nb_naissances), .by = Sexe)
data |> mutate(n_reg = n(), .by = `Nom Officiel Région`)





