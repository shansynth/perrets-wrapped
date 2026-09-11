library(DBI)
library(RSQLite)
library(dplyr)
library(jsonlite)

# Connect to local SQLite database
con <- dbConnect(RSQLite::SQLite(), "~/HealthData/DBs/garmin_activities.db")

dbListTables(con) #view what is actually inside said file

dbListFields(con, "files")

walks <- dbReadTable(con, "files_view")

dbDisconnect(con)
