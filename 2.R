# FIRST SESSION

ls()
rm(list = ls())

source("http://bit.ly/CEU-R-heights-2018")
readLines("http://bit.ly/CEU-R-heights-2018")

## TODO compute the mean of heights
mean(heights, na.rm = TRUE)
rm(h)
## TODO do some dataviz
hist(heights)
library(ggplot2)
ggplot(data.frame(heights),aes(heights)) + geom_histogram()

rm(list = ls())
ls(all.names = TRUE)
.secret

library(data.table) 
?fread 
# VS read.csv 

bookings <- fread('http://bit.ly/CEU-R-hotels-2018-prices')
features <- fread('http://bit.ly/CEU-R-hotels-2018-features')

## SECOND SESSION

## TODO count the number of bookings below 100 EUR
bookings[price <= 100, .N]

## TODO count the number of bookings below 100 EUR without an offer
bookings[price <= 100 & offer == 0, .N]

## TODO compute the average price of the bookings below 100 EUR
bookings[price <= 100, mean(price)]

## TODO compute the average price of bookings on weekends
bookings[weekend == 1, mean(price)]

## TODO compute the average price of bookings on weekdays
bookings[weekend == 0, mean(price)]

## TODO include nnights, holiday and year as well in the aggregate variables
bookings[, .(avg_price = mean(price)), by = list(weekend, nnights, holiday, year)]

## TODO avg price per number of stars
bookings[1]
bookings[hotel_id == 1]
features[hotel_id == 1]
# join: left, right, ...
?merge
#x[y, rolling = ..]
merge(bookings, features)[, mean(price), by = stars]
bookings
# TODO why do we miss 3 rows?
bookings[ls.na(hotel_id)]
bookings[duplicated(hotel_id)]
features[ls.na(hotel_id)]
features[duplicated(hotel_id)]
?duplicated
bookings[!hotel_id %in% features$hotel_id]
features[hotel_id == 2]

merge(bookings, features)
merge(bookings, features, all = TRUE)

merge(bookings, features)[, .(price = mean(price)), by = stars][order(stars)]
merge(bookings, features)[, .(price = mean(price)), by = stars][order(-stars)]
merge(bookings, features)[, .(.N, price = mean(price/nnights)), by = stars][order(stars)]

library(ggplot2)
ggplot(merge(bookings, features)[stars == 2.5], aes(price)) + geom_boxplot()
ggplot(merge(bookings, features)[stars == 2.5], aes(price)) + geom_histogram()

merge(bookings, features)[stars == 2.5][, mean(price), by = nnights]


dt <- merge(bookings, features)
dt$price_per_night <- dt$price / dt$nnights
dt[, price_per_night := price / nnights]

dt[, mean(price_per_night), by = stars][order(stars)]   
dt[, weighted.mean(price_per_night, nnights), by = stars][order(stars)]   

str(dt)

# TODO hotels dataset: features + avg price of a night
hotels <- merge(features, bookings[, .(price_per_night = mean(price/nnights), bookings = .N), 
                                   by = hotel_id])
hotels[, weighted.mean(price_per_night, bookings), by = stars][order(stars)]                

## TODO dataviz on avg price per nights per stars
dta <- hotels[, weighted.mean(price_per_night, bookings), by = stars][order(stars)]
dta <- hotels[, weighted.mean(price_per_night, bookings), by = stars][order(stars)][!is.na(stars)]  
dta <- hotels[!is.na(stars), weighted.mean(price_per_night, bookings), by = stars][order(stars)]
ggplot(dta, aes(stars, V1)) + geom_point()
ggplot(dta, aes(factor(stars), V1)) + geom_point() + xlab("Number of Stars")

## TODO dataviz on avg per nights per stars split by country (facet)
dta <- hotels[!is.na(stars), weighted.mean(price_per_night, bookings), by = .(stars, country)]
[order(stars)]
ggplot(dta, aes(factor(stars), V1)) + geom_point() + xlab("Number of Stars") + 
  facet_wrap(~country, scales = "free")

## TODO aggregated dataset by country: avg price, ratings, stars
countries <- hotels[, .(price = mean(price_per_night, na.rm = TRUE), 
                        ratings = mean(rating, na.rm = TRUE)), by = country]

## TODO list countries with above avg rating
avg_rating <- mean(countries$ratings, na.rm = TRUE)
countries[ratings > mean(ratings, na.rm = TRUE)] 


## THIRD SESSION

