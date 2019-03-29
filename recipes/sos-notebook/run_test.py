# Test that sos kernel is installed

import jupyter_client

try:
    jupyter_client.kernelspec.get_kernel_spec('sos')
except jupyter_client.kernelspec.NoSuchKernel:
    print('sos kernel was not installed')
    print('The following kernels are installed:')
    print('jupyter_client.kernelspec.find_kernel_specs()')
    print(jupyter_client.kernelspec.find_kernel_specs())
