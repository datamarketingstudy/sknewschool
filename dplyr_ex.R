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

