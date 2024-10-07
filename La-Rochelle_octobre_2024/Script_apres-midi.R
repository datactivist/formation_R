## Manipulations de données pour la formation R - La Rochelle, 2024


#### APRÈS-MIDI ####



#---- Dérouillage

# Import
library(tidyverse)
place_bleue <- read_delim("https://opendata.agglo-larochelle.fr/d4c/api/records/2.0/downloadfile/format=csv&resource_id=407dd9c7-5f0c-4f69-8746-ba2e1caaa291&use_labels_for_header=true&user_defined_fields=true", ";")
dim(place_bleue)

# quel est l’id de tronçon (pzb_troncon_id) du pzb_id ‘75’ de la voie “Avenue des Corsaires” ?
place_bleue |> 
    filter(pzb_id == 75 & pzb_voie == "Avenue DES CORSAIRES") |> 
    select(pzb_troncon_id)

# combien y a-t-il de places de parking (lignes) sur le boulevard ANDRE SAUTEL ?
table(place_bleue$pzb_voie)  
place_bleue |> filter(pzb_voie == "Boulevard ANDRE SAUTEL") |> nrow()



#---- Exécution des manips du matin

# En lien vers le CSV
data <- read_delim("https://public.opendatasoft.com/api/explore/v2.1/catalog/datasets/demographyref-france-prenoms-departement-millesime/exports/csv?lang=fr&refine=birth_year%3A%221900%22&facet=facet(name%3D%22birth_year%22%2C%20disjunctive%3Dtrue)&timezone=Europe%2FBerlin&use_labels=true&delimiter=%3B", delim = ";")

# Renommer
names(data)
data <- data |> rename(annee_naissance = `Année de naissance`,
                       code_departement = `Code Officiel Département`,
                   	   nom_departement = `Nom Officiel Département`,
                   	   nb_naissances = `Nombre de naissances`)
names(data)

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

# autre
ggplot(group_data,
       aes(x = naissances_sexe, 
           y = Sexe, fill = Sexe)) +
    geom_col(width = .3) +
    labs(x = "Nombre de naissances",
         y = "Sexe de l'enfant",
         title = "Nombre de naissances par sexe en 1900") +
    scale_fill_manual(values = c("Masculin" = "#CC0000", 
                                 "Féminin" = "#FFFF99")) + #personnalisation des couleurs par sexe
    theme_classic() +
    theme(legend.position = "none") + #retrait de la légende
    geom_text(aes(x = naissances_sexe + 25000, y = Sexe, label = naissances_sexe)) #ajout du nombre exact après les barres




#---- Exercices finaux



# Import des données des services
library(readxl)
sante <- read_xlsx("./La-Rochelle_juin_2024/data [CONFIDENTIEL]/Tableau de bord indicateurs SPHL 2023v[Sante, hygiene].xlsx", 
                   sheet = "Secteur jaune", skip = 22)
stationnement <- read_xlsx("./La-Rochelle_juin_2024/data [CONFIDENTIEL]/Stat financières et occupation 2012-2026 [Stationnement].xlsx",
                           sheet = "Evolution globale", skip = 2)
dechets_bacs <- read_xlsx("./La-Rochelle_juin_2024/data [CONFIDENTIEL]/gvBacs_20240618135857[Dechets].xlsx")
dechets_composteur <- read_xlsx("./La-Rochelle_juin_2024/data [CONFIDENTIEL]/gvComposteur_20240618135407[Dechets].xlsx")


    ### SERVICE SANTÉ

# Tableau
table_stat <- sante |> 
    select(-c(`...4`:`...6`, `...8`:`...10`)) |> 
    rename(indicateur = `...1`) |> 
    filter(row_number() < 16) |> 
    mutate(`2018` = as.numeric(`2018`)) |> 
    pivot_longer(cols = c(`2017`:`2023`), names_to = "Annee", values_to = "Valeur") |> 
    filter(indicateur == "Surface des locaux en régie(m²)" | indicateur == "Surface des locaux prestation ext(m²)")

# Graphique
table_stat |> 
    ggplot(aes(x = Annee, y = Valeur, group = indicateur, col = indicateur)) +
        geom_line() +
        geom_point() +
        labs(title = "Évolution de la surface des locaux de santé et hygiène", 
             subtitle = "Agglomération de La Rochelle", 
             x = "Année",
             y = "Surface en m²") +
        theme_classic() +
        theme(legend.position = "top")



    ### SERVICE STATIONNEMENT

# Tableau
table_stat <- stationnement |> 
    select(`...1`:`2023...13`) |> 
    rename(indicateur = `...1`,
           `2012` = `2012...2`,
           `2013` = `2013...3`,
           `2014` = `2014...4`,
           `2015` = `2015...5`,
           `2016` = `2016...6`,
           `2017` = `2017...7`,
           `2018` = `2018...8`,
           `2019` = `2019...9`,
           `2020` = `2020...10`,
           `2021` = `2021...11`,
           `2022` = `2022...12`,
           `2023` = `2023...13`) |> 
    filter(row_number() < 3) |> 
    pivot_longer(cols = c(`2012`:`2023`), names_to = "Annee", values_to = "Valeur")

# Graphique
table_stat |> 
    ggplot(aes(x = Annee, y = Valeur, group = indicateur, col = indicateur)) +
        geom_line() +
        geom_point() +
        labs(title = "Évolution financière des recettes en parkings et voiries", 
             subtitle = "Agglomération de La Rochelle", 
             x = "Année",
             y = "Montant en €") +
        theme_classic() +
        theme(legend.position = "top")



    ### SERVICE DECHETS

# Tableau
table_stat <- dechets_composteur |> 
    filter(Commune == "ANGOULINS" | Commune == "CHATELAILLON PLAGE") |> 
    summarise(n = n(), .by = c(`Etat contenant`, Commune)) |> 
    mutate(percent = paste0(round(n/sum(n)*100, 0), "%"), .by = Commune)
 
# Graphique
table_stat |> 
    ggplot(aes(x = Commune, y = n, fill = `Etat contenant`)) +
    geom_col(position = "dodge") +
    geom_text(aes(label = percent, y = n + 30), position = position_dodge(width = .9)) +
    labs(title = "Comparaison du nombre de composteurs à Angoulins et Châtelaillon-Plage", 
         subtitle = "Agglomération de La Rochelle", 
         x = "Commune",
         y = "Nombre de composteurs") +
    theme_classic() +
    theme(legend.position = "top")
    
    
    
    
    
    
    
    

