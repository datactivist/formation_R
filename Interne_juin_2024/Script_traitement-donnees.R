#--- Introduction à R, script contenant les commandes

# Chargement des librairies
library(tidyverse) #install.packages("tidyverse") à exécuter dans la console si pas déjà installé
library(readxl) #install.packages("readxl") à exécuter dans la console si pas déjà installé

# Import des données
    # en CSV via le lien
data <- read_delim("https://public.opendatasoft.com/api/explore/v2.1/catalog/datasets/demographyref-france-prenoms-departement-millesime/exports/csv?lang=fr&refine=birth_year%3A%221900%22&facet=facet(name%3D%22birth_year%22%2C%20disjunctive%3Dtrue)&timezone=Europe%2FBerlin&use_labels=true&delimiter=%3B", delim = ";")
    # en excel via l'import du fichier sur l'ordinateur
#data <- read_excel("~/Downloads/demographyref-france-prenoms-departement-millesime.xlsx")

# Renommer
data <- data |> rename(annee_naissance = `Année de naissance`,
                       code_departement = `Code Officiel Département`,
                   	   nom_departement = `Nom Officiel Département`,
                   	   nb_naissances = `Nombre de naissances`)

# Sélectionner
dat_select1 <- data |> select(-c(annee_naissance, `Année triable`))
dat_select2 <- data |> select(Sexe:nb_naissances)
dat_relocate1 <- data |> relocate(code_departement)
dat_select3 <- data |> select(code_departement, 1:3, 5:9)

# Filtrer
dat_filter1 <- data |> filter(Sexe == "Féminin")
dat_filter2 <- data |> filter(nom_departement == "Aisne" | nom_departement == "Gironde")
data |> filter(nb_naissances >= 100 & `Nom Officiel Région` == "Occitanie") |> nrow()

# Créer
data2 <- data |> mutate(nb_naissances10 = nb_naissances * 10,
                        taux = nb_naissances / sum(nb_naissances) *100,
                        siecle = substr(`Année triable`, 1, 2),
                        siecle = as.numeric(siecle) + 1)
    #exos en plus "créer"
data <- data |> mutate(region_1 = word(`Nom Officiel Région`, 1))
data <- data |> mutate(new_col = str_replace_all(Sexe, c("Masculin" = "Hommme", "Féminin" ~ "Femme")))
data <- data |> mutate(nouvelle_colonne = case_when(Sexe == "Masculin" ~ "Hommme",
                                                    Sexe == "Féminin" ~ "Femme",
                                                    .default = NA_character_))

# Résumer
data |> summarise(moy = mean(nb_naissances),
                  med = median(nb_naissances))
data |> summarise(etendue = range(nb_naissances))

# Grouper
data |> summarise(naissances_sexe = sum(nb_naissances), .by = Sexe)
data |> mutate(n_reg = n(), .by = `Nom Officiel Région`)
data |> filter(row_number() == 1, .by = `Nom Officiel Région`)

# Joindre
pop_departements <- read_delim("https://public.opendatasoft.com/api/explore/v2.1/catalog/datasets/demographyref-france-pop-active-sexe-activite-departement-millesime/exports/csv?lang=fr&refine=year%3A%222019%22&facet=facet(name%3D%22year%22%2C%20disjunctive%3Dtrue)&timezone=Europe%2FBerlin&use_labels=true&delimiter=%3B", ";") |> 
    filter(`Nom de la variable` == "Femmes Actifs ayant un emploi") |> 
    select(`Code Officiel Département`, Valeur) |> 
    rename(pop_femmes_actives = Valeur)
jointure <- data |> 
    left_join(pop_departements, by = c("code_departement" = "Code Officiel Département"))

