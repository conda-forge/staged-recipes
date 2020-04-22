import netket as nk

# 1D Lattice
g = nk.graph.Hypercube(length=20, n_dim=1, pbc=True)

# Hilbert space of spins on the graph
hi = nk.hilbert.Spin(s=0.5, graph=g)

# Ising spin hamiltonian
ha = nk.operator.Ising(h=1.0, hilbert=hi)

# RBM Spin Machine
ma = nk.machine.RbmSpin(alpha=1, hilbert=hi)
ma.init_random_parameters(seed=1234, sigma=0.01)


# Metropolis Local Sampling
sa = nk.sampler.MetropolisLocal(ma, n_chains=32)

# Optimizer
op = nk.optimizer.Sgd(learning_rate=0.1)

# Stochastic reconfiguration
sr = nk.optimizer.SR(diag_shift=0.1)
gs = nk.Vmc(
    hamiltonian=ha, sampler=sa, optimizer=op, n_samples=10, sr=sr, n_discard=5
)

gs.run(n_iter=3)
