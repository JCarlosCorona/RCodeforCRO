if (!require("pacman")) install.packages("pacman")
pacman::p_load("curl",
               "devtools",
               "googleAnalyticsR",
               "RAdwords",
               "ggplot2",
               "highcharter")

#1 Authorize GA & GAds----
ga_auth()
gads_auth <- doAuth()

#2 Set the view ID and the date range----
view_id <- Sys.getenv("GA_VIEW_ID")
gads_id <- "654-692-5640"

start_date <- Sys.Date() - 31
end_date <- Sys.Date() - 1


#3 Pull the GA data----
#Filter---
my_dim_filter_object <- dim_filter("sourceMedium", 
                                   operator = "REGEXP",
                                   expressions = "google...cpc")
my_dim_filter_clause <- filter_clause_ga4(list(my_dim_filter_object),
                                          operator = "AND")

ga_data <- google_analytics(viewId = view_id,
                            date_range = c(start_date, end_date),
                            metrics = c("transactions","transactionRevenue"),
                            dimensions = c("adwordsCampaignID", "campaign"),
                            dim_filters = my_dim_filter_clause,
                            anti_sample = FALSE)
head(ga_data)

#4 Pull the GAds data----
body <- statement(select = c("CampaignId",
                             "Impressions",
                             "Clicks",
                             "Cost",
                             "Ctr",
                             "SearchBudgetLostImpressionShare",
                             "SearchRankLostImpressionShare",
                             "ContentBudgetLostImpressionShare",
                             "ContentRankLostImpressionShare"),
                  report = "CAMPAIGN_PERFORMANCE_REPORT",
                  start = start_date,
                  end = end_date)

GAds_Data <- getData(clientCustomerId = gads_id,
                       google_auth = gads_auth,
                       statement = body,
                       transformation = T,
                       apiVersion = "201809")
head(GAds_Data)

#5 Preparing the summary table----
#5.1  Combining data from Google Analytics and Google AdWords in one table
totalData <- merge(ga_data, GAds_Data, by.x = "adwordsCampaignID", by.y = "CampaignID", all.x = TRUE)
head(totalData)
#5.2  Replacing missed values with zeros
for (i in 1:length(totalData)){
  totalData[which(is.na(totalData[i])),i] <- 0
}

#5.3  Final calculations of the number of lost transactions and revenue.
totalData$lostImpressionByBudgetSearch  <- round(totalData$Impressions / (1-totalData$`SearchLostIS(budget)`) - totalData$Impressions,0)
totalData$lostImpressionByRankSearch    <- round(totalData$Impressions / (1-totalData$`SearchLostIS(rank)`) - totalData$Impressions,0)
totalData$lostImpressionByBudgetDisplay <- round(totalData$Impressions / (1-totalData$`ContentLostIS(budget)`) - totalData$Impressions,0)
totalData$lostImpressionByRankDisplay   <- round(totalData$Impressions / (1-totalData$`ContentLostIS(rank)`) - totalData$Impressions,0)
totalData$lostImpressionByBudget        <- totalData$lostImpressionByBudgetSearch + totalData$lostImpressionByBudgetDisplay
totalData$lostImpressionByRank          <- totalData$lostImpressionByRankSearch  + totalData$lostImpressionByRankDisplay
totalData$lostClicksByBudget            <- round(totalData$lostImpressionByBudget * (totalData$CTR),0)
totalData$lostClicksByRank              <- round(totalData$lostImpressionByRank * (totalData$CTR),0)
totalData$lostTransactionsByBudget      <- round(totalData$lostClicksByBudget * (totalData$transactions / totalData$Clicks),0)
totalData$lostTransactionsByRank        <- round(totalData$lostClicksByRank * (totalData$transactions / totalData$Clicks),0)
totalData$lostTransactions              <- totalData$lostTransactionsByBudget + totalData$lostTransactionsByRank
totalData$lostRevenueByBudget           <- round(totalData$lostTransactionsByBudget * (totalData$transactionRevenue / totalData$transactions),0)
totalData$lostRevenueByRank             <- round(totalData$lostTransactionsByRank * (totalData$transactionRevenue / totalData$transactions),0)
totalData$lostRevenue                   <- totalData$lostRevenueByBudget + totalData$lostRevenueByRank

#6. Unloading the calculated table in csv file
write.table(totalData, file="lostRevenue.csv", sep = ";", dec = ",", row.names = FALSE)

#7. Visualization in the form of a pie chart
lost_revenue <- c('received revenue' = sum(totalData$transactionRevenue, na.rm=T), 'lost by budget' =sum(totalData$lostRevenueByBudget, na.rm=T), 'lost by rank' = sum(totalData$lostRevenueByRank, na.rm=T))
pie(lost_revenue,col = c("green", "red", "firebrick"))

HistData <- rbind(data.frame(subset(totalData, select = c("Campaign", "transactionRevenue")), Type = "GottenRevenue"),
setNames(data.frame(subset(totalData, select = c("Campaign", "lostRevenueByBudget")), Type = "LostByBudget"), c("Campaign", "transactionRevenue","Type")),
setNames(data.frame(subset(totalData, select = c("Campaign", "lostRevenueByRank")), Type = "LostByRank"), c("Campaign", "transactionRevenue","Type")))
HistData <- HistData[!is.nan(HistData$transactionRevenue),]

#Building a histogram based on the package ggplot2
ggplot(HistData, aes(x = Campaign, y = transactionRevenue, fill = Type))+
geom_bar(stat = "identity", position = "fill")+
scale_fill_manual(values=c("forestgreen", "firebrick1", "tan1"))+
theme(axis.text.x = element_text(angle = 90, hjust = 1, size = 7))+
ggtitle("Lost Conversion rate")