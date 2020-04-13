library(ergm)
library(sna)
library(latentnet)
library(network)
library(stargazer)
load('./data/dataset_ergmm.RData')



# Q1 ----------------------------------------------------------------------
# change euclidean to inner product

model_1 <- ergmm(net ~ bilinear(d = 2), 
                 control=ergmm.control(burnin=100000,sample.size= 10000,interval=5))

summary(model_1)
plot(model_1, pie = T, main = "Inner Product",  vertex.cex = 2.5)



# Q2 ----------------------------------------------------------------------
# change cluster dimension to 3


model_2_fomula <- formula(net ~ nodematch("white") + nodematch("male") + euclidean(d=2,G=3))
model_2 <- ergmm(model_2_fomula,
                control=ergmm.control(burnin=100000,sample.size= 10000,interval=5), verbose = T)
summary(model_2)
plot(model_2, pie = T,  vertex.cex = 2.5)


