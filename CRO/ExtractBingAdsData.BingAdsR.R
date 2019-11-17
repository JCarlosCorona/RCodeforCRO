# library(devtools)
# install_github("ps1982/MicrosoftAdsR")
if (!require("pacman"))
  install.packages("pacman")
pacman::p_load(tidyverse,
               MicrosoftAdsR)

###For authorization and access token###
credentials <- list(
  client_id = "6f6c3340-a65b-473a-8faa-eb4c8618baf8",
  developer_token = "109NJ893O4117054",
  customer_id = "159920785",
  download_location = "C:\\R Data\\Digital Marketing\\Microsoft Ads\\%s",
  filename = "bing_%s_%s_%s_%s_.zip",  #reportid followed by startdate followed by enddate
  startDate = format.Date(Sys.Date() - 7, "%Y-%m-%d"),
  endDate = format.Date(Sys.Date() - 1, "%Y-%m-%d")
)

credentials <- Authentication(credentials)

#####Generate the data

#vector of account ids
accounts <- c(  '2456865'
                ,'157122866'
                ,'149266895'
)

report <- "KeywordPerformanceReportRequest"
columns <- c("TimePeriod", "AccountNumber", "AccountId", "AccountName", "AccountStatus", "Network", "CampaignId", "CampaignStatus", "CampaignName", "AdGroupId","AdGroupName", "AdGroupStatus","KeywordId", "Keyword", "KeywordStatus", "BidMatchType", "DeliveredMatchType", "LandingPageExperience", "QualityImpact","AdRelevance", "AdDistribution", "QualityScore", "Impressions", "Clicks", "Spend", "AveragePosition", "Conversions")

dataList <- list()

for (account_id in accounts){
  dataList[[account_id]] <-
    (account_id=account_id)
  report_id <- getReportId(credentials, report, columns, startDate, endDate)
  downloadUrl <- getDownloadUrl(credentials, report_id)
}