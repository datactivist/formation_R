#--- Introduction à R, script contenant les commandes

# Chargement des librairies
library(tidyverse) #install.packages("tidyverse") à éxecuter dans la console si pas déjà installé
library(readxl) #install.packages("readxl") à éxecuter dans la console si pas déjà installé

# Import des données
    # en CSV via le lien
data <- read_delim("https://public.opendatasoft.com/api/explore/v2.1/catalog/datasets/demographyref-france-prenoms-departement-millesime/exports/csv?lang=fr&refine=birth_year%3A%221900%22&facet=facet(name%3D%22birth_year%22%2C%20disjunctive%3Dtrue)&timezone=Europe%2FBerlin&use_labels=true&delimiter=%3B", delim = ";")
    # en excel via l'import du fichier sur l'ordinateur
#data <- read_excel("~/Downloads/demographyref-france-prenoms-departement-millesime.xlsx")

# Renommage
data <- data |> rename(annee_naissance = `Année de naissance`,
                       code_departement = `Code Officiel Département`,
                   	   nom_departement = `Nom Officiel Département`,
                   	   nb_naissances = `Nombre de naissances`)

# Sélection
dat_select1 <- data |> select(-c(annee_naissance, `Année triable`))
dat_select2 <- data |> select(Sexe:nb_naissances)
dat_relocate1 <- data |> relocate(code_departement)
dat_select3 <- data |> select(code_departement, 1:3, 5:9)

# Filtrer
dat_filter1 <- data |> filter(Sexe == "Féminin")
dat_filter2 <- data |> filter(nom_departement == "Aisne" | nom_departement == "Gironde")
data |> filter(nb_naissances >= 100 & `Nom Officiel Région` == "Occitanie") |> nrow()


