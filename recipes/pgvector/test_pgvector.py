import shutil
import subprocess
import os

if __name__ == '__main__':
    subprocess.check_call(['initdb', '-D', 'test_db'], env=os.environ)
    subprocess.check_call(['pg_ctl', '-D', 'test_db', '-l', 'test.log', '-o', "-F -p 5434", 'start'], env=os.environ)
    print(shutil.which('pg_ctl'))
    print(shutil.which('pg_regress'))
    print(shutil.which('psql'))
    print(os.getcwd())
    prefix = os.environ.get('LIBRARY_PREFIX')
    bin_dir = os.path.join(prefix, 'bin')
    try:
        subprocess.check_call(["pg_regress",'--port=5434', '--inputdir=test', f'--bindir={bin_dir}', 'btree', 'cast', 'copy', 'functions', 'input', 'ivfflat_cosine', 'ivfflat_ip', 'ivfflat_l2', 'ivfflat_options', 'ivfflat_unlogged'], env=os.environ)
    finally:
        subprocess.check_call(['pg_ctl', '-D', 'test_db', 'stop'], env=os.environ)
