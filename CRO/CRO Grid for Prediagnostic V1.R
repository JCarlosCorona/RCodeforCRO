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

# Configuraciones Globales ---------------------------------------------------------
#Colores personalizados
customGreen0 <- "#DeF7E9"
customGreen <- "#71CA97"
customRed <- "#ff7f7f"
#ID de la vista de GA.
view_id <- 16134042
#Fechas
start_date <- "2019-01-01"
end_date <- "2019-01-31"
#TRUE para dejar el sampleo de la data y FALSE para desactivarlo.
sampling <- FALSE

# Extracción de la Data de la API de Google Analytics ---------------------------------------------------------
df = google_analytics(
  viewId = view_id,
  date_range = c(start_date,
                 end_date),
  metrics = c("sessions",
              "users",
              "pageviews",
              "bounces",
              "avgTimeOnPage",
              "searchSessions",
              "transactions",
              "transactionRevenue",
              "itemQuantity",
              "itemRevenue"),
  dimensions = c("userType",
                 "deviceCategory",
                 "channelGrouping"),
  anti_sample = sampling
)
head(df)

df1 = google_analytics(
  viewId = view_id,
  date_range = c(start_date,
                 end_date),
  metrics = c("percentNewSessions",
              "uniquePurchases"),
  dimensions = c("deviceCategory",
                 "channelGrouping"),
  anti_sample = sampling
)
head(df1)

pivot <- df %>% 
  select(-c(deviceCategory, channelGrouping)) %>% 
  group_by(userType) %>%
  summarise(Sesiones = sum(sessions),
            Usuarios = sum(users),
            Pageviews = sum(pageviews),
            Rebotes = sum(bounces),
            TiempoProm = mean(avgTimeOnPage, na.rm = TRUE),
            Sesiones_Busqueda = sum(searchSessions),
            Transacciones = sum(transactions),
            Revenue = sum(transactionRevenue),
            Cantidad_Productos = sum(itemQuantity),
            Revenue_Productos = sum(itemRevenue)) %>% 
  mutate(Porcentaje_Visitas = round(Sesiones / sum(Sesiones)*100, 2),
         Porcentaje_Rebote = round(Rebotes / Sesiones*100, 2),
         Porcentaje_Busqueda = round(Sesiones_Busqueda / Sesiones*100, 2),
         CR = round(Transacciones / Sesiones*100, 2),
         Ticket_Promedio = round(Revenue_Productos / Cantidad_Productos*100, 2))

head(pivot)
test <- pivot[,c(1,2,12,3,4,13,14,15,8,9,10,16)]
