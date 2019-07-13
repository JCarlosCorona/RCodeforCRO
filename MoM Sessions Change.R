if (!require("pacman")) install.packages("pacman")
pacman::p_load("googleAuthR",
               "googleAnalyticsR",
               "ggplot2")

ga_auth()
ga_account_list()


ga_id <- 16134042

gadata <- google_analytics(viewId = ga_id, 
                           date_range = c("2018-01-01","2018-11-21"),
                           metrics = c("sessions"),
                           dimensions = c("yearMonth"),
                           anti_sample = TRUE)

gadata

library(dplyr)

#new column added using a calculated field
gadata<- gadata %>% 
  mutate(mom_per_change = 
           (sessions - lag(sessions))/lag(sessions))

gadata

#Plot created to show % change
ggplot(gadata, mapping=aes(x=yearMonth, 
                           y=mom_per_change)) +
  geom_col()

#number format changed to show Y axis as %
ggplot(gadata, mapping=aes(x=yearMonth, 
                           y=mom_per_change)) +
  geom_col() +
  scale_y_continuous(labels = scales::percent)