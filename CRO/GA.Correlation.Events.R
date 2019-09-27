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
view.id <- cuentas$viewId[11]
#Fechas
start_date <- "2019-07-05"
end_date <- "2019-07-27"

#TRUE para dejar el sampleo de la data y FALSE para desactivarlo.
sampling <- FALSE


# Extracción de la Data de la API de Google Analytics ---------------------------------------------------------
dimfilter1<- dim_filter("eventCategory", 
                        operator = "REGEXP",
                        expressions = "Detalle producto")
dimfilter2<- dim_filter("eventAction", 
                        operator = "REGEXP",
                        expressions = "Ver otro producto . Seleccionar")
filter <- filter_clause_ga4(list(dimfilter1,dimfilter2),
                            operator = "AND")

events <-  google_analytics(
  viewId = view.id,
  date_range = c(start_date,
                 end_date),
  metrics = c(
    "totalEvents"),
  dimensions = "date",
  dim_filters = filter,
  anti_sample = sampling)

head(events)

correlation <-  google_analytics(
  viewId = view.id,
  date_range = c(start_date,
                 end_date),
  metrics = c(
    "itemRevenue",
    "uniquePurchases",
    "itemQuantity",
    "revenuePerItem",
    "itemsPerPurchase",
    "cartToDetailRate",
    "buyToDetailRate"),
  dimensions = "date",
  anti_sample = sampling)

head(correlation)

events.test  <- select(events, -c(date))
correl.test <- select(correlation, -c(date))
corr <- cbind(events.test,correl.test)
M <- cor(corr)

corrplot.mixed(M)
