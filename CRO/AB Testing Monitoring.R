# Carga/Instalacion de Librerias ---------------------------------------------------------
if (!require("pacman"))
  install.packages("pacman")
pacman::p_load("googleAnalyticsR",
               "lubridate",
               "fpp",
               "forecast",
               "ggplot2",
               "gridExtra")
ga_auth()

# Configuraciones Globales ---------------------------------------------------------
#ID de la vista de GA.
view_id <- 53461765
#Fechas
start_date <- "2019-05-09"
end_date <- "2019-05-13"
#Dimension Personalizada de la prueba
custom.dimension.index <- "8"
#Objetivo (KPI primario de la prueba)
n.goal <- "10"
#TRUE para dejar el sampleo de la data y FALSE para desactivarlo.
sampling <- FALSE

# Extracción de la Data de la API de Google Analytics ---------------------------------------------------------
prueba <- paste("dimension", custom.dimension.index, sep = "")
goal.completions <- paste("goal", n.goal, "Completions", sep = "")
goal.cr <- paste("goal", n.goal, "ConversionRate", sep = "")

df = google_analytics(
  viewId = view_id,
  date_range = c(start_date,
                 end_date),
  metrics = c(
    "sessions",
    "percentNewSessions",
    "bounceRate",
    "pageviewsPerSession",
    "avgSessionDuration",
    "transactionsPerSession",
    "transactions",
    "transactionRevenue",
    goal.completions,
    goal.cr
  ),
  dimensions = c("date", prueba),
  anti_sample = sampling
)
head(df)
