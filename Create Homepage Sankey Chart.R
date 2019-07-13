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
start_date <- Sys.Date() - 31        # 30 days back from yesterday
end_date <- Sys.Date() - 1           # Yesterday
sampling <- FALSE

#----

# Create page filter object
page_filter <- dim_filter(
  dimension = "landingPagePath",
  operator = "REGEXP",
  expressions = "^/$")
homepage_filter <- filter_clause_ga4(list(page_filter))

# Pull the data from GA
home_next_pages <- google_analytics(
  viewId = view_id,
  date_range = c(start_date, end_date),
  dimensions = c("secondPagePath", "channelGrouping"),
  metrics = "uniquePageviews",
  dim_filters = homepage_filter,
  max = -1,
  anti_sample = sampling
)
head(home_next_pages)

# Build the data frame of top 10 pages:
top_10 <- home_next_pages %>% 
  group_by(secondPagePath) %>% 
  summarise(upvs = sum(uniquePageviews)) %>% 
  top_n(10, upvs) %>% 
  arrange(desc(upvs))

# Using this list of our top 10 pages, use the `semi_join` function from `dplyr` to restrict 
# our data to pages & channels that have one of these top 10 pages as the second page viewed.
home_next_pages <- home_next_pages %>% 
  semi_join(top_10, by = "secondPagePath")

# Check the data again. It's the same structure as it was originally, and the head() is likely
# identical. But, we know that, deeper in the data, the lower-volume pages have been removed.
head(home_next_pages)

# Reordering colums: the gVisSankey function doesn't take kindly
# if our df columns aren't strictly ordered as from:to:weight
home_next_pages <- home_next_pages %>% 
  select(channelGrouping, secondPagePath, uniquePageviews)

# Build the plot
s <- gvisSankey(home_next_pages)
# chartid = chart_id)
plot(s)

# 8 values from colorbrewer. Note the use of array notation
# colour_opts <- '["#7fc97f", "#beaed4","#fdc086","#ffff99","#386cb0","#f0027f","#bf5b17","#666666"]'
colour_opts <- '["#7fc97f", "#beaed4","#fdc086","#ffff99"]'

# Set colorMode to 'source' to colour by the chart's source
opts <- paste0("{
               link: { colorMode: 'source',
               colors: ", colour_opts ," }
               }" )

# This colour list can now be passed as an option to our `gvisSankey` call. We pass them to the 
# `options` argument for our plot.
s <- gvisSankey(home_next_pages,
                options = list(sankey = opts))
plot(s)

# 25% gray for all sources except the second one.
colour_opts <- '["#999999", "#999999","#999999","#999999","#ffcc33","#999999","#999999","#999999"]'

opts <- paste0("{
               link: { colorMode: 'source',
               colors: ", colour_opts ," },
               node: { colors: '#999999' }
               }" )

# This colour list can now be passed as an option to our `gvisSankey` call.
s <- gvisSankey(home_next_pages,
                options = list(sankey = opts))
plot(s)