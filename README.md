# MachineLearning-A2

## Background
What Is a Loan?
The term loan refers to a type of credit vehicle in which a sum of money is lent to another party in exchange for future repayment of the value or principal amount. In many cases, the lender also adds interest or finance charges to the principal value which the borrower must repay in addition to the principal balance.

The Loan Process
Here’s how the loan process works. When someone needs money, they apply for a loan from a bank, corporation, government, or other entity. The borrower may be required to provide specific details such as the reason for the loan, their financial history, and other information.

Based on the applicant’s creditworthiness, the lender either denies or approves the application. The lender must provide a reason should the loan application be denied. If the application is approved, both parties sign a contract that outlines the details of the agreement. The lender advances the proceeds of the loan, after which the borrower must repay the amount including any additional charges such as interest.

## Data
This assignment is based on the data from the Loan data set but the data generating process follows entirely different process. The true data generating process will be shared after the conclusion of this assessment.

See “Data” tab on the kaggle site to download training and test data:

- loan_tr.csv contains the full training set.
- loan_ts.csv contains the test set.
- loan_ts_submission.csv contains a sample submission.

The data contains the following variables:

- Gender specifying whether the applicant is “Female” or “Male”,
- Married specifying whether the applicant is married (“Yes”) or not (“No”),
- Dependents specifying the number of dependent children in the household of the applicant as a categorical variable with levels, 0, 1, 2, and 3+,
- Education specifying whether or not if the applicant has graduated from university (“Graduate”) or not (“Not Graduate”),
- Self_Employed specifying if the individual is self-employed (“Yes”) or not (“No”),
- Area specifies if the applicant lives in the “Rural”, “Semiurban” or “Urban” area.
- Applicant_Income is the income of the applicant
- Coapplicant_Income is the income of the co-applicant (if any)
- Loan_Amount is the amount of money seeked
- Term is the loan period measured in days.
- Credit_History is whether the applicant has a credit history of repaying debts (“1”) or not (“0”)
- Status is a categorical variable of whether the loan was granted (“1”) or not (“0”). This is the variable that you need to predict.
- ID is a unique number to identify the observation in the test set. This variable only appears in the test set.

## Tasks
This is a KaggleInClass challenge, can find at https://www.kaggle.com/competitions/etc32505250-iml-assignment-2. Join this challenge via this link.
The task is to predict the Status of whether the loan was approved or not.
