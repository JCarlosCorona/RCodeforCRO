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
dimensions <- c("pagePath")          # Dimensiones
metrics <- c("pageviews")            # Metricas

#----

#Create the segment object.
segment <- segment_ga4("Mobile Sessions Only",
                          segment_id = "gaid::-14")

# Pull the data.
ga_data <- google_analytics(viewId = view_id,
                            date_range = c(start_date, end_date),
                            metrics = metrics,
                            dimensions = dimensions,
                            segments = segment)
head(ga_data)

# Using dplyr, sort descending and then grab the top 10 values
ga_data_top_10 <- ga_data %>%
  arrange(-pageviews) %>% 
  top_n(10) %>% 
  mutate(pagePath = factor(pagePath,
                           levels = rev(pagePath)))

# Take a quick look at the result.
head(ga_data_top_10)

gg <- ggplot(ga_data_top_10, mapping = aes(x = pagePath, y = pageviews)) +
  geom_bar(stat = "identity") +
  coord_flip() +
  theme_light() +
  theme(panel.grid.major.y = element_blank(),
        panel.grid.minor.y = element_blank(),
        panel.border = element_blank(),
        axis.title.y = element_blank(),
        axis.ticks.y = element_blank())

gg

hchart(ga_data_top_10, type = "bar", hcaes(x = pagePath, y = pageviews))