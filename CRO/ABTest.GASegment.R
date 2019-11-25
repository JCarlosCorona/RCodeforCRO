if (!require("pacman")) install.packages("pacman")
pacman::p_load(googleAnalyticsR,
               ggplot2,
               tidyverse)

ga_auth()
1

#Fechas
start_date <- "2019-10-22"
end_date <-  "2019-11-11"     
sampling <-  T

#ID de la vista de GA.
ga.cuentas <- ga_account_list()
#Modificar el regex del nombre la cuenta para obtener el ID dequerido
cuentas <- ga.cuentas %>%
  select(accountName, webPropertyName, viewName, viewId) %>% 
  filter(grepl("coppel",accountName,ignore.case = TRUE))
cuentas
#Colocar el numero de fila de la vista requerida
view.id <- cuentas$viewId[12]

#Segmentos
ga.segs <- ga_segment_list()
segs <- ga.segs %>%
  select(segmentId, name) %>% 
  filter(grepl("DP.B.Precio.D.1",name,ignore.case = TRUE))
segs

seg_obj1 <- segment_ga4(name = segs[1,2], segment_id = segs[1,1])
seg_obj2 <- segment_ga4(name = segs[2,2], segment_id = segs[2,1])

#Metricas
mets <- c("sessions","transactions")
#Dimensiones
dims <- c("date")

# df1 <- dim_filter("pagePath", 
#                  operator = "REGEXP",
#                  expressions = "login")
# df2 <- dim_filter("eventAction", 
#                  operator = "REGEXP",
#                  expressions = "Add to Cart")

# filter1 <- filter_clause_ga4(list(df1), operator = "AND")

ga_data1 <- google_analytics(
  viewId = view.id,
  date_range = c(start_date, end_date),
  metrics = mets,
  dimensions = dims,
  segments = seg_obj1,
  # dim_filters = filter1,
  anti_sample = sampling
)
head(ga_data1)

ga_data2 <- google_analytics(
  viewId = view.id,
  date_range = c(start_date, end_date),
  metrics = mets,
  dimensions = dims,
  segments = seg_obj2,
  # dim_filters = filter1,
  anti_sample = sampling
)
head(ga_data2)