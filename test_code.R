# Example analysis
library(tidyverse)
library(ranger)

# Read data
loan_tr <- read_csv("loan_tr.csv") 
loan_ts <- read_csv("loan_ts.csv")

# Fit a basic model
fit_rf <- ranger(Status ~ ., 
                 data = loan_tr,
                 classification = TRUE)

# Make predictions
loan_pred <- loan_ts %>%
  mutate(Status = predict(fit_rf, .)$predictions) %>% 
  select(ID, Status)

# write to submission
write_csv(loan_pred, file="loan_ts_submission.csv")