if (!require("pacman")) install.packages("pacman")
pacman::p_load("googleAnalyticsR",
               "tidyverse",
               "openxlsx")

ga_auth()

view_id <- 101577225
start_date <- "2019-01-01"
end_date <- "2019-01-31"

sampling <- TRUE
  
#cuentas AW
#UVM <- 6702114222
#UVM_GDN <- 1661478432
#Brandlifts <- 4317381596


my_dim_filter_object <- dim_filter("adwordsCustomerID", 
                                   operator = "REGEXP",
                                   expressions = "1661478432|4317381596")
my_dim_filter_clause <- filter_clause_ga4(list(my_dim_filter_object),
                                          operator = "AND")
#REPORTE DEVICE----
ga_device <- google_analytics(viewId = view_id,
                            date_range = c(start_date, end_date),
                            metrics = c("adCost","adClicks","sessions","bounces","pageviewsPerSession","goal19Completions"),
                            dimensions = c("yearMonth","deviceCategory"),
                            dim_filters = my_dim_filter_clause,
                            anti_sample = sampling)
head(ga_device)

#REPORTE AGE----
ga_age <- google_analytics(viewId = view_id,
                              date_range = c(start_date, end_date),
                              metrics = c("sessions","bounces","pageviewsPerSession","goal19Completions"),
                              dimensions = c("yearMonth","userAgeBracket"),
                              dim_filters = my_dim_filter_clause,
                              anti_sample = sampling)
head(ga_age)

#REPORTE GENDER----
ga_Gender <- google_analytics(viewId = view_id,
                              date_range = c(start_date, end_date),
                              metrics = c("sessions","bounces","pageviewsPerSession","goal19Completions"),
                              dimensions = c("yearMonth","userGender"),
                              dim_filters = my_dim_filter_clause,
                              anti_sample = sampling)
head(ga_Gender)

#REPORTE REGION----
ga_region <- google_analytics(viewId = view_id,
                                  date_range = c(start_date, end_date),
                                  metrics = c("sessions","bounces","pageviewsPerSession","goal19Completions"),
                                  dimensions = c("yearMonth","region"),
                                  dim_filters = my_dim_filter_clause,
                                  anti_sample = TRUE)
head(ga_region)

#REPORTE FORMAT----
ga_campaign <- google_analytics(viewId = view_id,
                              date_range = c(start_date, end_date),
                              metrics = c("adCost","adClicks","sessions","bounces","pageviewsPerSession","goal19Completions"),
                              dimensions = c("yearMonth","campaign"),
                              dim_filters = my_dim_filter_clause,
                              anti_sample = TRUE)
head(ga_campaign)

#REPORTE LANDING----
ga_landing <- google_analytics(viewId = view_id,
                              date_range = c(start_date, end_date),
                              metrics = c("adCost","adClicks","sessions","bounces","pageviewsPerSession","goal19Completions"),
                              dimensions = c("yearMonth","adDestinationUrl"),
                              dim_filters = my_dim_filter_clause,
                              anti_sample = sampling)
head(ga_landing)

#Sum Goal19Completions
sum(ga_device$goal19Completions)
sum(ga_age$goal19Completions)
sum(ga_Gender$goal19Completions)
sum(ga_region$goal19Completions)
sum(ga_campaign$goal19Completions)
sum(ga_landing$goal19Completions)

#REGEX FILTER (Optional)----
#ga_data <- filter(ga_data,(!grepl("Sunday|Saturday", dayOfWeekName)))

#Create Workbook----
OUT <- createWorkbook()

# Add some sheets to the workbook
addWorksheet(OUT, "DEVICE")
addWorksheet(OUT, "AGE")
addWorksheet(OUT, "GENDER")
addWorksheet(OUT, "REGION")
addWorksheet(OUT, "FORMAT")
addWorksheet(OUT, "LANDING")

# Write the data to the sheets
writeData(OUT, sheet = "DEVICE", x = ga_device)
writeData(OUT, sheet = "AGE", x = ga_age)
writeData(OUT, sheet = "GENDER", x = ga_Gender)
writeData(OUT, sheet = "REGION", x = ga_region)
writeData(OUT, sheet = "FORMAT", x = ga_campaign)
writeData(OUT, sheet = "LANDING", x = ga_landing)

# Export the file
saveWorkbook(OUT, "Reportes_UVM_GDN.xlsx", overwrite = TRUE)