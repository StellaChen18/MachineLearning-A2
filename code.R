library(tidyverse)
library(ranger)
library(xgboost)
set.seed(32051018)

# Read data and feature engineer variables
loan_tr <- read_csv("loan_tr.csv") %>%
  filter(Credit_History == 1) # Set condition of high Debt-to-Income Ratio

loan_ts <- read_csv("loan_ts.csv")

loan_xgb <- xgboost(data = model.matrix(~ . - Status + Applicant_Income^2, data = loan_tr)[, -1], # Consider the Applicants' income to be the essential index of the model.  
                    label = loan_tr$Status,
                    max.depth = 2,
                    eta = 0.2, #smaller is good, default = 0.3, range in (0,1)
                    nrounds = 10,
                    objective = "binary:logistic",
                    verbose = 0)

loan_pred <- loan_ts %>%
  mutate(prob = predict(loan_xgb, model.matrix(~ . - ID + Applicant_Income^2, data = .)[, -1]),
         Status = factor(ifelse(prob > 0.5, 1, 0))) %>% 
  select(ID, Status)

# write to submission
write_csv(loan_pred, file="submission.csv")