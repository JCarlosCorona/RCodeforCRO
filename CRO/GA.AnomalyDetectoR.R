if (!require("pacman"))
  install.packages("pacman")
pacman::p_load(googleAnalyticsR,
               tidyverse,
               corrplot,
               anomalize,
               ggplot)

ga_auth()
1

#ID de la vista de GA.
ga.cuentas <- ga_account_list()
#Modificar el regex del nombre la cuenta para obtener el ID requerido
cuentas <- ga.cuentas %>%
  select(accountName, webPropertyName, viewName, viewId) %>%
  filter(grepl("coppel", accountName, ignore.case = TRUE))
cuentas
#Colocar el numero de fila de la vista requerida
view.id <- cuentas$viewId[12]

#Fechas del Análisis
start.date <-   "2019-11-01"
end.date <-     "2019-11-20"
#Metrica a Análizar
metrica <-      "sessions"
#Dimensiones de desglose
dimensiones <-
  c("date",
    "userType",
    "deviceCategory",
    "channelGrouping",
    "region")
#Samplig?
sampling <- T

df1 <- dim_filter("country","REGEXP","m.xico",caseSensitive = F)
d.filter <- filter_clause_ga4(list(df1), operator = "AND")
#Llamada a la API de GA
ga.data <- google_analytics(
  viewId = view.id,
  date_range = c(start.date, end.date),
  metrics = metrica,
  dimensions = dimensiones,
  dim_filters = d.filter,
  max = -1,
  anti_sample = sampling
)
head(ga.data)

#Agrupar y sumar la data por dimensión de análisis
dim <- region
ga.ts <- as_tibble(ga.data)%>%
  group_by(date,region) %>%
  summarise(sessions = sum(sessions))
colnames(ga.ts) <- c("date","dim",metrica)


#Graficar la tendencía y las anomalías
ga.ts %>% group_by(dim) %>%
  time_decompose(metrica, method = "twitter",) %>%
  anomalize(remainder, method = "gesd") %>%
  time_recompose() %>%
  plot_anomalies(time_recomposed = TRUE,
                 ncol = 4,
                 fill_ribbon = "#c3d9e3",
                 alpha_ribbon = 0.5,
                 alpha_dots = 0.7)

#Extraer las anomalías en una tabla
ga.anomaly <- ga.ts %>% group_by(dim) %>% 
  time_decompose(metrica) %>%
  anomalize(remainder) %>%
  time_recompose() %>%
  filter(anomaly == 'Yes')
#Fechas de las anomalías
ga.anomaly %>%
  select(date,dim)