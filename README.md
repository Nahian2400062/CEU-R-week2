# CEU-R-week2

I will upload R materials here.

ls() 
rm(list = ls()) 
source("http://bit.ly/CEU-R-heights-2018") 
readLines("http://bit.ly/CEU-R-heights-2018") 

## TODO compute the mean of heights 
mean(heights, na.rm = TRUE) 

## TODO do some dataviz 
hist(heights) 
library(ggplot2) 
ggplot(data.frame(heights), aes(heights)) + geom_histogram() 
rm(list = ls()) 
ls(all.names = TRUE) 
.secret

library(data.table) 
?fread # VS read.csv 
bookings <- fread('http://bit.ly/CEU-R-hotels-2018-prices')

features <- fread('http://bit.ly/CEU-R-hotels-2018-features')
