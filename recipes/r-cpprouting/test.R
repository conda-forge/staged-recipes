# This test is copied from the help text of get_distance_pair {cppRouting}	

library('cppRouting')

#Choose number of cores used by cppRouting
RcppParallel::setThreadOptions(numThreads = 2)

#Data describing edges of the graph
edges<-data.frame(from_vertex=c(0,0,1,1,2,2,3,4,4),
                  to_vertex=c(1,3,2,4,4,5,1,3,5),
                  cost=c(9,2,11,3,5,12,4,1,6),
                  dist = c(5,3,4,7,5,5,5,8,7))

#Construct directed  graph with travel time as principal weight, and distance as secondary weight
graph <- cppRouting::makegraph(edges[,1:3], directed=TRUE, aux = edges$dist)

#Get all nodes IDs
nodes <- graph$dict$ref

# Get shortest times between all nodes : the result are in time unit
time_mat <- cppRouting::get_distance_pair(graph, from = nodes, to = nodes)

# Get distance according shortest times : the result are in distance unit
dist_mat <- cppRouting::get_distance_pair(graph, from = nodes, to = nodes, aggregate_aux = TRUE)

stopifnot(all(time_mat == dist_mat))
