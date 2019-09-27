#https://cran.r-project.org/web/packages/adwordsR/readme/README.html
library(adwordsR)
library(lubridate)

#Client ID <- 798882676056-92lpn0aq0fqu6dvuukqqi59dsb8hulr9.apps.googleusercontent.com
#Client secret <- 9xjF8phYK4OLmvGP7nCT0gr3
#Developer token <- xGIijZfuBq3rOR2r63wIqw

google_auth <- doAuth()

Google_Ads_ID <- "654-692-5640"
start_date <- "2019-01-01"
end_date <- "2019-01-31"

metrics("CAMPAIGN_PERFORMANCE_REPORT")

body <- statement(select = c("Date",
                             'CampaignName',
                             'Cost',
                             "Impressions",
                             "Clicks"),
                  report = "CAMPAIGN_PERFORMANCE_REPORT",
                  start = start_date,
                  end = end_date)

data <- getData(clientCustomerId = Google_Ads_ID, #use Adwords Account Id (MCC Id will not work)
                google_auth = google_auth,
                statement = body)

head(data)