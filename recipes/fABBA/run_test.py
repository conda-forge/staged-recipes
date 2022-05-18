# test the basic functions and load the related packages
import pickle
import numpy as np
from fABBA import fabba_model
from fABBA.load_datasets import load_synthetic_sample

samples = []
for length in np.arange(1000, 3001, 1000, dtype=int):
    ts1 = load_synthetic_sample(length=int(length), freq=10)
    ts2 = load_synthetic_sample(length=int(length), freq=20)
    ts3 = load_synthetic_sample(length=int(length), freq=30)
    samples.append(ts1)
    samples.append(ts2)
    samples.append(ts3)

for i in range(len(samples)):
    fabba = fabba_model(tol=0.1, alpha=0.1, sorting='2-norm', scl=1, verbose=0)
    string = fabba.fit_transform(samples[i])
    inverse_ts = fabba.inverse_transform(string, samples[i][0])

    with open('string'+str(i)+'.pickle', 'wb') as f:
        pickle.dump(string, f, pickle.HIGHEST_PROTOCOL)
    with open('inverse_ts'+str(i)+'.pickle', 'wb') as f:
        pickle.dump(inverse_ts, f, pickle.HIGHEST_PROTOCOL)
    
    with open('string'+str(i)+'.pickle', 'rb') as f:
        string_backup = pickle.load(f)
    with open('inverse_ts'+str(i)+'.pickle', 'rb') as f:
        inverse_ts_backup = pickle.load(f)
        
    assert(string == string_backup)
    assert(inverse_ts == inverse_ts_backup)
    
    
print("Complete!")
