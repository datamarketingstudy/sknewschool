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
library(rJava)
dataset <- read.xlsx

