if (!require("pacman")) install.packages("pacman")
pacman::p_load(googleAnalyticsR,  # How we actually get the Google Analytics data
               tidyverse,         # Includes dplyr, ggplot2, and others; very key!
               devtools,          # Generally handy
               googleVis,         # Useful for some of the visualizations
               scales)            # Useful for some number formatting in the visualizations

view_id <- 16134042
# Authorize GA. Depending on if you've done this already and a .ga-httr-oauth file has
# been saved or not, this may pop you over to a browser to authenticate.
ga_auth(token = ".ga-httr-oauth")

# Set the view ID and the date range. If you want to, you can swap out the Sys.getenv()
# call and just replace that with a hardcoded value for the view ID. And, the start 
# and end date are currently set to choose the last 30 days, but those can be 
# hardcoded as well.
view_id <- Sys.getenv("GA_VIEW_ID")
start_date <- Sys.Date() - 31        # 30 days back from yesterday
end_date <- Sys.Date() - 1           # Yesterday

# Pull the data. See ?google_analytics_4() for additional parameters. The anti_sample = TRUE
# parameter will slow the query down a smidge and isn't strictly necessary, but it will
# ensure you do not get sampled data.
ga_data <- google_analytics(viewId = view_id,
                            date_range = c(start_date, end_date),
                            metrics = "sessions",
                            dimensions = c("date","medium","deviceCategory"),
                            anti_sample = TRUE)

# Go ahead and do a quick inspection of the data that was returned. This isn't required,
# but it's a good check along the way.
head(ga_data)

# Remove the "date" component to get total sessions for the heatmap
ga_data_totals <- ga_data %>% 
  group_by(medium, deviceCategory) %>% 
  summarise(sessions = sum(sessions))

# Roll up to just be medium tables and then arrange the values for use in converting the
# medium column to a factor. This is one of those things that is pretty standard to need 
# to do. We're going to sort descending, but, for one of the data frames, we're actually
# going to need to reverse the order as we create the factors. This just comes with
# experimentation and experience.
medium_totals <- ga_data %>% 
  group_by(medium) %>% 
  summarise(sessions = sum(sessions)) %>% 
  arrange(-sessions)

# Do the same thing, but for deviceCategory. For this one, we actually want to sort 
# descending.
deviceCategory_totals <- ga_data %>% 
  group_by(deviceCategory) %>% 
  summarise(sessions = sum(sessions)) %>% 
  arrange(-sessions)

# Convert the medium and deviceCategory columns to factors in both of our main data frames.
ga_data$medium <- factor(ga_data$medium,
                         levels = medium_totals$medium)
ga_data$deviceCategory <- factor(ga_data$deviceCategory,
                                 levels = deviceCategory_totals$deviceCategory)

ga_data_totals$medium <- factor(ga_data_totals$medium,
                                levels = rev(medium_totals$medium))    # Reversing the factor order
ga_data_totals$deviceCategory <- factor(ga_data_totals$deviceCategory,
                                        levels = deviceCategory_totals$deviceCategory)

# Let's just check that the ga_data_totals we created looks pretty normal
head(ga_data_totals)

# Create the plot
gg <- ggplot(ga_data_totals, mapping=aes(x = deviceCategory, y = medium)) +
  geom_tile(aes(fill = sessions), colour = "grey30") +
  geom_text(aes(label = format(sessions, big.mark = ","))) +
  scale_fill_gradient(low = "white", high = "green") +    # Specify the gradient colors
  guides(fill = FALSE) +                                 # Remove the legend
  theme_light() +
  theme(panel.grid = element_blank(),
        panel.border = element_blank(),
        axis.ticks = element_blank())

# Output the plot. You *could* just remove the "gg <-" in the code above, but it's
# generally a best practice to create a plot object and then output it, rather than
# outputting it on the fly.
gg
# Create the plot
gg_sparklines <- ggplot(ga_data, mapping=aes(x = date, y = sessions)) +
  geom_line() +
  facet_grid(medium ~ deviceCategory, switch = "y") +
  theme_light() +
  theme(panel.grid = element_blank(),
        panel.border = element_rect(fill = NA, colour = "gray80"),
        panel.background = element_blank(),
        strip.background = element_blank(),
        strip.text = element_text(colour = "black"),
        strip.text.y = element_text(angle = 180, hjust = 1),
        axis.ticks = element_blank(),
        axis.text = element_blank(),
        axis.title.x = element_blank())

# Output the plot. You *could* just remove the "gg <-" in the code above, but it's
# generally a best practice to create a plot object and then output it, rather than
# outputting it on the fly.
gg_sparklines