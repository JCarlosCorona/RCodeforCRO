#Load the necessary libraries.
if (!require("pacman")) install.packages("pacman")
pacman::p_load(googleAnalyticsR, 
               tidyverse, 
               devtools, 
               googleVis, 
               scales,
               highcharter) 

# Authorize GA
ga_auth()

# Set the view ID and the date range
view_id <- Sys.getenv("GA_VIEW_ID")
start_date <- Sys.Date() - 31                 # Fecha de inicio
end_date <- Sys.Date() - 1                    # Fecha final

#----

# Pull the data.
ga_data <- google_analytics(viewId = view_id,
                            date_range = c(start_date, end_date),
                            metrics = "sessions",
                            dimensions = c("date","deviceCategory"),
                            anti_sample = TRUE)
head(ga_data)

# Create the plot.
gg <- ggplot(ga_data, mapping = aes(x = date, y = sessions, colour = deviceCategory)) +
  geom_line() +
  theme_light()
gg

hchart(ga_data, type = "area", hcaes(x = date, y = sessions, group = deviceCategory),
       color = c("#F4CD00", "#76C4D5", "#F7323F"))