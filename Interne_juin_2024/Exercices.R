#--- Exercice de mise en pratique n°1 sur les données des équipements sportifs

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
ggplot(table, aes(x = `Commune Nom`, y = `Nombre d'équipements`, fill = `Commune Nom`)) +
    geom_col(width = 0.3, color = "white") +
    scale_fill_manual(values = c("Nantes" = "red", "Bordeaux" = "#FC54DD"))



#--- Exercice de mise en pratique n°2 sur les données des cantines

# Import, chargement
library(tidyverse)
data <- read_delim("https://www.data.gouv.fr/fr/datasets/r/3f73d129-6b24-45cd-95e9-9bacc216d9d9", ";") #Métadonnées > URL stable

# Question 1
data |> 
    filter(declaration_donnees_2021 == FALSE & declaration_donnees_2022 == FALSE & declaration_donnees_2023 == FALSE & declaration_donnees_2024_en_cours == FALSE) |> 
    nrow() #21.361

# Question 2
table <- data |> 
    filter(economic_model == "private" & epci_lib == "Métropole Européenne de Lille") |> 
    arrange(desc(daily_meal_count)) #ASS AMIS INSTITUTIUON STE MARIE (LYCEE PRIVE STE MARIE)

# Question 3
table <- data |> 
    summarise(`Nombre de cantines` = n(),
              `Nombre moyen de repas distribués par an` = mean(yearly_meal_count, na.rm = TRUE),
              `Nombre médian de repas distribués par an` = median(yearly_meal_count, na.rm = TRUE),
              .by = region_lib) #valeur erronée pour "Restaurant scolaire LOUIS DUMONT"

# Question 4
table |> 
    mutate(region_lib = fct_reorder(region_lib, `Nombre de cantines`)) |> 
    ggplot() +
    geom_col(aes(x = `Nombre de cantines`, y = region_lib), fill = "#F78865") +
    labs(y = "Région", 
         title = "Nombre de cantines par région",
         subtitle = "Données du Registre National des Cantines, issues de l'application 'ma-cantine'")



#--- Exercice de mise en pratique n°3 sur les données des timesheets Odoo

# Import, chargement
library(tidyverse)
data <- read_csv("./Interne_juin_2024/account.analytic.line.csv")

# Question 1
data |> 
    summarise(nb_heures = sum(Quantité),
              nb_jours = nb_heures / 7) #37.839 heures, soit 5.406 jours au 21/03/25

# Question 2
table <- data |> 
    summarise(max_quantite = max(Quantité), 
              .by = Projet) #Accompagnement open data - Métropole Rouen Normandie et Open Data Canvas (R&D), avec 210 heures

# Question 3
table <- data |> 
    mutate(annee = str_sub(Date, 1, 4)) |> 
    filter(Projet != "Tâches non facturables à timesheeter 2023",
           Projet != "Tâches non facturables à timesheeter 2024",
           Projet != "Tâches non facturables à timesheeter 2025") |> 
    summarise(`Nombre de jours timesheetées` = sum(Quantité), .by = c(Employé, annee))



