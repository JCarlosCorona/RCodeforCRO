if (!require("pacman"))
  install.packages("pacman")
pacman::p_load("googleAnalyticsR",
               "tidyverse")
## authenticate, 
## or use the RStudio Addin "Google API Auth" with analytics scopes set
ga_auth()

## get your accounts
account_list <- ga_account_list()
filtro.cuenta <- filter(account_list, grepl('bestbuy', accountName,ignore.case = TRUE))
filtro.cuenta$viewName

## pick a profile with data to query

ga_id <- filtro.cuenta[7,'viewId']

## filter pivot results to 
pivme <- pivot_ga4("deviceCategory",
                   metrics = c("sessions"), 
                   maxGroupCount = 10)


pivtest <- google_analytics(ga_id, 
                            c("2019-01-01","2019-03-30"), 
                            dimensions=c('channelGrouping'), 
                            metrics = c('sessions'), 
                            pivots = list(pivme))
head(pivtest)
