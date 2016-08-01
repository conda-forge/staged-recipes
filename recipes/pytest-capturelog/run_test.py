# this test is intended to verify that the plugin has been
#    registered correctly with pytest.
import subprocess
output = subprocess.check_output('py.test -h'.split())
if hasattr(output, 'decode'):
    output = output.decode('utf-8')
assert '--nocapturelog' in output
