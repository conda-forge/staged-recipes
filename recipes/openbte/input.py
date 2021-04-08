from openbte import Geometry, Solver, Material, Plot

Material(temperature=300,model='rta2DSym',n_mfp=100,n_phi=96,mfp_max=100)

l = 100000
a = 30
p = 0.05
Geometry(model="lattice",lx=l,ly=l,step=l/a,porosity=p,shape="circle", base=[[0,0]])

Solver(multiscale=True,multiscale_error_fourier=5e-3,keep_lu=True,verbose=True,max_bte_iter=10,only_fourier=False,experimental_multiscale=True)












