# import necessary package
setwd('./hw5/')
library(RSiena)
library(magrittr)
# construct dataset like the demo
# (1) rename datasets
friend.data.w1 <- s501
friend.data.w2 <- s502
friend.data.w3 <- s503
drink <- s50a
smoke <- s50s

# (2) combine friendship network to 3-d array, and set the dependent variable
friendshipData <- array( c( friend.data.w1, friend.data.w2, friend.data.w3 ), dim = c( 50, 50, 3 ) )
friendship <- sienaDependent(friendshipData)

# (3) combine datasets to one siena data
smoke1 <- coCovar( smoke[ , 1 ] )
alcohol <- varCovar( drink )
mydata <- sienaDataCreate( friendship, smoke1, alcohol )


# Problem 1 ---------------------------------------------------------------


# add effects
myeff <- getEffects( mydata )

myeff <- includeEffects( myeff, transTrip, cycle3)
myeff <- includeEffects( myeff, egoX, altX, egoXaltX, interaction1 = "alcohol" )
myeff <- includeEffects( myeff, simX, interaction1 = "smoke1" )
myeff

# a. drop smoke1 similarity
myeff1 <- setEffect(myeff, simX, interaction1 = "smoke1", include = F)
# sienaAlgorithmCreate(projname = 'Drop smoke 1')

res1 <- sienaAlgorithmCreate(projname = 'Smoke Similarity') %>% 
  siena07(data = mydata, effects = myeff1)

res1$tconv.max
summary(res1)

# b. keep only alcohol similarity

myeff2 <- includeEffects(getEffects(mydata), simX, interaction1 = 'alcohol') %>%
  includeEffects(., simX, interaction1 = 'smoke1')

res2 <-  sienaAlgorithmCreate(projname = 'Alcohol Similarity') %>% 
  siena07(data = mydata, effects = myeff2)



# Problem 2 ---------------------------------------------------------------


# 2a.
# Replace the average alter effect by average similarity (avSim)
# or total similarity (totSim) and estimate the model again.
# 2b.
# Add the effect of smoking on drinking and estimate again.

# (a)
drinking <- sienaDependent( drink, type = "behavior" )

NBdata <- sienaDataCreate( friendship, smoke1, drinking )
NBdata
NBeff <- getEffects( NBdata )
# effectsDocumentation(NBeff)
NBeff <- includeEffects( NBeff, transTrip, transRecTrip )
NBeff <- includeEffects( NBeff, egoX, altX, egoXaltX,
                         interaction1 = "drinking" )
NBeff <- includeEffects( NBeff, simX, interaction1 = "smoke1" )

NBeff_avSim  <- includeEffects( NBeff, avSim, name="drinking", interaction1 = "friendship" )
NBeff_totSim <- includeEffects( NBeff, totSim, name="drinking", interaction1 = "friendship" )

myalgorithm1 <- sienaAlgorithmCreate( projname = 's50', doubleAveraging=0)

# estimating the model
NB_avSim  <- siena07(myalgorithm1, data = NBdata, effects = NBeff_avSim)
NB_totSim <- siena07(myalgorithm1, data = NBdata, effects = NBeff_totSim)

# (b) add smoking effect
NBeff_with_smoke  <- includeEffects( NBeff, effFrom, name = 'drinking', interaction1 = "smoke1" )
NB_with_smoke <- siena07(myalgorithm1, data = NBdata, effects = NBeff_with_smoke)






