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

#ID de la vista de GA.
ga.cuentas <- ga_account_list()
#Modificar el regex del nombre la cuenta para obtener el ID dequerido
cuentas <- ga.cuentas %>%
  select(accountName, webPropertyName, viewName, viewId) %>% 
  filter(grepl("best",accountName,ignore.case = TRUE))
cuentas
#Colocar el numero de fila de la vista requerida
view.id <- cuentas$viewId[7]

# Configuraciones Globales ---------------------------------------------------------
#Colores personalizados
customGreen0 <- "#DeF7E9"
customGreen <- "#71CA97"
customRed <- "#ff7f7f"
#Fechas
start.date <- "2019-03-01"
end.date <- "2019-03-31"
#TRUE para dejar el sampleo de la data y FALSE para desactivarlo.
sampling <- FALSE

# Extracción de la Data de la API de Google Analytics (userType)-------------------------
#Dimension
dimensions1 <- c("userType")
#Metricas
metrics1 <- c("sessions",
              "users",
              "pageviews",
              "percentNewSessions",
              "bounceRate",
              "percentSessionsWithSearch",
              "transactionsPerSession",
              "transactions",
              "transactionRevenue")
metrics2 <- c("itemQuantity",
              "revenuePerItem",
              "itemsPerPurchase")
metrics3 <- c("pageviewsPerSession",
              "avgTimeOnPage",
              "transactionsPerSession")
#Primera llamada a la API
df1 = google_analytics(
  viewId = view.id,
  date_range = c(start.date,
                 end.date),
  metrics = metrics1,
  dimensions = dimensions1,
  anti_sample = sampling
)
#Segunda llamada a la API
df2 = google_analytics(
  viewId = view.id,
  date_range = c(start.date,
                 end.date),
  metrics = metrics2,
  dimensions = dimensions1,
  anti_sample = sampling
)

segment1 <- segment_ga4("Non-bounce Sessions",
                        segment_id = "gaid::-12")
#Tercera llamada a la API
df3 <- google_analytics(viewId = view.id,
                        date_range = c(start.date,
                                       end.date),
                        metrics =  metrics3,
                        dimensions = dimensions1,
                        segments = segment1,
                        anti_sample = sampling)
df3$segment <-  NULL
df3 <- df3 %>% 
  rename(
    NB.CR = transactionsPerSession
  )
#Unir todos los Data Frames
grid1 <- Reduce(function(x, y) merge(x, y,by = dimensions1), list(df1, df2, df3))
#Modificar el orden y calcular metricas
grid1 <- grid1 %>% 
  mutate(percentVisits = round(sessions / sum(sessions)*100, 2)) %>% 
  select(dimension = dimensions1,
         sessions,
         percentVisits,
         users,
         pageviews,
         percentNewSessions,
         bounceRate,
         NB.PageViewsVisit = pageviewsPerSession,
         NB.AvgTime = avgTimeOnPage,
         percentSessionsWithSearch,
         CR = transactionsPerSession,
         NB.CR,
         transactions,
         transactionRevenue,
         itemQuantity,
         revenuePerItem,
         itemsPerPurchase)
head(grid1)
# Extracción de la Data de la API de Google Analytics (deviceCategory)-----------------
#Dimension
dimensions2 <- c("deviceCategory")
#Son las mismas metricas
#Primera llamada a la API
df4 = google_analytics(
  viewId = view.id,
  date_range = c(start.date,
                 end.date),
  metrics = metrics1,
  dimensions = dimensions2,
  anti_sample = sampling
)
#Segunda llamada a la API
df5 = google_analytics(
  viewId = view.id,
  date_range = c(start.date,
                 end.date),
  metrics = metrics2,
  dimensions = dimensions2,
  anti_sample = sampling
)
#Tercera llamada a la API
df6 <- google_analytics(viewId = view.id,
                        date_range = c(start.date,
                                       end.date),
                        metrics =  metrics3,
                        dimensions = dimensions2,
                        segments = segment1,
                        anti_sample = sampling)
df6$segment <-  NULL
df6 <- df6 %>% 
  rename(
    NB.CR = transactionsPerSession
  )
#Unir todos los Data Frames
grid2 <- Reduce(function(x, y) merge(x, y,by = dimensions2), list(df4, df5, df6))
#Modificar el orden y calcular metricas
grid2 <- grid2 %>% 
  mutate(percentVisits = round(sessions / sum(sessions)*100, 2)) %>% 
  select(dimension = dimensions2,
         sessions,
         percentVisits,
         users,
         pageviews,
         percentNewSessions,
         bounceRate,
         NB.PageViewsVisit = pageviewsPerSession,
         NB.AvgTime = avgTimeOnPage,
         percentSessionsWithSearch,
         CR = transactionsPerSession,
         NB.CR,
         transactions,
         transactionRevenue,
         itemQuantity,
         revenuePerItem,
         itemsPerPurchase)
head(grid2)
# Extracción de la Data de la API de Google Analytics (channelGrouping)----------------
#Dimension
dimensions3 <- c("channelGrouping")
#Son las mismas metricas
#Primera llamada a la API
df7 = google_analytics(
  viewId = view.id,
  date_range = c(start.date,
                 end.date),
  metrics = metrics1,
  dimensions = dimensions3,
  anti_sample = sampling
)
#Segunda llamada a la API
df8 = google_analytics(
  viewId = view.id,
  date_range = c(start.date,
                 end.date),
  metrics = metrics2,
  dimensions = dimensions3,
  anti_sample = sampling
)
#Tercera llamada a la API
df9 <- google_analytics(viewId = view.id,
                        date_range = c(start.date,
                                       end.date),
                        metrics =  metrics3,
                        dimensions = dimensions3,
                        segments = segment1,
                        anti_sample = sampling)
df9$segment <-  NULL
df9 <- df9 %>% 
  rename(
    NB.CR = transactionsPerSession
  )
#Unir todos los Data Frames
grid3 <- Reduce(function(x, y) merge(x, y,by = dimensions3), list(df7, df8, df9))
#Modificar el orden y calcular metricas
grid3 <- grid3 %>% 
  mutate(percentVisits = round(sessions / sum(sessions)*100, 2)) %>% 
  select(dimension = dimensions3,
         sessions,
         percentVisits,
         users,
         pageviews,
         percentNewSessions,
         bounceRate,
         NB.PageViewsVisit = pageviewsPerSession,
         NB.AvgTime = avgTimeOnPage,
         percentSessionsWithSearch,
         CR = transactionsPerSession,
         NB.CR,
         transactions,
         transactionRevenue,
         itemQuantity,
         revenuePerItem,
         itemsPerPurchase)
head(grid3)
# Fusionar los grids y darle formato a la tabla-------------------------------------------
data.grid <- bind_rows(grid1,grid2,grid3)

formattable(data.grid,align =c("r",rep("c", NCOL(data.grid) - 1)), list(
  `dimension` = formatter("span", style = ~ style(color = "black",font.weight = "bold")), 
  area(col = 3:3) ~ function(x) percent(x / 100, digits = 2)))

# area(col = 3:3,row = 1:2) ~ color_tile(customRed, customGreen),

#Opcional Transponer la Tabla
nombres <- data.grid[,1]
t.data.grid <- as.data.frame(t.data.frame(data.grid))
colnames(t.data.grid) <-  nombres
t.data.grid <- t.data.grid[-1,]
formattable(t.data.grid,align = c("r", rep("l", NCOL(t.data.grid) - 1)))
