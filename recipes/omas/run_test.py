import omas, os
if 'USER' not in os.environ:
    os.environ['USER'] = 'TEST_CONDA_USER'
if 'HOME' not in os.environ:
    os.environ['HOME'] = '/tmp'
omas.test_omas_suite()
