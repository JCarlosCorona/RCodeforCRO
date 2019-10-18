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

#ID de la vista de GA.
ga.cuentas <- ga_account_list()
1
#Modificar el regex del nombre la cuenta para obtener el ID dequerido
cuentas <- ga.cuentas %>%
  select(accountName, webPropertyName, viewName, viewId) %>% 
  filter(grepl("hoteles",accountName,ignore.case = TRUE))
cuentas
#Colocar el numero de fila de la vista requerida
view.id <- cuentas$viewId[9]

#Fechas
start.date <- "2018-01-01"
end.date <- "2018-12-31"
#TRUE para dejar el sampleo de la data y FALSE para desactivarlo.
sampling <- FALSE

# Get the data. Use the "pivots" parameter to get columns of medium sessions.
pivotga <- pivot_ga4("channelGrouping",
                   metrics = c("sessions"), 
                   maxGroupCount = 10)

trend_data <- google_analytics(viewId = view.id,
                           date_range = c(start.date, end.date),
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