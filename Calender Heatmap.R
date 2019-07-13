if (!require("pacman")) install.packages("pacman")
pacman::p_load(quantmod,
               googleAnalyticsR,
               reshape2,
               ggplot2,
               scales,
               plyr)

ga_auth()

##Enter your view ID here
view_id <- 121634094


##Enter your start and end date here
start_date = "2017-01-01"
end_date = "2018-12-31"
sampling <- FALSE


ga.data = google_analytics(viewId = view_id,
                      date_range = c(start_date , end_date),
                      metrics = c("visits","transactions"),
                      dimensions = c("date"),
                      anti_sample = sampling,
                      max = 1000)


# Set extracted data  to this data frame
data <-  ga.data

# Run commands listed below
data$year <- as.numeric(as.POSIXlt(data$date)$year+1900)
data$month <- as.numeric(as.POSIXlt(data$date)$mon+1)
data$monthf <- factor(data$month,levels=as.character(1:12),
                      labels=c("Jan","Feb","Mar","Apr","May","Jun",
                               "Jul","Aug","Sep","Oct","Nov","Dec"),
                      ordered=TRUE)
data$weekday <- as.POSIXlt(data$date)$wday
data$weekdayf <- factor(data$weekday,levels=rev(0:6),
                        labels=rev(c("Mon","Tue","Wed","Thu","Fri","Sat","Sun")),
                        ordered=TRUE)
data$yearmonth <- as.yearmon(data$date)
data$yearmonthf <- factor(data$yearmonth)
data$week <- as.numeric(format(as.Date(data$date),"%W"))
data <- ddply(data,.(yearmonthf),transform,monthweek=1+week-min(week))

# Plot for visits
P_visits <- ggplot(data, aes(monthweek, weekdayf, fill = visits)) +
  geom_tile(colour = "white") +
  facet_grid(year~monthf) +
  scale_fill_gradient(high="#D61818",low="#B5E384") +
  labs(title = "Time-Series Calendar Heatmap") +
  xlab("Week of Month") +
  ylab("")

# View plot
P_visits

#Plot for transactions
P_transactions <- ggplot(data, aes(monthweek, weekdayf, fill = transactions)) +
  geom_tile(colour = "white") +
  facet_grid(year~monthf) +
  scale_fill_gradient(high="#D61818",low="#B5E384") +
  labs(title = "Time-Series Calendar Heatmap") +
  xlab("Week of Month") +
  ylab("")

# View plot
P_transactions