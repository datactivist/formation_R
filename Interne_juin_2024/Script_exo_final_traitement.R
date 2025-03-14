#--- Exercice de mise en pratique global sur les données des équipements sportifs

# Import, chargement
library(tidyverse)
data <- read_delim("https://equipements.sports.gouv.fr/api/explore/v2.1/catalog/datasets/data-es/exports/csv?lang=fr&refine=equip_aps_nom%3A%22Activit%C3%A9s%20de%20forme%20et%20de%20sant%C3%A9%22&timezone=Europe%2FParis&use_labels=true&delimiter=%3B", ";")

# Question 1
nrow(data) #17.810

# Question 2
data |> 
    filter(`Type d'équipement sportif` == "Salle de cours collectifs" & `Commune Nom` == "Nantes") |> 
    nrow() #23

# Question 3
data |> 
    filter((`Présence de douches` == TRUE & `Présence de sanitaires` == TRUE) | `Aménagements de confort` == TRUE) |> 
    nrow() #10.225

# Question 4
table <- data |> 
    summarise(min_annee = min(`Année de mise en service`, na.rm = TRUE), .by = `Département Nom`) |> 
    arrange(min_annee) #Savoie

# Question 5
table <- data |> 
    filter(`Commune Nom` == "Nantes" | `Commune Nom` == "Bordeaux") |> 
    summarise(`Nombre d'équipements` = n(), .by = c(`Equipement d'accès libre`, `Commune Nom`)) |> 
    mutate(`%` = round(`Nombre d'équipements`/sum(`Nombre d'équipements`)*100, 0), .by = `Commune Nom`) |> 
    relocate(`Commune Nom`, .before = `Nombre d'équipements`)


#--- Graphique

# Data
ggplot(table, aes(x = `Commune Nom`, y = `Nombre d'équipements`)) +
    geom_col()



