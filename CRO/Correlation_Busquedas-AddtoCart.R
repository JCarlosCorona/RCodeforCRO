if (!require("pacman"))
  install.packages("pacman")
pacman::p_load(googleAnalyticsR,
               dplyr,
               corrplot,
               tidyverse)

# Configuraciones Globales ---------------------------------------------------------
#ID de la vista de GA.
ga_auth()
ga.cuentas <- ga_account_list()

#Modificar el regex del nombre la cuenta para obtener el ID dequerido
cuentas <- ga.cuentas %>%
  select(accountName, webPropertyName, viewName, viewId) %>% 
  filter(grepl("coppel",accountName,ignore.case = TRUE))
cuentas
#Colocar el numero de fila de la vista requerida
view.id <- cuentas$viewId[9]
#Fechas
start_date <- "2019-07-03"
end_date <- "2019-07-10"

#TRUE para dejar el sampleo de la data y FALSE para desactivarlo.
sampling <- FALSE


# Extracción de la Data de la API de Google Analytics ---------------------------------------------------------
correlation <-  google_analytics(
  viewId = view.id,
  date_range = c(start_date,
                 end_date),
  metrics = c(
    "transactions"),
  dimensions = "date",
  anti_sample = sampling)

head(correlation)

correl.test <- select(correlation, -c(date))
M <- cor(correl.test)

corrplot.mixed(M)
