#preparation de l'espace de travail
rm(list = ls())
getwd()
setwd("~/Logiciel R/rdatasciences")
#les libraries
pacman::p_load(tidyverse, readxl, writexl)

# Excel file --------------------------------------------------------------

students <- read_excel("data/students.xlsx")
students
read_excel("data/students.xlsx",
           col_names = c("students_id", "full_name", "favourite_food","meal_plan","age"))
read_excel("data/students.xlsx",
col_names = c("students_id", "full_name", "favourite_food","meal_plan","age"),
skip = 1)
#specifier la valeur du NA
read_excel("data/students.xlsx",
           col_names = c("students_id", "full_name", "favourite_food","meal_plan","age"),
           skip = 1, na = c(" ", "N/A")
           )
#pour specifier le type de colonne
read_excel("data/students.xlsx",
          col_names = c("students_id", "full_name", "favourite_food","meal_plan","age"),
          skip = 1, na = c(" ", "N/A"),
          col_types = c("numeric", "text", "text", "text", "numeric"))

students <- read_excel("data/students.xlsx",
           col_names = c("students_id", "full_name", "favourite_food","meal_plan","age"),
           skip = 1, na = c(" ", "N/A"),
col_types = c("numeric", "text", "text", "text", "text"))

students
students <- students |> mutate(
  age = if_else(age == "five","5", age),
  age = parse_number(age)
)
students

#lecture d'un fichier excel avec plusieures feuilles
read_excel("data/penguins.xlsx", sheet = "Torgersen Island")

penguins_torgersen <- read_excel("data/penguins.xlsx", 
                                 sheet = "Torgersen Island",
                                 na = "NA")
penguins_torgersen
#pour obtenier des informatiopns sur les feuilles
excel_sheets("data/penguins.xlsx")
# la lecture des autres feuilles
penguins_biscoe <- read_excel("data/penguins.xlsx", sheet =  "Biscoe Island",
                              na = "NA")
penguins_dream <- read_excel("data/penguins.xlsx", sheet =  "Dream Island",
                             na = "NA")
#pour veifier les dimensions des fichier
dim(penguins_biscoe)
dim(penguins_dream)
dim(penguins_torgersen)
#pour combiner les feuilles, Voir chap 27
penguins <- bind_rows(penguins_torgersen, penguins_biscoe, penguins_dream)
penguins
#pour selectionner une partie
deaths_path <- readxl_example("deaths.xlsx")
deaths_path
deaths <- read_excel(deaths_path)
deaths
read_excel(deaths_path, range = "A5:F15")
#sauvegarde de fichier excel
bake_sale <- tibble(
  item = factor(c("brownie", "cupcake", "cookie")),
  quantity = c(10,5,8)
)
write_xlsx(bake_sale,"bake-sale.xlsx")

# google sheets -----------------------------------------------------------

pacman::p_load(googlesheets4)
students_url <- "https://docs.google.com/spreadsheets/d/1V1nPp1tzOuutXFLb3G9Eyxi3qxeEhnOXUzL5_BcCQ0w"

students_sheets <- read_sheet(students_url)
students
students <- read_sheet(
  students_url,
  col_names = c("student_id","full_name","favourite_food", "meal_plan","age"),
  skip = 1,
  na = c("", "N/A"),
  col_types = "dcccc"
)
students
penguins_url <- "https://docs.google.com/spreadsheets/d/1aFu8lnD_g0yjF5O-K6SFgSEWiHPpgvFCF0NY9D6LXnY"
read_sheet(penguins_url, sheet = "Torgersen Island")
sheet_names(penguins_url)
#specifier les colonnes
deaths_url <- gs4_example("deaths")
deaths <- read_sheet(deaths_url, range = "A5:F15")
deaths
#sauvegarder un fichier en googlesheets
write_sheet(bake_sale, ss = "bake-sale")
