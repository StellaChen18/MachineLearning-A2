library(tidyverse)
library(rpart)
library(rpart.plot)
set.seed(32051018)

# Read data
loan_tr <- read_csv("loan_tr.csv")
loan_ts <- read_csv("loan_ts.csv")

fit_rpart <- rpart(Status ~ . - Status, data = loan_tr, method = "class")

rpart.plot(fit_rpart)

