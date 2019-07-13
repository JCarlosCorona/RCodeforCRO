if (!require("pacman")) install.packages("pacman")
pacman::p_load("googleAnalyticsR",
               "dplyr",
               "tidyr",
               "highcharter")

# Authorize GA. Depending on if you've done this already and a .ga-httr-oauth file has
# been saved or not, this may pop you over to a browser to authenticate.
ga_auth()

# Set the view ID and the date range. If you want to, you can swap out the Sys.getenv()
# call and just replace that with a hardcoded value for the view ID. And, the start 
# and end date are currently set to choose the last 30 days, but those can be 
# hardcoded as well.
view_id <- Sys.getenv("GA_VIEW_ID")
start_date <- "2018-11-16"
end_date <- "2018-11-19"

# Pull the data. This is set to pull the last 400 days of data.
gadata <- google_analytics(viewId = view_id,
                           date_range = c(start_date, end_date),
                           metrics = "sessions", 
                           dimensions = c("date","hour","dayOfWeekName"),
                           max = -1)
head(gadata)

# Subset the data to just be the weekday, hour of the day, and sessions. (This
# means we're getting rid of the "date" column)
heatmap_data <- select(gadata, dayOfWeekName, hour, sessions)

# Summarize the data by weekday-hour
heatmap_sums <- group_by(heatmap_data, dayOfWeekName, hour) %>%
  summarise(sessions = sum(sessions))

# Now, "spread" the data out so it's heatmap-ready
heatmap_recast <- spread(heatmap_sums, hour, sessions)

# Make this "data frame" into a "matrix"
heatmap_matrix <- as.matrix(heatmap_recast[-1])

# Name the rows to match the weeks
row.names(heatmap_matrix) <- c("Friday","Saturday","Sunday","Monday")

# Generate the heatmap of weekdays per hour
hchart(heatmap_matrix, type = "heatmap")