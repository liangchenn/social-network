# NTU ECON7217 
# Problem set 2
# @author : Liang-Cheng Chen <R08323022@ntu.edu.tw>

# set.seed(2)
# required packages -------------------------------------------------------
library(spatialreg)
library(spdep)
library(igraph)
library(ade4)
library(magrittr) # for pipe operator %>%
library(purrr)# for map()
library(stargazer) # for regression table, similar to outreg in stata.

# load data ---------------------------------------------------------------

load('./data/dataset_network_interactions.RData')
set.seed(NULL)
characteristics <- dataset_lecture3[[1]]
adjacency_matrix <- dataset_lecture3[[2]]


# network -----------------------------------------------------------------

network <- graph.adjacency(adjacency_matrix, mode = c('directed'), diag = F, weighted = NULL) # class: edge list
network_nb <- get.edgelist(network) %>% neig(edges = .) %>% neig2nb() # class: neighbor

# assign random link for isolation nodes
# use `purrr::map()` to filter non-connected nodes' index over the list
iso_index <- map_lgl(network_nb, ~ length(.x) == 0) %>% which()


network_nb[iso_index] <- sample(1:336, length(iso_index), replace = T)


# regression preprocessing ------------------------------------------------

# define variable names
variables <- c('gpa', 'smoke_freq', 'drink', 'club', 'exer',
              'male', 'black', 'hisp', 'asian', 'race_other',
              'both_par', 'less_hs', 'more_hs', 'momedu_miss',
              'Prof', 'Home', 'job_other')

# define regression formula

# fmla <- paste0('gpa ~ ', paste0(variables[-1], collapse = ' + ')) %>% as.formula()
fmla <- as.formula("gpa ~ male + black + hisp + asian + race_other + both_par + less_hs + more_hs + momedu_miss + Prof + Home + job_other")



# assign variable names to the characteristics matrix
colnames(characteristics) <- variables
characteristics %<>% as.data.frame()


# supplement network_nb with spatial weight
lw <- nb2listw(network_nb, glist = NULL, style = 'W', zero.policy = T)

binary_lw <- nb2listw(network_nb, style = 'B', glist = NULL, zero.policy = T)


# OLS
model1 <- lm(fmla, data = characteristics)

# Spatial Durbin Model
model2 <- lagsarlm(fmla, data=characteristics, listw=lw, method="eigen",
                   quiet=FALSE, zero.policy = TRUE, tol.solve=1e-13,
                   Durbin = T, type = "mixed")
summary(model2)
# Spatial Durbin Model with binary weight matrix
model3 <- lagsarlm(fmla, data=characteristics, listw=binary_lw, method="eigen",
                   quiet=FALSE, zero.policy = TRUE, tol.solve=1e-13,
                   Durbin = T, type = "mixed")




# Estimations -------------------------------------------------------------
stargazer(model1, model2, model3, type = 'text', column.labels = c('', 'Durbin', 'Durbin (binary)'),
          out = 'output.txt')

