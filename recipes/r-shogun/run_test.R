library('shogun')

X <- matrix(rnorm(300), 100)
Y <- matrix(rnorm(300), 100) + .5

mmd <- QuadraticTimeMMD()
mmd$set_p(RealFeatures(X))
mmd$set_q(RealFeatures(Y))
mmd$set_kernel(GaussianKernel(32, 1))
mmd$set_num_null_samples(200)
samps <- mmd$sample_null()
stat <- mmd$compute_statistic()
