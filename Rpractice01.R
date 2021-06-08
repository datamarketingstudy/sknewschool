install.packages("package_name")
# tidyverse 패키지 
install.packages("tidyverse")


library(pakage_name)
# tidyvers 패키지 사용
library(tidyverse)

data <- read.csv("file_name.csv", header = TRUE, stringsAsFactors = FALSE)
data <- read.csv("file_name.csv", stringsAsFactors = FALSE)

data <- read.csv("file_name.csv", header = FALSE, stringsAsFactors = FALSE)

write.csv(dataset, "file_name.csv")

# load
dataset <- read.table("file_name.txt", header = FALSE, sep = "\t", stringsAsFactors = FALSE)
# save
write.table(dataset, "fileName.txt")


# readxl
library(readxl)
dataset <- read_excel("file_name.xlsx", col_names = FALSE)
# xlsx
library(xlsx)
dataset <- read.xlsx("file_name.xlsx", 1) # 1 대신 "Sheet Name" 가능
write.xlsx(dataset, "file_name.xlsx") # sheet 지정도 가능



