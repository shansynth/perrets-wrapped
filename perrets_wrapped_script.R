library(DBI)
library(RSQLite)
library(dplyr)
library(jsonlite)
library(lubridate)
library(ggplot2)

#connect to sqlite db
con <- dbConnect(RSQLite::SQLite(), "~/HealthData/DBs/garmin_activities.db")

# peek around at data
dbListTables(con) #
dbListFields(con, "activities")
dbListFields(con, "walking_activities_view")

# data selection & cleaning

activities_full <- dbReadTable(con, "activities")
walks <- dbReadTable(con, "walking_activities_view")

walks_all_data <- walks |>
    left_join(activities_full, by = join_by(activity_id), keep = FALSE)

walks_clean <- walks_all_data |>
    select(
        activity_id,
        start_time.x,
        stop_time.x,
        elapsed_time.x,
        distance.x,
        steps,
        avg_moving_pace,
        avg_hr.x,
        avg_speed.x,
        start_loc,
        stop_loc,
        start_lat,
        start_long,
        stop_lat,
        stop_long,
        ascent
    ) |>
    rename(
        start_time = start_time.x,
        stop_time = stop_time.x,
        distance = distance.x,
        avg_hr = avg_hr.x,
        elapsed_time = elapsed_time.x,
        avg_speed = avg_speed.x
    ) |>
    mutate(
        date = as_date(start_time)
    ) |>
    filter(date >= "2026-01-01") |>
    arrange(date)

#have start and end loc/lat long but not sure if i can extract the perrets hill vector
#without having the full walk activity map - not sure how to get this
#most of the walks are this but there are others included that wont be, and also others that
#will span the perrets hill without starting and stopping in the correct area

#ggplot for mapping

library(ggplot2)

# Divide avg_hr by ~25 to bring its scale (60-150) inline with speed (0-5)
ggplot(walks_clean, aes(x = date)) +
    geom_point(aes(y = avg_speed, color = "Speed"), alpha = 0.4) +
    geom_smooth(
        aes(y = avg_speed, color = "Speed"),
        method = "loess",
        se = FALSE
    ) +
    geom_point(aes(y = avg_hr / 25, color = "Heart Rate"), alpha = 0.4) +
    geom_smooth(
        aes(y = avg_hr / 25, color = "Heart Rate"),
        method = "loess",
        se = FALSE
    ) +
    scale_y_continuous(
        name = "Average Speed (mph)",
        sec.axis = sec_axis(~ . * 25, name = "Average Heart Rate (bpm)")
    ) +
    scale_color_manual(values = c("Speed" = "blue", "Heart Rate" = "red")) +
    labs(color = "Metric") +
    theme_minimal()


dbDisconnect(con)
