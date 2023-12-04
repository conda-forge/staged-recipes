import numpy as np
import pygeodesic.geodesic as geodesic

# To read the mesh files provided with the original C++ code:
filename = r'flat_triangular_mesh.txt'
result = geodesic.read_mesh_from_file(filename)
if result:
    points, faces = result

# To calculate the geodesic distance and path between two points (the source and the target) on the mesh:

# Initialise the PyGeodesicAlgorithmExact class instance
geoalg = geodesic.PyGeodesicAlgorithmExact(points, faces)

# Define the source and target point ids with respect to the points array
sourceIndex = 25
targetIndex = 97

# Compute the geodesic distance and the path
distance, path = geoalg.geodesicDistance(sourceIndex, targetIndex)

# To calculate the geodesic distances from a single point (the source point) to all other points on the mesh:
source_indices = np.array([25])
target_indices = None
distances, best_source = geoalg.geodesicDistances(source_indices, target_indices)

# To calculate the geodesic distances from two source points to 3 target points:
source_indices = np.array([25,100]) 
target_indices = np.array([0,10,50])
distances, best_source = geoalg.geodesicDistances(source_indices, target_indices)

print('Test passed!')
