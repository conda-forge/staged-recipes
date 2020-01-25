import numpy as np
import ncvis
import time

def test_distances():
    np.random.seed(42)
    X = np.random.random((5, 3))
    distances=['euclidean', 'cosine', 'correlation', 'inner_product']
    for distance in distances:
        vis = ncvis.NCVis(n_neighbors=15, M=16, ef_construction=200, random_seed=42,
        n_init_epochs=20, n_epochs=50, min_dist=0.4, n_threads=-1, distance=distance)
        Y = vis.fit_transform(X)
        all_finite = np.all(np.isfinite(Y)) 
        print("Distance:", distance)
        print("Input:")
        print(X)
        print("Output:")
        print(Y)
        assert all_finite, "All entries must be finite"

def test_parallel():
    np.random.seed(42)
    X = np.random.random((10**3, 10))
    distances=['euclidean', 'cosine', 'correlation', 'inner_product']
    n_threads = [1, 2]
    for distance in distances:
        print("Distance:", distance)
        times = {}
        for n_th in n_threads:
            vis = ncvis.NCVis(n_neighbors=15, M=16, ef_construction=200, random_seed=42,
            n_init_epochs=20, n_epochs=50, min_dist=0.4, n_threads=n_th, distance=distance)
            start = time.time()
            Y = vis.fit_transform(X)
            stop  = time.time()
            times[n_th] = stop-start

            print("n_threads = {}, time = {:.2f}s".format(n_th, times[n_th]))
            if n_th > 1:
                eff = times[1]/(times[n_th]*n_th)
                assert eff > 0.3, "Parallelization efficiency is too low"

def test_1d_clustering():
    np.random.seed(42)
    n = 50
    X = np.concatenate((np.random.normal(-1, 1.5, (n, 1)), 
                        np.random.normal( 1, 1.5, (n, 1))))

    vis = ncvis.NCVis(n_neighbors=15, M=16, ef_construction=200, d=1,
                    n_init_epochs=20, n_epochs=50, min_dist=0.4, n_threads=-1, 
                    distance="euclidean", random_seed=42)
    Y = vis.fit_transform(X).ravel()
    n_pos = np.count_nonzero(Y-Y.mean() > 0)
    assert np.abs(n_pos - n) < 5, "Clustering quality is too poor"