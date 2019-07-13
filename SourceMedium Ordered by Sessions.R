#Load the necessary libraries.
if (!require("pacman")) install.packages("pacman")
pacman::p_load(googleAnalyticsR, 
               tidyverse, 
               devtools, 
               googleVis, 
               scales,
               highcharter) 

# Authorize GA
ga_auth(token = ".ga-httr-oauth")

# Set the view ID and the date range
view_id <- Sys.getenv("GA_VIEW_ID")
start_date <- Sys.Date() - 31        # 30 days back from yesterday
end_date <- Sys.Date() - 1           # Yesterday

#----

# Create an order type object.
order_sessions_desc <- order_type("sessions",
                                  sort_order = "DESCENDING",
                                  orderType = "VALUE")

# Pull the data. 
ga_data <- google_analytics(viewId = view_id,
                            date_range = c(start_date, end_date),
                            metrics = "sessions",
                            dimensions = "sourceMedium",
                            order = order_sessions_desc,
                            max = 5)
head(ga_data)

# Convert the sourceMedum to a factor so they will be ordered when plotted
ga_data$sourceMedium <- factor(ga_data$sourceMedium,
                         levels = rev(ga_data$sourceMedium))

# Create the plot.
gg <- ggplot(ga_data, mapping = aes(x = sourceMedium, y = sessions)) +
  geom_bar(stat = "identity") +
  coord_flip() +
  theme_light() +
  theme(panel.grid.major.y = element_blank(),
        panel.grid.minor.y = element_blank(),
        panel.border = element_blank(),
        axis.title.y = element_blank(),
        axis.ticks.y = element_blank())
gg