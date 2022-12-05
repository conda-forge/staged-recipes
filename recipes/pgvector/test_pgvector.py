import shutil
import subprocess
import os
import sys

if __name__ == '__main__':
    subprocess.check_call(['initdb', '-D', 'test_db'], env=os.environ)
    subprocess.check_call(['pg_ctl', '-D', 'test_db', '-l', 'test.log', '-o', "-F -p 5434", 'start'], env=os.environ)
    subprocess.check_call(['createuser', f'--username={os.getlogin()}', '-w','--port=5434', '-s', 'postgres'], env=os.environ)
    if sys.platform == 'win32':
        prefix = os.environ.get('LIBRARY_PREFIX')
        pg_regress = "pg_regress"
    else:
        prefix = os.environ.get('PREFIX')
        pg_regress = os.path.join(prefix, 'lib', 'pgxs', 'src', 'test', 'regress', 'pg_regress')
    bin_dir = os.path.expandvars(os.path.join(prefix, 'bin'))
    try:
        subprocess.check_call([pg_regress,'--port=5434', '--inputdir=test', f'--bindir={bin_dir}', 'btree', 'cast', 'copy', 'functions', 'input', 'ivfflat_cosine', 'ivfflat_ip', 'ivfflat_l2', 'ivfflat_options', 'ivfflat_unlogged'], env=os.environ)
    finally:
        subprocess.check_call(['pg_ctl', '-D', 'test_db', 'stop'], env=os.environ)
