#preparation de l'espace de travail
rm(list = ls())
getwd()
setwd("~/Logiciel R/Tidyverse")
#les libraries
pacman::p_load(tidyverse,DBI,dbplyr, duckdb)
#connexion a la base des données
con <- DBI::dbConnect(duckdb::duckdb(),
                      dbdir = "duckdb")

dbWriteTable(con, "mpg", ggplot2::mpg)
dbWriteTable(con, "diamonds", ggplot2::diamonds)
dbListTables(con)
con |> dbReadTable("diamonds") |> 
  as_tibble()

sql <- "
SELECT carat, cut,clarity,color,price
FROM diamonds
WHERE price > 15000"

as_tibble(dbGetQuery(con, sql))

# dbplyr database ---------------------------------------------------------

diamonds_db <- tbl(con, "diamonds")
diamonds_db
library(extraoperators)
big_diamonds_db <- diamonds_db |>  
  filter(price > 15000) |> 
  select(carat:clarity, price)

big_diamonds_db
#to show sql  query
big_diamonds_db |> show_query()
#to collect all data
big_diamonds <-  big_diamonds_db |> collect()
big_diamonds

# SQL ---------------------------------------------------------------------

#copie nyccflights 13 dans la base
dbplyr::copy_nycflights13(con)
flights <- tbl(con,"flights")
planes <- tbl(con,"planes")
#sql basic
flights |> show_query()
planes |> show_query()
flights |> filter(dest == "IAH") |> arrange(dep_delay) |> 
  show_query()
flights |> group_by(dest) |> summarise(dep_delay = mean(dep_del))
