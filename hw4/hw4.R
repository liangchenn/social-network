
# packages ----------------------------------------------------------------
library(ergm)
library(stargazer)


# dataset -----------------------------------------------------------------
data(florentine)


# Problem 1 ---------------------------------------------------------------
# add absolute difference of family wealth

model.baseline <- ergm(flomarriage ~ edges + triangle)
model.1 <- ergm(flomarriage ~ edges + triangle + absdiff("wealth"))

stargazer(model.baseline, model.1, type = 'text')



# Problem 2 ---------------------------------------------------------------
# count 2-stars, 3-stars

# counting k-stars 
summary(flomarriage ~ kstar(2:3))

# model
model.2 <- ergm(flomarriage ~ edges + kstar(2:3))
stargazer(model.baseline, model.1, model.2, type = 'text')
