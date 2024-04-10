import urllib.request
from python_tsp.distances import tsplib_distance_matrix
from python_tsp.heuristics import solve_tsp_local_search, solve_tsp_simulated_annealing

# download a tsp file
url_to_a280tsp = 'https://raw.githubusercontent.com/fillipe-gsm/python-tsp/4416f56bed40daa65a7dd159ebfe9512caf942e3/tests/tsplib_data/a280.tsp'
urllib.request.urlretrieve(url_to_a280tsp, 'a280.tsp')

# Get corresponding distance matrix
tsplib_file = "a280.tsp"
distance_matrix = tsplib_distance_matrix(tsplib_file)

# Solve with Local Search using default parameters
permutation, distance = solve_tsp_local_search(distance_matrix)
