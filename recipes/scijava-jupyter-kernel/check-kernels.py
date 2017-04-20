from jupyter_client.kernelspec import KernelSpecManager

manager = KernelSpecManager()
kernels = manager.get_all_specs().keys()

assert "scijava-python" in kernels
assert "scijava-groovy" in kernels
assert "scijava-java" in kernels
assert "scijava-clojure" in kernels
assert "scijava-r" in kernels
assert "scijava-scala" in kernels
assert "scijava-beanshell" in kernels
assert "scijava-ruby" in kernels
assert "scijava-javascript" in kernels
