if (!require("pacman")) install.packages("pacman")
pacman::p_load(googleAnalyticsR,
               ggplot2,
               tidyverse)

ga_auth(new_user = F)

#ID de la vista de GA.
ga.cuentas <- ga_account_list()
#Modificar el regex del nombre la cuenta para obtener el ID dequerido
cuentas <- ga.cuentas %>%
  select(accountName, webPropertyName, viewName, viewId) %>% 
  filter(grepl("soriana",accountName,ignore.case = TRUE))
cuentas
#Colocar el numero de fila de la vista requerida
view.id <- cuentas$viewId[1]

start_date <- "2019-01-01"
end_date <-  "2019-07-31"     
sampling <-  FALSE

df1 <- dim_filter("pagePath", 
                 operator = "REGEXP",
                 expressions = "login")
# df2 <- dim_filter("eventAction", 
#                  operator = "REGEXP",
#                  expressions = "Add to Cart")

filter1 <- filter_clause_ga4(list(df1), operator = "AND")

ga_data <- google_analytics(viewId = view.id,
                              date_range = c(start_date, end_date),
                              metrics = c("pageviews","uniquePageviews"),
                              dimensions = c("month"),
                              dim_filters = filter1,
                              anti_sample = sampling)
head(ga_data)

ga_data <-  ga_data[-c(5),]
ga_data

mean(ga_data$pageviews)
