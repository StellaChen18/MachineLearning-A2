library(tidyverse)
library(rpart)
library(ipred)
library(ranger)
library(gbm)
library(xgboost)
library(yardstick)
set.seed(32051018)

# Read data and feature engineer variables
loan_tr <- read_csv("loan_tr.csv") %>%
  mutate(Gender = ifelse(Gender == "Male", 1, 0),
         Married = ifelse(Married == "Yes", 1, 0),
         Education = ifelse(Education == "Graduate", 1, 0),
         Self_Employed = ifelse(Self_Employed == "Yes", 1, 0),
         Area = ifelse(Area == "Urban", 2,
                       ifelse(Area == "Semiurban", 1, 0)),
         Dependents = ifelse(Dependents == "3+", 3,
                             ifelse(Dependents == "2", 2,
                                    ifelse(Dependents == "1", 1, 0))))
  #filter(Credit_History == 1)

loan_ts <- read_csv("loan_ts.csv")%>%
  mutate(Gender = ifelse(Gender == "Male", 1, 0),
         Married = ifelse(Married == "Yes", 1, 0),
         Education = ifelse(Education == "Graduate", 1, 0),
         Self_Employed = ifelse(Self_Employed == "Yes", 1, 0),
         Area = ifelse(Area == "Urban", 2,
                       ifelse(Area == "Semiurban", 1, 0)),
         Dependents = ifelse(Dependents == "3+", 3,
                             ifelse(Dependents == "2", 2,
                                    ifelse(Dependents == "1", 1, 0))))

#skim(loan_tr, Applicant_Income, Coapplicant_Income, Loan_Amount, Term)

#loan_tr <- loan_tr %>% 
 # filter(Applicant_Income >= 385900)

loan_bag <- bagging(Status ~ .,
                     data = loan_tr,
                     nbagg = 1000,
                     control = rpart.control(cp = 0))

loan_pred <- loan_ts %>%
  mutate(prob = predict(loan_bag, ., type = "response"),
         Status = factor(ifelse(prob > 0.5, 1, 0))) %>% 
  select(ID, Status)

# write to submission
write_csv(loan_pred, file="loan_submission8.csv") #0.59585



loan_rf <- ranger(Status ~ ., 
                   data = loan_tr,
                   mtry = floor((ncol(loan_tr) - 1) / 3),
                   importance = "impurity",
                   num.trees = 500,
                   classification = TRUE)


loan_pred <- loan_ts %>%
  mutate(prob = predict(loan_rf, .)$predictions,
         Status = factor(ifelse(prob > 0.5, 1, 0))) %>% 
  select(ID, Status)

# write to submission
write_csv(loan_pred, file="loan_submission9.csv") #0.54922



loan_boost <- gbm(Status ~ .,
                   data = loan_tr,
                   distribution = "bernoulli", # binary logistic regression
                   n.trees = 10000,
                   shrinkage = 0.01,
                   interaction.depth = 1,
                   cv.folds = 10)

loan_pred <- loan_ts %>%
  mutate(prob = predict(loan_boost, ., type = "response"),
         Status = factor(ifelse(prob > 0.5, 1, 0))) %>% 
  select(ID, Status)

# write to submission
write_csv(loan_pred, file="loan_submission10.csv")

J <- gbm.perf(loan_boost, method = "cv") # J = 203L

loan_boost_optimal <- gbm(Status ~ ., #+ Applicant_Income*Credit_History J =380, accuracy = 0.60621
                           data = loan_tr,
                           distribution = "bernoulli",
                           n.trees = J,
                           shrinkage = 0.01,
                           interaction.depth = 1)

loan_pred <- loan_ts %>%
  mutate(prob = predict(loan_boost_optimal, ., type = "response"),
         Status = factor(ifelse(prob > 0.5, 1, 0))) %>% 
  select(ID, Status)

# write to submission
write_csv(loan_pred, file="loan_submission11.csv") #0.61658





loan_xgb <- xgboost(data = model.matrix(~ . - Status, data = loan_tr)[, -1], #consider * relation
                     label = loan_tr$Status,
                     max.depth = 2,
                     eta = 1, #smaller is good, defult = 0.3, range in (0,1)
                     nrounds = 10,
                     objective = "binary:logistic",
                     verbose = 0)

loan_pred <- loan_ts %>%
  mutate(prob = predict(loan_xgb, model.matrix(~ . - ID, data = .)[, -1]),
         Status = factor(ifelse(prob > 0.5, 1, 0))) %>% 
  select(ID, Status)

# write to submission
write_csv(loan_pred, file="loan_submission7.csv") #0.5544

list(bagged = loan_bag,
     randomforest = loan_rf,
     boost = loan_boost_optimal,
     xgboost = loan_xgb) %>% 
  imap_dfr(function(model, name) {
    loan_ts %>% 
      mutate(prob = switch(name,
                           randomforest = predict(model, .)$predictions,
                           xgboost = predict(model, model.matrix(~ . - ID, data = .)[, -1]),
                           predict(model, ., type = "response")),
             Status = factor(ifelse(prob > 0.5, 1, 0)),
             Credit_History = factor(Credit_History)) %>%
      metric_set(accuracy, bal_accuracy, kap, roc_auc)(., Credit_History, prob, estimate = Status, event_level = "second") %>% 
      mutate(name = name) %>% 
      pivot_wider(id_cols = name, names_from = .metric, values_from = .estimate)
  })

