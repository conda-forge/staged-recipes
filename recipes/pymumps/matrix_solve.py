import numpy as np
import mumps

# Set up the test problem:
n = 5
irn = np.array([1,2,4,5,2,1,5,3,2,3,1,3], dtype='i')
jcn = np.array([2,3,3,5,1,1,2,4,5,2,3,3], dtype='i')
a = np.array([3.0,-3.0,2.0,1.0,3.0,2.0,4.0,2.0,6.0,-1.0,4.0,1.0], dtype='d')

b = np.array([20.0,24.0,9.0,6.0,13.0], dtype='d')

# Create the MUMPS context and set the array and right hand side
ctx = mumps.DMumpsContext(sym=0, par=1)
if ctx.myid == 0:
    ctx.set_shape(5)
    ctx.set_centralized_assembled(irn, jcn, a)
    x = b.copy()
    ctx.set_rhs(x)

ctx.set_silent() # Turn off verbose output

ctx.run(job=6) # Analysis + Factorization + Solve

assert np.allclose(x, np.array([1.0, 2.0, 3.0, 4.0, 5.0]))

ctx.destroy() # Free memory
