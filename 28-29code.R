library(tidyverse)
library(ranger)
library(gbm)
library(xgboost)
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

J <- gbm.perf(loan_boost, method = "cv") # J = 203L when select credict = 1, no filter J = 380L

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


loan_boost2 <- gbm(Status ~ . + Applicant_Income*Credit_History*Dependents,
                  data = loan_tr,
                  distribution = "bernoulli", # binary logistic regression
                  n.trees = 10000,
                  shrinkage = 0.01,
                  interaction.depth = 1,
                  cv.folds = 10)

J2 <- gbm.perf(loan_boost2, method = "cv") # J2=380???

loan_boost_optimal2 <- gbm(Status ~ . + Applicant_Income*Credit_History*Dependents, #J =304L accuracy = ?
                          data = loan_tr,
                          distribution = "bernoulli",
                          n.trees = J2,
                          shrinkage = 0.01,
                          interaction.depth = 1)

loan_pred <- loan_ts %>%
  mutate(prob = predict(loan_boost_optimal2, ., type = "response"),
         Status = factor(ifelse(prob > 0.5, 1, 0))) %>% 
  select(ID, Status)

# write to submission
write_csv(loan_pred, file="loan_submission12.csv") # 0.60621


# xgboost

loan_tr <- read_csv("loan_tr.csv") 
loan_ts <- read_csv("loan_ts.csv")

loan_xgb <- xgboost(data = model.matrix(~ . - Status, data = loan_tr)[, -1], #consider * relation
                    label = loan_tr$Status,
                    max.depth = 2,
                    eta = 0.3, #smaller is good, defult = 0.3, range in (0,1)
                    nrounds = 10,
                    objective = "binary:logistic",
                    verbose = 0)

loan_pred <- loan_ts %>%
  mutate(prob = predict(loan_xgb, model.matrix(~ . - ID, data = .)[, -1]),
         Status = factor(ifelse(prob > 0.5, 1, 0))) %>% 
  select(ID, Status)

# write to submission
write_csv(loan_pred, file="loan_submission13.csv") #0.61139


loan_xgb2 <- xgboost(data = model.matrix(~ . - Status + Applicant_Income*Credit_History*Dependents, data = loan_tr)[, -1], #consider * relation
                    label = loan_tr$Status,
                    max.depth = 2,
                    eta = 0.3, #smaller is good, defult = 0.3, range in (0,1)
                    nrounds = 10,
                    objective = "binary:logistic",
                    verbose = 0)

loan_pred <- loan_ts %>%
  mutate(prob = predict(loan_xgb2, model.matrix(~ . - ID + Applicant_Income*Credit_History*Dependents, data = .)[, -1]),
         Status = factor(ifelse(prob > 0.5, 1, 0))) %>% 
  select(ID, Status)

# write to submission
write_csv(loan_pred, file="loan_submission14.csv") #0.58031


loan_xgb2 <- xgboost(data = model.matrix(~ . - Status, data = loan_tr)[, -1], #consider * relation
                     label = loan_tr$Status,
                     max.depth = 2,
                     eta = 0.4, #smaller is good, defult = 0.3, range in (0,1)
                     nrounds = 10,
                     objective = "binary:logistic",
                     verbose = 0)

loan_pred <- loan_ts %>%
  mutate(prob = predict(loan_xgb2, model.matrix(~ . - ID, data = .)[, -1]),
         Status = factor(ifelse(prob > 0.65, 1, 0))) %>% 
  select(ID, Status)

# write to submission
write_csv(loan_pred, file="loan_submission15.csv") #0.52331

#0429
loan_tr <- read_csv("loan_tr.csv")
loan_ts <- read_csv("loan_ts.csv")

loan_xgb <- xgboost(data = model.matrix(~ . - Status, data = loan_tr)[, -1], #consider * relation
                    label = loan_tr$Status,
                    max.depth = 2,
                    eta = 0.2, #smaller is good, defult = 0.3, range in (0,1)
                    nrounds = 10,
                    objective = "binary:logistic",
                    verbose = 0)

loan_pred <- loan_ts %>%
  mutate(prob = predict(loan_xgb, model.matrix(~ . - ID, data = .)[, -1]),
         Status = factor(ifelse(prob > 0.5, 1, 0))) %>% 
  select(ID, Status)

# write to submission
write_csv(loan_pred, file="loan_submission17.csv") #0.59585 #0.62176 when eta = 0.2 &filter Credit_History == 1
                                                    #0.60621 when eta = 0.2 no filter
