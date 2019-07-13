if (!require("pacman")) install.packages("pacman")
pacman::p_load("googleAnalyticsR",
               "knitr",
               "ggplot2",
               "tidyverse",
               "highcharter",
               "dplyr")

# Authorize GA. Depending on if you've done this already and a .ga-httr-oauth file has
# been saved or not, this may pop you over to a browser to authenticate.
ga_auth

# Set the view ID and the date range. If you want to, you can swap out the Sys.getenv()
# call and just replace that with a hardcoded value for the view ID. And, the start 
# and end date are currently set to choose the last 30 days, but those can be 
# hardcoded as well.
view_id <- Sys.getenv("GA_VIEW_ID")
start_date <- Sys.Date() - 300        # 300 days back from yesterday
end_date <- Sys.Date() - 1           # Yesterday

# Get the data. Use the "pivots" parameter to get columns of medium sessions.
pivotga <- pivot_ga4("channelGrouping",
                   metrics = c("sessions"), 
                   maxGroupCount = 10)

trend_data <- google_analytics(viewId = view_id,
                           date_range = c(start_date, end_date),
                           metrics = "sessions", 
                           dimensions = c("date"),
                           pivots = list(pivotga),
                           max = -1)
# Note the medium columns that were created by using the pivots= setting
head(trend_data)
# The "names" are the column headings. Let's see what those are (these are the same as the headings
# in the table above -- we just want to double-check that that's what we're about to change).
names(trend_data)
# Now, let's actually change those values to be a bit more user-friendly.
names(trend_data) <- c("Date","Total","Organic","Direct","Email","Referral","Display","Criteo","Other","Social","Video")

# Plot the Total (total sessions) by date as a line chart (type = "l"). Oh... and we want to
# turn off the tick marks on the x-axis, which uses the oh-so-obvious "xaxt=" parameter
plot(Total ~ Date, data = trend_data, type = "l", xaxt="n")

# Now, add to that plot the x-axis using the date values and format them with the 3-letter
# month ("%b") and 2-digit year ("%y")
axis(1, trend_data$Date, format(trend_data$Date, "%b-%y"), tick = FALSE)

# Change the data into a 'long' format. This is "tidy data," which we'll cover
# elsewhere in more detail.
trend_long <- gather(trend_data, Channel, Sessions, -Date)

# Check out the first few rows of the 'long' version of the data
head

# Build up the plot.
# Create a basic plot object that says to use Sessions as the plotted variable, and to split
# out each Channel into a different data series. For now, don't actually *plot* it -- just
# make it a "plot object" that we're calling "gg" (we haven't yet said *how* to plot it --
# we've just sort of set up "here's the data and here's how we're looking at it.")
gg <- ggplot(trend_long, aes(x = Date, y = Sessions, group = Channel)) + theme_minimal()

# Now, add on to that base plot definition that we want to plot the results as a line chart,
# and we want to make each Channel's data a different color.
gg <- gg + geom_line(aes(colour = Channel))

# Finally, actually output the plot.
gg

# Use the hchart function to generate a line chart with the data.
hchart(trend_long, type = "line", hcaes(x = Date, y = Sessions, group = Channel))