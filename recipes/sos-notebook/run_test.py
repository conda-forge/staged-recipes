# Test that sos kernel is installed

import jupyter_client

try:
    jupyter_client.kernelspec.get_kernel_spec('sos')
except jupyter_client.kernelspec.NoSuchKernel:
    print('sos kernel was not installed')
    print('The following kernels are installed:')
    print('jupyter_client.kernelspec.find_kernel_specs()')
    print(jupyter_client.kernelspec.find_kernel_specs())

# Test that sos kernel is functional

# https://github.com/jupyter/jupyter_kernel_test

import unittest
import jupyter_kernel_test

class MyKernelTests(jupyter_kernel_test.KernelTests):
    # Required --------------------------------------

    # The name identifying an installed kernel to run the tests against
    kernel_name = "SoS"

    # language_info.name in a kernel_info_reply should match this
    language_name = "sos"

    # Optional --------------------------------------

    # Code in the kernel's language to write "hello, world" to stdout
    code_hello_world = "print('hello, world')"

    # Samples of code which generate a result value (ie, some text
    # displayed as Out[n])
    code_execute_result = [
        {'code': '6*7', 'result': '42'}
    ]

if __name__ == '__main__':
    unittest.main()
