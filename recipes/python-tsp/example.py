from python_tsp.distances import tsplib_distance_matrix
from python_tsp.heuristics import solve_tsp_local_search, solve_tsp_simulated_annealing

# Get corresponding distance matrix
tsplib_file = "a280.tsp"
distance_matrix = tsplib_distance_matrix(tsplib_file)

# Solve with Local Search using default parameters
permutation, distance = solve_tsp_local_search(distance_matrix)
