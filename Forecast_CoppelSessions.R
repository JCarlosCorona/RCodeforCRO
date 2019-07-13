# Carga/Instalacion de Librerias ---------------------------------------------------------
if (!require("pacman"))
  install.packages("pacman")
pacman::p_load(googleAnalyticsR,
               dplyr,
               lubridate,
               fpp,
               forecast,
               ggplot2,
               gridExtra,
               prophet,
               highcharter)
ga_auth()

# Configuraciones Globales ---------------------------------------------------------
#Establecer Configuración Regional en Español (para los días de la semana)
Sys.setlocale("LC_TIME", "es_ES.UTF-8")
#Elegir el ID de la vista de GA.
ga.cuentas <- ga_account_list()
cuentas<- ga.cuentas %>%
  select(accountName, webPropertyName, viewName, viewId) %>% 
  filter(grepl("coppel.*",accountName,ignore.case = TRUE))
#Colocar la fila con el ID de la vista
view.id <- cuentas$viewId[9]

#Fechas
start_date <- "2018-05-01"
end_date <- "2019-05-31"
#TRUE para dejar el sampleo de la data y FALSE para desactivarlo.
sampling <- FALSE

# Extracción de la Data de la API de Google Analytics ---------------------------------------------------------
gadata = google_analytics(
  viewId = view.id,
  date_range = c(start_date,
                 end_date),
  metrics = c("sessions"),
  dimensions = c("yearMonth"),
  anti_sample = sampling
)
head(gadata)

# df <- df %>%
#   rename(
#   ds = date,
#   y = users
# )

# Convert the data to be officially "time-series" data
ga_ts <- ts(gadata$sessions, start = c(2017,05), end = c(2019,05), frequency = 12)
# Compute the Holt-Winters filtering for the data
forecast1 <- HoltWinters(ga_ts)
hchart(forecast(forecast1, h = 12))
