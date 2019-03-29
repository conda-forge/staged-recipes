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

from ipykernel.tests.utils import execute, wait_for_idle, assemble_output
from sos_notebook.test_utils import sos_kernel

class TestSoSKernel(unittest.TestCase):
    def testKernel(self):
        with sos_kernel() as kc:
            execute(kc=kc, code='a = 1\n')
            wait_for_idle(kc)
            execute(kc=kc, code='%use Python3\n%get a\nb = a + 1')
            wait_for_idle(kc)
            execute(kc=kc, code='%use SoS\n%get b --from Python3\nprint(b)')
            stdout, stderr = assemble_output(kc.iopub_channel)
            self.assertEqual(stderr, '')
            self.assertEqual(stdout.strip(), '2')

if __name__ == '__main__':
    unittest.main()
