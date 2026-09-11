library(DBI)
library(RSQLite)
library(dplyr)
library(jsonlite)

# Connect to local SQLite database
con <- dbConnect(RSQLite::SQLite(), "~/HealthData/DBs/garmin_activities.db")

dbListTables(con) #view what is actually inside said file

dbListFields(con, "activities")

walks <- dbReadTable(con, "walking_activities_view")

#will want to join onto avtivities for ascent and descent

dbDisconnect(con)
