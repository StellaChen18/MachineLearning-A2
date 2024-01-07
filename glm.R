library(tidyverse)
set.seed(32051018)

# Read data
loan_tr <- read_csv("loan_tr.csv") 
#%>% mutate(
 #  Status_loan  = factor(Status, labels = c("G", "N")),
  # Status = ifelse(Status_loan == "G", 1, 0)) #already know whether the loan was granted (“1”) or not (“0”).
loan_ts <- read_csv("loan_ts.csv")

#check NA
#skim(loan_tr, Applicant_Income, Credit_History, Area, Status)

#Logistic regression with a binary response
loan_fit <- glm(Status ~ ., 
                data = loan_tr, 
                family = binomial(link = "logit"))
# Make predictions
#loan_pred <- loan_ts %>%
 # mutate(Status = predict(fit_rf, .)$predictions) %>% 
  #select(ID, Status) #loan_submission3

loan_pred <- loan_ts %>% 
  mutate(Propensity = predict(loan_fit, ., type = 'response'),
         Status = as.numeric(Propensity >= 0.5,
                             levels = c(1, 0))) %>% #Propensity > 0.5-> granted or not?#factor(as.numeric(Propensity > 0.5), levels = c(1, 0))  
  select(ID, Status)

# write to submission
write_csv(loan_pred, file="loan_submission6.csv")
