# Load up a few libraries we'll need to retrieve and work with the data
if (!require("pacman")) install.packages("pacman")
pacman::p_load(googleAnalyticsR, 
               highcharter,
               forecast)

# Set the view ID that we'll be using. You can get the view ID for a specific view
# that you have access to by logging into the Google Analytics Query Explorer at
# https://ga-dev-tools.appspot.com/query-explorer/. It's the "ids" value.
view_id <- 53461765

# Authorize Google Analytics
ga_auth()

# Get the data from Google Analytics
gadata <- google_analytics(view_id, 
                           date_range = c("2017-05-01", "2019-05-31"),
                           metrics = "sessions", 
                           dimensions = c("yearMonth"),
                           max = -1,
                           anti_sample = FALSE)

# Convert the data to be officially "time-series" data
ga_ts <- ts(gadata$sessions, start = c(2017,05), end = c(2019,05), frequency = 12)
# Compute the Holt-Winters filtering for the data
forecast1 <- HoltWinters(ga_ts)
hchart(forecast(forecast1, h = 12))