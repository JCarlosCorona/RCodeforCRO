if (!require("pacman"))
  install.packages("pacman")
pacman::p_load(googleAnalyticsR,
               dplyr,
               corrplot,
               tidyverse,
               googleAuthR)
# Configuraciones Globales ---------------------------------------------------------
#ID de la vista de GA
ga_auth()
ga.cuentas <- ga_account_list()

#Modificar el regex del nombre la cuenta para obtener el ID dequerido
cuentas <- ga.cuentas %>%
  select(accountName, webPropertyName, viewName, viewId) %>% 
  filter(grepl("best",accountName,ignore.case = TRUE))
cuentas
#Colocar el numero de fila de la vista requerida
view.id <- cuentas$viewId[7]

# Queries ---------------------------------------------------------
#Dimensiones
metricas <- c("sessions")
dimensiones <- c("shoppingStage","yearWeek")
#Metricas
#Fechas Query 1
start.date1 <- "2019-06-07"            #"YYYY-MM-DD"
end.date1 <- "2019-08-01"              #"YYYY-MM-DD"

ga.data1 <- google_analytics(viewId = view.id,
                             date_range = c(start.date1, end.date1),
                             metrics = metricas,
                             dimensions = dimensiones,
                             #                            met_filters = my_met_filter_clause,
                             #                            dim_filters = my_dim_filter_clause,
                             anti_sample = T
)
head(ga.data1)

#Fechas Query 2
start.date2 <- "2018-06-08"            #"YYYY-MM-DD"
end.date2 <- "2018-08-02"              #"YYYY-MM-DD"

ga.data2 <- google_analytics(viewId = view.id,
                             date_range = c(start.date2, end.date2),
                             metrics = metricas,
                             dimensions = dimensiones,
                             #                            met_filters = my_met_filter_clause,
                             #                            dim_filters = my_dim_filter_clause,
                             anti_sample = T
)
head(ga.data2)