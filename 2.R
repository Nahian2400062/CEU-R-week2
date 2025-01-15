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
dta <- hotels[!is.na(stars), weighted.mean(price_per_night, bookings), by = .(stars, country)][order(stars)]
ggplot(dta, aes(factor(stars), V1)) + geom_point() + xlab("Number of Stars") + 
  facet_wrap(~country, scales = "free")

## TODO aggregated dataset by country: avg price, ratings, stars
countries <- hotels[, .(price = mean(price_per_night, na.rm = TRUE), 
                        ratings = mean(rating, na.rm = TRUE)), by = country]

## TODO list countries with above avg rating
avg_rating <- mean(countries$ratings, na.rm = TRUE)
countries[ratings > mean(ratings, na.rm = TRUE)] 


## THIRD SESSION
countries[ratings > mean(ratings, na.rm = TRUE)]

hotels[, pricecat := cut(price_per_night, 3)]
hotels[, .N, by = pricecat]

hotels[, pricecat := cut(price_per_night, c(0, 100, 250, Inf), labels = c("cheap", "avg", "expensive"))]
hotels[, .N, by = pricecat]

?quantile
quantile(hotels$price_per_night, c(1/3, 2/3))
lower <- quantile(hotels$price_per_night, 1/3)
upper <- quantile(hotels$price_per_night, 2/3)
hotels[, pricecat := cut(price_per_night, c(0, lower, upper, Inf), 
                         labels = c("cheap", "avg", "expensive"))]
hotels[, pricecat := cut(price_per_night, c(0, quantile(price_per_night, c(1/3, 2/3)), Inf), 
                         labels = c("cheap", "avg", "expensive"))]
hotels[, .N, by = pricecat]


hotels[, lower := quantile(price_per_night, 1/3), by = country]
hotels[, upper := quantile(price_per_night, 1/3), by = country]
rm(lower)
rm(upper) 
hotels[, pricecat := cut(price_per_night, c(0, lower[1], upper[1], Inf), 
                                       labels = c("cheap", "avg", "expensive")), by = country]

cut(hotels[country == "Netherlands", price_per_night], c(0, lower[1], upper[1], Inf))
hotels[upper != lower, pricecat := cut(price_per_night, c(0, lower[1], upper[1], Inf), 
                                       labels = c("cheap","avg","expensive")), by = country]
hotels[upper != lower, .(0, lower[1], upper[1], Inf), by = country]

hotels[, pricecat := NULL]
hotels[upper != lower, pricecat := cut(price_per_night, c(0, lower[1], upper[1], Inf), 
                                       labels = c("cheap", "avg", "expensive")), by = country]

## TODO data.table with x (1:100), y(1:100), color columns (red/white)
# Flag of Japan
points <- data.table(x = rep(1:100, 100), y = rep(1:100, each = 100), col = "white")

points <- data.table(x = rep(1:100, 100), y = rep(1:100, each = 100), col = "white")
points[(x - 50)^2 + (y - 50)^2 < 50, col := "red"]
points[, .N, by = col]

library(ggplot2)
ggplot(points, aes(x, y, color = col)) + geom_point() + theme_void() + 
  scale_color_manual(values = c("red", "white")) + theme(legend.position = "none")

## TODO model: col ~ x +y

?lm
fit <- lm(col ~ x + y, data = points)

points[, col := factor(col)]
fit <- glm(col ~ x + y, data = points, family = binomial(link = logit))
summary(fit)

predict(fit, type = "response")
points$pred <- predict(fit, type = "response")
ggplot(points, aes(x, y, color = factor(round(pred)))) + geom_point() + theme_void() + 
  scale_color_manual(values = c("red", "white")) + theme(legend.position = "none")

library(rpart)
fit <- rpart(col ~ x + y, points)
fit

plot(fit)
text(fit)

?rpart

fit <- rpart(col ~ x + y, points, control = rpart.control(minsplit = 1, cp = 0))

points$pred <- predict(fit, type = "class")
ggplot(points, aes(x, y, color = pred)) + geom_tile() + theme_void() + 
  scale_color_manual(values = c("red", "white")) + theme(legend.position = "none")
ggplot(points, aes(x, y, fill = pred)) + geom_tile() + theme_void() +
  scale_fill_manual(values = c("red", "white")) +
  theme(legend.position = 'none') 
ggplot(points, aes(x, y)) + 
  geom_tile(aes(fill = pred)) + 
  geom_tile(aes(fill = col), alpha = 0.5) + theme_void() +
  scale_fill_manual(values = c("red", "white")) +
  theme(legend.position = 'none')

library(partykit)
plot(as.party(fit))

?rpart

fit <- rpart(col ~ x + y, points, control = ...)


?ctree

library(randomForest)
#h2o

fit <- randomForest(col ~ x + y, points)

points$pred <- predict(fit, type = "class")
ggplot(points, aes(x, y)) + 
  geom_tile(aes(fill = pred)) + 
  geom_tile(aes(fill = col), alpha = 0.5) + theme_void() +
  scale_fill_manual(values = c("red", "white")) +
  theme(legend.position = 'none')
