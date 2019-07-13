#Antes de correr este modelo verificar que la tasa de rebote sea correcta.
#Verificar que los eventos no inflen artificialmente las interacciones.
#Verificar que el las señales de interacción están siendo medidas correctamente (scrolling, 1pag/30min)

#----Carga/Instalacion de Librerias----
if (!require("pacman")) install.packages("pacman")
pacman::p_load("googleAnalyticsR", 
               "tidyverse", 
               "stringr", 
               "lubridate", 
               "ggrepel",
               "scales",
               "highcharter") 
ga_auth()

#----Configuraciones Globales----
#ID de la vista de GA.
ga.cuentas <- ga_account_list()

#Modificar el regex del nombre la cuenta para obtener el ID dequerido
cuentas <- ga.cuentas %>%
  select(accountName, webPropertyName, viewName, viewId) %>% 
  filter(grepl("uvm",accountName,ignore.case = TRUE))
cuentas
#Colocar el numero de fila de la vista requerida
view.id <- cuentas$viewId[2]
#Colocar el periodo adecuado para realizar el análisis en base a las conversiones entre intervalos.
start_date <- today() - 30
end_date <- today() - 1
#TRUE para dejar el sampleo de la data y FALSE para desactivarlo.
sampling <- FALSE

#----Filtros (opcionales)----
dim_filter_object <- dim_filter("deviceCategory", 
                                operator = "REGEXP",
                                expressions = "desktop")
met_filter_object <- met_filter("sessions",
                                "GREATER_THAN",
                                10)

met_filter_clause <- filter_clause_ga4(list(met_filter_object),
                                       operator = "AND")
dim_filter_clause <- filter_clause_ga4(list(dim_filter_object),
                                       operator = "AND")

#----Bounce Layer Model----
dimensiones <- c("channelGrouping","SourceMedium","deviceCategory","landingPagePath")

BLM_1 = google_analytics(
  viewId = view.id,
  date_range = c(start_date , end_date),
  metrics = c("sessions",
              "users",
              "bounceRate",
              "transactions",
              "transactionRevenue"),
  dimensions = dimensiones,
  # met_filters = met_filter_clause,
  # dim_filters = dim_filter_clause,
  anti_sample = sampling)

head(BLM_1)