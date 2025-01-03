library(RcppParallel)
library(cppRouting)


RcppParallel::setThreadOptions(numThreads = 2)

edges<-data.frame(from_vertex=c(0,0,1,1,2,2,3,4,4), to_vertex=c(1,3,2,4,4,5,1,3,5), cost=c(9,2,11,3,5,12,4,1,6), dist = c(5,3,4,7,5,5,5,8,7))

graph <- cppRouting::makegraph(edges[,1:3], directed=TRUE, aux = edges\$dist)

nodes <- graph\$dict\$ref

time_mat <- cppRouting::get_distance_pair(graph, from = nodes, to = nodes)
dist_mat <- cppRouting::get_distance_pair(graph, from = nodes, to = nodes, aggregate_aux = TRUE)

stopifnot(all(time_mat == c(0,0,0,0,0,0)))
stopifnot(all(dist_mat == c(0,0,0,0,0,0)))
