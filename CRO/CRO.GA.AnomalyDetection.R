if (!require("pacman")) install.packages("pacman")
pacman::p_load(googleAnalyticsR,
               dplyr,
               corrplot,
               tidyverse,
               anomalize)

ga_auth()

#ID de la vista de GA.
ga.cuentas <- ga_account_list()
#Modificar el regex del nombre la cuenta para obtener el ID dequerido
cuentas <- ga.cuentas %>%
  select(accountName, webPropertyName, viewName, viewId) %>% 
  filter(grepl("coppel",accountName,ignore.case = TRUE))
cuentas
#Colocar el numero de fila de la vista requerida
view.id <- cuentas$viewId[7]

#Fechas del Análisis
start_date <- "2019-08-01"        # 30 days back from yesterday
end_date <- "2019-08-31"          # Yesterday

#Samplig?
sampling <- FALSE

#Filtro de dimensión
my_dim_filter_object <- dim_filter("sourceMedium", 
                                   operator = "REGEXP",
                                   expressions = "google...cpc")

my_dim_filter_clause <- filter_clause_ga4(list(my_dim_filter_object),
                                          operator = "AND")
#Metrica a Análizar
metrica <- "transactions"
#Llamada a la API de GA
ga_data <- google_analytics(viewId = view_id,
                              date_range = c(start_date, end_date),
                              metrics = metrica,
                              dimensions = c("date"),
                              dim_filters = my_dim_filter_clause,
                              anti_sample = sampling)
head(ga_data)

ga.ts <- as_tibble(ga_data)

ga.ts %>% 
  time_decompose(metrica, method = "stl", frequency = "auto", trend = "auto") %>%
  anomalize(remainder, method = "gesd", alpha = 0.05, max_anoms = 0.2) %>%
  plot_anomaly_decomposition()

ga.ts %>% 
  time_decompose(metrica) %>%
  anomalize(remainder) %>%
  time_recompose() %>%
  plot_anomalies(time_recomposed = TRUE, ncol = 3, alpha_dots = 0.5)

ga.anomaly <- ga.ts %>% 
  time_decompose(metrica) %>%
  anomalize(remainder) %>%
  time_recompose() %>%
  filter(anomaly == 'Yes') 
