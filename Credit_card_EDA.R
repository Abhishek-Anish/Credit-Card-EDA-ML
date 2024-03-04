library(tidyverse)

credit_card_df<-read.csv("customer.csv")

#Exploratory Data Analysis

(df1 <- credit_card_df %>%
    group_by(card_type,customer_status) %>%
    summarise(
      n_customers = n(),
      avg_climit=mean(credit_limit),
      min_income=min(income),
      avg_income=mean(income),
      max_income=max(income)
    ))

ggplot(df1, aes(x = card_type, y = avg_income, fill = customer_status)) +
  geom_bar(stat = "identity", position = position_dodge(),color="black") +
  labs(title = "Average Income",subtitle="by Card Type and Customer Status",
       x = "Card Type",
       y = "Average Income",
       fill="Customer Service")+
  theme_minimal() +coord_flip()

(df2 <- credit_card_df %>%
    group_by(dependents,customer_status) %>%
    summarise(
      n_customers = n()
    ))

ggplot(df2, aes(x = customer_status, y = factor(dependents), fill = n_customers)) +
  geom_tile(color="black") +
  scale_fill_viridis_b() +
  labs(title = "Number of dependants vs Account Status",
       x = "Account Status",
       y = "Number of Dependants", 
       fill = "Number of customers") +
  theme_minimal()

(df3 <- credit_card_df %>%
    group_by(customer_status) %>%
    summarise(
      n_customers = n(),
      avg_num_trans=mean(transactions_last_year),
      avg_total_spend=mean(total_spend_last_year)
    ))

ggplot(credit_card_df, aes(x = transactions_last_year, y = total_spend_last_year, color=customer_status)) +
  geom_point() +
  facet_wrap(~ customer_status)+
  labs(title = "Number of transactions vs.Total Spend Amount",
       x="Number of transactions (Last year) ",
       y="Total Spend Amount (Last year)",
       color="Customer Status")

(df4 <- credit_card_df %>%
    group_by(total_accounts,customer_status) %>%
    summarise(
      n_customers = n(),
    ))


ggplot(data = credit_card_df, mapping = aes(x = customer_status, fill = customer_status)) +
  geom_bar(stat = "count",color="black") + 
  facet_wrap(~ total_accounts, nrow = 1) +
  labs(title = "Customer Status by Number of Accounts", x = " ",
       y = "Number of Customers",fill="Customer Status") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

(df5 <- credit_card_df %>%
    group_by(marital_status,customer_status) %>%
    summarise(
      n_cust = n(),
      avg_TR=mean(transaction_ratio_q4_q1),
      min_TR=min(transaction_ratio_q4_q1),
      max_TR=max(transaction_ratio_q4_q1),
      avg_SR=mean(spend_ratio_q4_q1),
      min_SR=min(spend_ratio_q4_q1),
      max_TR=max(spend_ratio_q4_q1),
    ))

# TR & SR stands for transaction ratio and spend ratio respectively

ggplot(credit_card_df, aes(x = transaction_ratio_q4_q1, y = spend_ratio_q4_q1, color = marital_status)) +
  geom_point(alpha = 0.5) +
  facet_grid(customer_status ~ marital_status) +  # Changed from facet_wrap to facet_grid
  labs(title = "Spend Ratio vs Transaction Ratio by Customer and Marital Status",
       x = "Spend Ratio Q4 to Q1",
       y = "Transaction Ratio Q4 to Q1",
       color = "Marital Status") +
  theme_minimal()