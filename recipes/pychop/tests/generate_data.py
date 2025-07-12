import numpy as np
from scipy.io import savemat, loadmat
np.set_printoptions(precision=4)
np.random.seed(0)

NB = 10000
test_values = np.random.randn(NB) # Numpy array
print(test_values)

np.random.seed(0)
test_values = np.random.randn(NB)
with open("verified_data.txt", "w") as text_file:
    for val in test_values:
        text_file.write(str(val)+"\n")

savemat("verified_data.mat", {"array": test_values})