import jupyter_client

if "java" not in jupyter_client.kernelspec.find_kernel_specs().keys():
    exit(1)

exit(0)
