import subprocess
import os
import sys

import pgvector  # noqa
import pytest

if __name__ == '__main__':
    subprocess.check_call(['initdb', '-D', 'test_db'], env=os.environ)
    subprocess.check_call(['pg_ctl', '-D', 'test_db', '-l', 'test.log', '-o', "-F -p 5434", 'start'], env=os.environ)
    subprocess.check_call(['createdb', '--port=5434', 'pgvector_python_test'], env=os.environ)
    src_dir = os.path.expandvars(os.environ.get('SRC_DIR'))
    try:
        retcode = pytest.main([os.path.join(src_dir, 'tests')])
    except:
        retcode = 1
    finally:
        subprocess.check_call(['pg_ctl', '-D', 'test_db', 'stop'], env=os.environ)
    sys.exit(retcode)