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


# mutate

## dplyr
temp <- mutate(Trans,
               total_amt2 = Rate*Qty,
               total_amt3 = (Rate*Qty)-(Discount*Qty)
               )

## dplyr + pipe
temp <- Trans %>%
    mutate(total_amt2 = Rate*Qty,
           total_amt3 = (Rate*Qty) - (Discount*Qty))

## base
temp$total_amt2 <- temp$Rate*temp$Qty
temp$total_amt3 <- (temp$Rate * temp$Qty) - (temp$Discount * temp$Qty)

# mutate

### mutate with ifelse

## dplyr
temp <- mutate(Trans,
               Cancel_yn = ifelse(total_amt > 0, "N", "Y"),
               Disc_yn = ifelse(is.na(Discount), "N", "Y"))

## dplyr + pipe
temp <- Trans %>%
    mutate(Cancel_yn = ifelse(total_amt > 0, "N", "Y"),
           Disc_yn = ifelse(is.na(Discount), "N", "Y"))

## base
temp$Cancel_yn <- ifelse(Trans$total_amt > 0, "N", "Y")
temp$Disc_yn <- ifelse(is.na(Trans$Discount), "N", "Y")


# group_by + summarise

store_summary <- Trans %>%
    group_by(Store_type) %>% # Step 1
    summarise(sum_amt = sum(total_amt)) # Step 2
store_summary # Step 3



a <- data.frame(fruit = c('apple', 'banana', 'kiwi'),
                sweet = c(4, 3, 6))

b <- data.frame(fruit = c('peer', 'banana', 'strawberry'),
                sweet = c(3, 3, 7))

a
b


inner_join(a, b, by = c("fruit"))
left_join(a, b, by = c("fruit" = "fruit"))
full_join(a, b, by = c("fruit"))          

semi_join(a, b, by = c("fruit" = "fruit"))
anti_join(a, b, by = c("fruit"))
