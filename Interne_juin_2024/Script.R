#--- Introduction à R, script contenant les commandes

# Chargement des librairies
library(tidyverse) #install.packages("tidyverse") à éxecuter dans la console si pas déjà installé
library(readxl) #install.packages("readxl") à éxecuter dans la console si pas déjà installé

# Import des données
    # en CSV via le lien
data <- read_delim("https://public.opendatasoft.com/api/explore/v2.1/catalog/datasets/demographyref-france-prenoms-departement-millesime/exports/csv?lang=fr&refine=birth_year%3A%221900%22&facet=facet(name%3D%22birth_year%22%2C%20disjunctive%3Dtrue)&timezone=Europe%2FBerlin&use_labels=true&delimiter=%3B", delim = ";")
    # en excel via l'import du fichier sur l'ordinateur
data <- read_excel("~/Downloads/demographyref-france-prenoms-departement-millesime.xlsx")

# Renommage
data <- data |> rename(annee_naissance = `Année de naissance`,
                       code_departement = `Code Officiel Département`,
                   	   nom_departement = `Nom Officiel Département`,
                   	   nb_naissances = `Nombre de naissances`)
