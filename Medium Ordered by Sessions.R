if (!require("pacman")) install.packages("pacman")
pacman::p_load(googleAnalyticsR,  # How we actually get the Google Analytics data
               tidyverse,         # Includes dplyr, ggplot2, and others; very key!
               devtools,          # Generally handy
               googleVis,         # Useful for some of the visualizations
               scales)            # Useful for some number formatting in the visualizations

# Authorize GA. Depending on if you've done this already and a .ga-httr-oauth file has
# been saved or not, this may pop you over to a browser to authenticate.
view_id <- 16134042
ga_auth(token = ".ga-httr-oauth")

# Set the view ID and the date range. If you want to, you can swap out the Sys.getenv()
# call and just replace that with a hardcoded value for the view ID. And, the start 
# and end date are currently set to choose the last 30 days, but those can be 
# hardcoded as well.
view_id <- Sys.getenv("GA_VIEW_ID")
start_date <- Sys.Date() - 31        # 30 days back from yesterday
end_date <- Sys.Date() - 1           # Yesterday

# Create an order type object.
order_sessions_desc <- order_type("sessions",
                                  sort_order = "DESCENDING",
                                  orderType = "VALUE")

# Pull the data. See ?google_analytics_4() for additional parameters. Note that we are
# NOT using anti_sample = TRUE. This is because we are setting max = 5, and the max
# argument has no impact when anti_sample = TRUE.
ga_data <- google_analytics(viewId = view_id,
                            date_range = c(start_date, end_date),
                            metrics = "sessions",
                            dimensions = "medium",
                            order = order_sessions_desc,
                            max = 5)

# Go ahead and do a quick inspection of the data that was returned. This isn't required,
# but it's a good check along the way.
head

# Convert the medium to a factor so they will be ordered when plotted
ga_data$medium <- factor(ga_data$medium,
                         levels = rev(ga_data$medium))
# Create the plot. Note the stat="identity"" (because the data is already aggregated) and
# the coord_flip(). And, I just can't stand it... added on the additional theme stuff to
# clean up the plot a bit more.
gg <- ggplot(ga_data, mapping = aes(x = medium, y = sessions)) +
  geom_bar(stat = "identity") +
  coord_flip() +
  theme_light() +
  theme(panel.grid.major.y = element_blank(),
        panel.grid.minor.y = element_blank(),
        panel.border = element_blank(),
        axis.title.y = element_blank(),
        axis.ticks.y = element_blank())

# Output the plot. You *could* just remove the "gg <-" in the code above, but it's
# generally a best practice to create a plot object and then output it, rather than
# outputting it on the fly.
gg