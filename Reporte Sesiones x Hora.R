if (!require("pacman")) install.packages("pacman")
pacman::p_load("googleAnalyticsR",
               "dplyr",
               "tidyverse",
               "highcharter")

# Set the view ID that we'll be using. You can get the view ID for a specific view
# that you have access to by logging into the Google Analytics Query Explorer at
# https://ga-dev-tools.appspot.com/query-explorer/. It's the "ids" value.
view_id <- 16134042

# Authorize Google Analytics
ga_auth()

# Pull the data. This is set to pull the last 400 days of data.
gadata <- google_analytics(view_id, 
                             date_range = c("2018-11-09", "2018-11-12"),
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