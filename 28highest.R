library(tidyverse)
library(ranger)
library(gbm)
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
                                    ifelse(Dependents == "1", 1, 0)))) %>%
filter(Credit_History == 1)


# optimal boosting

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

loan_boost <- gbm(Status ~ .,
                  data = loan_tr,
                  distribution = "bernoulli", # binary logistic regression
                  n.trees = 10000,
                  shrinkage = 0.01,
                  interaction.depth = 1,
                  cv.folds = 10)

J <- gbm.perf(loan_boost, method = "cv") # J = 203L

loan_boost_optimal <- gbm(Status ~ .,
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
write_csv(loan_pred, file="loan_submission.csv") #0.61658
