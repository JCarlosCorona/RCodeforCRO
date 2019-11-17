# library(devtools)
# install_github("Deducive/FBinsightsR")
if (!require("pacman"))
  install.packages("pacman")
pacman::p_load(tidyverse,
               FBinsightsR)

report.level <-  c("ad", "adset", "campaign","account")

start.date <- "2019-01-20"
end.date <- "2019-01-30"
level <- report.level[3]
token <- "EAAEY7njrS3IBAJ6m7Ghrk1jxtZAo1KN3WAHZBFwGRW02kxCy8ZAoT1dPOGqelkwhyQx9FF3zMSx5VQMZBdfsnQebkgjyHuoZB1cZCWgxClNbCuAjyr9qy3DMOVsfkTU1OTswJa42xG0meXTHubTMF7GDHkLx0uJfHMSKF91jmqR4xUwfgzKPZCTrU6JJCZC6FpbupJ4HtRAN4iDfhhYBzZCFyKx6HOKhGTdkZD"
cuenta <- paste("act_",2210499132335057,sep = "")

FBData <- fbins_summ(
  start_date = start.date,
  until_date = end.date,
  report_level = level,
  time_increment = "1",
  fb_access_token = token,
  account = cuenta
)

FBAgeGender <-
  fbins_ag(
    start_date = start.date,
    until_date = end.date,
    report_level = level,
    fb_access_token = token,
    account = cuenta
  )