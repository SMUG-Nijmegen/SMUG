library(dplyr)

# install.packages("devtools")
devtools::install_github("hadley/multidplyr") # not on CRAN so have to get it from github

library(multidplyr)

load("results_smug.RData")

# a function to calculate the pareto dominance score of each fit

pareto_dominance <- function(x,population=NA){
  library(dplyr) # have to call dplyr again within the function if we want to use it within the function,
                 # since the workers don't get the 'stack' of libraries imported in the script
  
  # Agent A pareto dominates agent B if each and every one of it's scores is better, i.e. 'made at least one richer without making any others poorer'
  # pareto dominance score = number of agents that I dominate - number of agents that dominate me
  
  dominance_syl1 <- x$score_syl1 <= population$score_syl1 # which members of the population am I better than for score_syl1?
  dominance_overlap <- x$score_overlap <= population$score_overlap # which members of the population am I better than for score_overlap?
  dominance_syl2 <- x$score_syl2 <= population$score_syl2 # which members of the population am I better than for score_syl2?

  
  dominance = sum(ifelse(dominance_syl1 & dominance_overlap & dominance_syl2,1,0) + ifelse(!dominance_syl1 & !dominance_overlap & !dominance_syl2,-1,0))
    
  # have to return a dataframe that can be bind_rows'd outside the do
  return(data.frame(dominance=dominance))
}

# single core version

system.time({
  dominance_smug_single_core <- results_smug %>%
    group_by(fingerprint,score_syl1,score_overlap,score_syl2) %>% # group it (so each row is one group, fingerprint is a unique hash)
    do({pareto_dominance(.,results_smug)}) # apply the function to each group
})

# multicore version

system.time({
  clust <- create_cluster(cores = 3) # establish a cluster with 3 cores
  cluster_copy(clust,pareto_dominance) # copy the function to each cluster worker
  cluster_copy(clust,results_smug) # copy the data to each cluster worker
  
  dominance_smug_3core <- results_smug %>%
    partition(cluster = clust) %>% # partition the data arbitrarily across the workers
    group_by(fingerprint,score_syl1,score_overlap,score_syl2) %>% # group it (so each row is one group, fingerprint is a unique hash)
    do({pareto_dominance(.,results_smug)}) %>%
    collect() # collect the results from the workers
  
})

