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
#Establecer Configuración Regional en Español (para los días de la semana)
Sys.setlocale("LC_TIME", "es_ES.UTF-8")
#ID de la vista de GA.
view_id <- 101577225
#Fechas
start_date <- "2019-01-01"
end_date <- "2019-03-31"
#TRUE para dejar el sampleo de la data y FALSE para desactivarlo.
sampling <- TRUE

# Extracción de la Data de la API de Google Analytics ---------------------------------------------------------
df = google_analytics(
  viewId = view_id,
  date_range = c(start_date,
                 end_date),
  metrics = c("users"),
  dimensions = c("date"),
  anti_sample = sampling
)
head(df)

# Grafico por Día ---------------------------------------------------------------------------------
df$date <- as.Date(df$date, '%Y%m%d')
df$wkd = as.factor(weekdays(df$date))
plot1 <- ggplot(data = df, aes(date, users)) +
  geom_line(color = 'gray50') +
  ggtitle("Usuarios por día") +
  geom_point(colour = "skyblue3", alpha = 0.5) +
  geom_text(
    data = subset(df, wkd == c("S")),
    aes(label = ifelse(substr(wkd, 1, 1) == "S", '')),
    hjust = 0,
    vjust = 0
  ) +
  theme_minimal()
plot1
# Boxplot Días de la Semana ---------------------------------------------------------
df$wkd = factor(
  df$wkd,
  levels = c(
    "lunes",
    "martes",
    "miércoles",
    "jueves",
    "viernes",
    "sábado",
    "domingo"
  )
)

plot2 <- ggplot(df, aes(x = wkd, y = users)) +
  geom_boxplot(
    color = "skyblue3",
    fill = "skyblue3",
    alpha = 0.5,
    outlier.colour = "red",
    outlier.size = 2
  ) +
  geom_jitter(shape = 20, position = position_jitter(0.3)) +
  labs(title = "Usuarios por Día de la Semana", x = "Día de la Semana", y = "Usuarios") + theme_minimal()
plot2
grid.arrange(plot1, plot2, ncol = 1)
#Análisis de Estacionalidad ---------------------------------------------------------
# transform data frame into a time series object
df_ts = ts(df$users, frequency = 7)
# decompose time series and plot results
decomp = decompose(df_ts, type = "additive")
autoplot(decomp) + theme_minimal()