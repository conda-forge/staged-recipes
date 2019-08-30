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

import unittest

from sos_notebook.test_utils import sos_kernel
from ipykernel.tests.utils import execute, wait_for_idle, assemble_output

class TestSoSKernel(unittest.TestCase):
    def testKernel(self):
        with sos_kernel() as kc:
            execute(kc=kc, code='a = 1')
            _, _ = assemble_output(kc.iopub_channel)
            execute(kc=kc, code='%use R\n%get a\ncat(a)')
            stdout, _ = assemble_output(kc.iopub_channel)
            self.assertEqual(stdout.strip(), '1')

if __name__ == '__main__':
    unittest.main()
