# Dplyr Package

# install.packages("dplyr")

library(dplyr)

# File Import

Customer <- read.csv("sql_dataset/Customer.csv")
head(Customer)

# rename

temp <- rename(Customer, Birthday = DOB) # dplyr : rename 'DOB' to 'Birthday'
head(temp)

names(temp)[names(temp) == 'Birthday'] <- 'DOB' # base : rename 'Birthday' to 'DOB'
head(temp)

# filter

Trans <- read.csv("sql_dataset/Transactions.csv")
head(Trans)

temp <- filter(Trans, Rate < 5000) # dplyr
head(temp)

temp <- Trans %>% filter(Rate < 5000) # dplyr, pipe
head(temp)

temp <- Trans[Trans$Rate < 5000,] # base
head(temp)

temp <- filter(Trans, Rate > 0 & Rate < 5000) # dplyr
head(temp)

temp <- Trans %>% filter(Rate > 0 & Rate < 5000) # dplyr, pipe
head(temp)

temp <- Trans[((Trans$Rate > 0) & (Trans$Rate < 5000)),] # base
head(temp)

# select

temp <- select(Trans, customer_id, tran_date, total_amt) # dplyr
head(temp)

temp <- Trans %>% select(customer_id, tran_date, total_amt) # dplyr, pipe
head(temp)

temp <- Trans[,c("customer_id", "tran_date", "total_amt")] # base
head(temp)


# arrange

## Ascending ( 1 - 2 - 3)

temp <- arrange(Customer, DOB) # dplyr
head(temp)

temp <- Customer %>% arrange(DOB) # dplyr, pipe
head(temp)

temp <- Customer[order(Customer$DOB),] # base
head(temp)

# arrange

## Descending ( 3 - 2 - 1)

temp <- arrange(Customer, desc(DOB))  # dplyr
head(temp)

temp <- Customer %>% arrange(desc(DOB)) # dplyr, pipe
head(temp)

temp <- Customer[order(Customer$DOB, decreasing = TRUE),]  # base
head(temp)


