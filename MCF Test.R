install.packages("devtools", dependencies=TRUE, repos='http://cran.rstudio.com/')
library(devtools)
install_github("artemklevtsov/RGA")
library(RGA)
library(googleAnalyticsR)
authorize()
# Set report start and end dates
start_date <- "2018-07-01"
end_date <- "2018-07-31"
# Query MCF API
mcf_data <- get_mcf(profileId = 16134042, 
                    start.date = start_date, end.date = end_date, 
                    metrics = "mcf:totalConversions, mcf:totalConversionValue", 
                    dimensions = "mcf:campaignName", 
                    sort = NULL,
                    filters = "mcf:sourceMediumPath == google / cpc", 
                    samplingLevel = NULL, 
                    start.index = NULL, max.results = NULL,      fetch.by = NULL)

head(mcf_data)