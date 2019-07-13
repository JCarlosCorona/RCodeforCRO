#Load the necessary libraries.
if (!require("pacman")) install.packages("pacman")
pacman::p_load(googleAnalyticsR, 
               tidyverse, 
               stringr, 
               lubridate, 
               ggthemes,
               ggrepel,
               scales,
               highcharter) 
ga_auth()

view_id <- 53461765
start_date <- today() - 30
end_date <- today() - 1
sampling <- TRUE

dim_filter_object <- dim_filter("deviceCategory", 
                                   operator = "REGEXP",
                                   expressions = "desktop")
met_filter_object <- met_filter("sessions",
                                "GREATER_THAN",
                                10)

met_filter_clause <- filter_clause_ga4(list(met_filter_object),
                                       operator = "AND")
dim_filter_clause <- filter_clause_ga4(list(dim_filter_object),
                                          operator = "AND")

sources_raw = google_analytics(
  viewId = view_id,
  date_range = c(start_date , end_date),
  metrics = c("sessions",
    "users",
    "transactions",
    "transactionRevenue"),
  dimensions = c("browser"),
  met_filters = met_filter_clause,
  dim_filters = dim_filter_clause,
  anti_sample = sampling)

head(sources_raw)

# now let's make some calculations on the sessions/users share and conversion rates
sources_clean = sources_raw %>%
  mutate(
    session_share = sessions / sum(sessions),
    sales_share = transactions / sum(transactions),
    revenue_share = transactionRevenue / sum(transactionRevenue)
  ) %>%
  arrange(-session_share) %>%
  transmute(
    channel = browser,
    sessions,
    users,
    sales = transactions,
    revenue = transactionRevenue,
    session_share,
    session_addup = cumsum(session_share),
    sales_share,
    sales_addup = cumsum(sales_share),
    revenue_share,
    revenue_addup = cumsum(revenue_share),
    cr_sessions = transactions / sessions,
    cr_users = transactions / users,
    rps = revenue / sessions,
    rpu = revenue / users
  )

head(sources_clean)


sources_clean %>%         # passing our data frame into the plot function
  ggplot(
    aes(                  # specifying which fields should we use for plotting
      x = session_share,
      y = sales_share,
      color = channel
    )
  ) +
  geom_point(alpha = 5/7) # specifying the type of the plot we want

sources_clean %>%
  filter(sales >= 5) %>%   # show only the channels with 10+ sales
  ggplot(
    aes(
      x = session_share,
      y = sales_share,
      color = channel
    )
  ) +
  geom_abline(slope = 1, alpha = 1/10) +
  geom_point(alpha = 5/7) +
  theme_minimal(base_family = "Helvetica Neue") +
  theme(legend.position = "none") +
  scale_x_continuous(name = "Share of sessions", limits = c(0, NA), labels = percent) +
  scale_y_continuous(name = "Share of sales", limits = c(0, NA), labels = percent) +
  scale_color_few(name = "Channel") +
  scale_fill_few() +
  ggtitle(
    "Sessions and sales distribution for top browsers",
    subtitle = "Based on the Google Analytics data"
  ) +
  geom_label_repel(alpha = 1/2, aes(label = channel), show.legend = F)