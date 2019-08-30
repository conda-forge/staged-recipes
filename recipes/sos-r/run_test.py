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
            stdout, stderr = assemble_output(kc.iopub_channel)
            self.assertEqual(stdout.strip(), '', f'Stdout is not empty, "{stdout}" received')
            self.assertEqual(stderr.strip(), '', f'Stderr is not empty, "{stderr}" received')
            execute(kc=kc, code='%use R\n%get a\ncat(a)')
            stdout, stderr = assemble_output(kc.iopub_channel)
            self.assertEqual(stderr.strip(), '', f'Stderr is not empty, "{stderr}" received')
            self.assertEqual(stdout.strip(), '1', f'Stdout should be 1, "{stdout}" received')

if __name__ == '__main__':
    unittest.main()
