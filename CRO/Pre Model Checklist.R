#Load the necessary libraries.
if (!require("pacman")) install.packages("pacman")
pacman::p_load(zoo,
               googleAnalyticsR,
               lubridate,
               ggplot2,
               scales)


view_id <- 16134042
start_date <- "2017-01-01"
end_date <- "2018-01-01"
sampling <- FALSE

ga_auth()

ga_data = google_analytics(viewId = view_id,
                           date_range = c(start_date , end_date),
                           metrics = c("sessions"),
                           dimensions = c("yearMonth"),
                           anti_sample = sampling)

head(ga_data)

ga_data$yearMonth
Y <- substr(ga_data$yearMonth, 1, 4)
M <- substr(ga_data$yearMonth, 5, 6)
D <- paste(Y,M,"01",sep = "-")
as.Date(D)

ga_data$yearMonth <- D

gg <- ggplot(ga_data, mapping = aes(x = yearMonth, y = sessions)) +
  geom_line() +
  theme_light()
gg