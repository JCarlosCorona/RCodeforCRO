# Carga/Instalacion de Librerias ---------------------------------------------------------
if (!require("pacman"))
  install.packages("pacman")
pacman::p_load("DataExplorer",
               "googleAnalyticsR",
               "lubridate",
               "tidyverse")

ga_auth()

# Configuraciones Globales ---------------------------------------------------------
#ID de la vista de GA.
ga.cuentas <- ga_account_list()
#Modificar el regex del nombre la cuenta para obtener el ID dequerido
cuentas <- ga.cuentas %>%
  select(accountName, webPropertyName, viewName, viewId) %>% 
  filter(grepl("coppel",accountName,ignore.case = TRUE))
cuentas
#Colocar el numero de fila de la vista requerida
view.id <- cuentas$viewId[11]
#Fechas
start.date <- "2019-01-01"
end.date <- "2019-03-31"
#TRUE para dejar el sampleo de la data y FALSE para desactivarlo.
sampling <- FALSE

# Extracción de la Data de la API de Google Analytics ---------------------------------------------------------
EDA = google_analytics(
  viewId = view.id,
  date_range = c(start.date,
                 end.date),
  metrics = c("sessions",
              "users",
              "pageviews",
              "bounces",
              "avgTimeOnPage",
              "searchSessions",
              "transactions",
              "transactionRevenue"),
  dimensions = c("date", 
                 "deviceCategory"),
  anti_sample = sampling)
head(EDA)

plot_str(EDA)
plot_missing(EDA)
plot_histogram(EDA)
plot_density(EDA)
plot_correlation(EDA, type = 'continuous','date')
plot_bar(EDA)
create_report(EDA)
