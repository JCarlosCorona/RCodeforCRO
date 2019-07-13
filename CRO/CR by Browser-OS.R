# Carga/Instalacion de Librerias ---------------------------------------------------------
if (!require("pacman"))
  install.packages("pacman")
pacman::p_load("googleAnalyticsR",
               "lubridate",
               "fpp",
               "forecast",
               "ggplot2",
               "gridExtra",
               "data.table",
               "dplyr",
               "formattable",
               "tidyr",
               "tidyverse")
ga_auth()

ga.cuentas <- ga_account_list()

#Modificar el regex del nombre la cuenta para obtener el ID dequerido
cuentas <- ga.cuentas %>%
  select(accountName, webPropertyName, viewName, viewId) %>% 
  filter(grepl("best",accountName,ignore.case = TRUE))
cuentas
#Colocar el numero de fila de la vista requerida
view.id <- cuentas$viewId[7]

# Configuraciones Globales ---------------------------------------------------------
start.date <- "2019-03-01"
end.date <- "2019-03-31"
#TRUE para dejar el sampleo de la data y FALSE para desactivarlo.
sampling <- FALSE

# Extracción de la Data de la API de Google Analytics (userType)-------------------------
#Dimensiones
dimensions <- c("deviceCategory","browser","operatingSystem")
#Metricas
metrics <- c("sessions",
              "users",
              "pageviews",
              "percentNewSessions",
              "bounceRate",
              "percentSessionsWithSearch",
              "transactionsPerSession",
              "transactions",
              "transactionRevenue")
#Llamada a la API
df <- google_analytics(
  viewId = view.id,
  date_range = c(start.date,
                 end.date),
  metrics = metrics,
  dimensions = dimensions,
  anti_sample = sampling
)
head(df)

browser <- df %>% 
  filter(deviceCategory == "desktop")  %>%
  group_by(browser) %>% 
  summarize( sum(sessions), sum(users), sum(pageviews), mean(percentNewSessions), mean(bounceRate), mean(percentSessionsWithSearch), mean(transactionsPerSession), sum(transactions), sum(transactionRevenue)) %>%
formattable(browser)
