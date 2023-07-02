#preparation de l'espace de travail
rm(list = ls())
getwd()
setwd("~/Logiciel R/Tidyverse")
#les libraries
pacman::p_load(tidyverse, arrow, dbplyr, duckdb)

#pour telecharger un document
curl::multi_download(
  "https://r4ds.s3.us-west-2.amazonaws.com/seattle-library-checkouts.csv",
  "data/seattle-library-checkouts.csv",
  resume = TRUE
)
# ouvrir le jeu de données
seattle_csv <- open_dataset(
  sources = "data/seattle-library-checkouts.csv",
  format = "csv"
)
seattle_csv
seattle_csv |> glimpse()

seattle_csv |> count(CheckoutYear, wt = Checkouts) |> 
  arrange(CheckoutYear) |> collect()
pq_path <- "data/seattle-library-checkouts"
#partition
seattle_csv |> group_by(CheckoutYear) |> 
  write_dataset(path = pq_path, format = "parquet")
reprex::reprex(seattle_csv |> dplyr::group_by(CheckoutYear) |> 
                 arrow::write_dataset(path = pq_path, format = "parquet"))
#on obtien une erreur qu'il faut corriger
opts <- CsvConvertOptions$create(col_types = schema(ISBN = string()))
seattle_csv <- open_dataset(
  sources = "data/seattle-library-checkouts.csv",
  format = "csv",
  convert_options = opts
)
seattle_csv |> group_by(CheckoutYear) |> 
  write_dataset(path = pq_path, format = "parquet")
tibble(
  files = list.files(pq_path, recursive = TRUE),
  size_sb = file.size(file.path(pq_path, files))/1024^2
)
#recherche avec dplyr_col_modify()
seattle_pq <- open_dataset(pq_path)
query <- seattle_pq |> 
  filter(CheckoutYear >=2018, MaterialType == "BOOK") |> 
  group_by(CheckoutYear, CheckoutMonth) |> 
  summarise(Totalcheckouts = sum(Checkouts)) |> 
  arrange(CheckoutYear, CheckoutMonth)
query
query |> glimpse()
compute(query)
query |> collect()

# evaluons les performances des codes
seattle_csv |> 
  filter(CheckoutYear == 2021, MaterialType == "BOOK") |> 
  group_by(CheckoutMonth) |> 
  summarise(Totalcheckouts = sum(Checkouts)) |> 
  arrange(desc(CheckoutMonth)) |> collect() |> system.time()

seattle_pq |> 
  filter(CheckoutYear == 2021, MaterialType == "BOOK") |> 
  group_by(CheckoutMonth) |> 
  summarise(Totalcheckouts = sum(Checkouts)) |> 
  arrange(desc(CheckoutMonth)) |> collect() |> system.time()
#creation d'une bas de donnée avec arrow
seattle_pq |> to_duckdb() |> 
  filter(CheckoutYear == 2021, MaterialType == "BOOK") |> 
  group_by(CheckoutMonth) |> 
  summarise(Totalcheckouts = sum(Checkouts)) |> 
  arrange(desc(CheckoutMonth)) |> collect()
