if (!require("pacman")) install.packages("pacman")
pacman::p_load(googleAnalyticsR,  # How we actually get the Google Analytics data
               tidyverse,         # Includes dplyr, ggplot2, and others; very key!
               devtools,          # Generally handy
               googleVis,         # Useful for some of the visualizations
               scales)            # Useful for some number formatting in the visualizations
ga_auth()

view_id <- Sys.getenv("GA_VIEW_ID")
start_date <- Sys.Date() - 30
end_date <- Sys.Date() - 1

ga_data <- google_analytics(viewId = view_id,
                            date_range = c(start_date, end_date),
                            metrics = "sessions",
                            dimensions = c("date","deviceCategory"),
                            anti_sample = TRUE)
head(ga_data)

gg <- ggplot(ga_data, mapping = aes(x = date, y = sessions, colour = deviceCategory)) +
  geom_line() +
  theme_light()
gg