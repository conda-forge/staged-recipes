import os
import shutil, tempfile

nbdir = os.path.join('notebooks')

testdir = tempfile.mkdtemp()

def get_notebooks():
    return [f for f in os.listdir(nbdir) if f.endswith('.ipynb')]

def run_notebook(fn):
    pth = os.path.join(nbdir, fn)
    cmd = 'jupyter ' + 'nbconvert ' + \
          '--ExecutePreprocessor.kernel_name=python ' + \
          '--ExecutePreprocessor.timeout=600 ' + '--to ' + 'notebook ' + \
          '--execute ' + '{} '.format(pth) + \
          '--output-dir ' + '{} '.format(testdir) + \
          '--output ' + '{}'.format(fn)
    ival = os.system(cmd)
    assert ival == 0, 'could not run {}'.format(fn)

def test_notebooks():
    files = get_notebooks()

    for fn in files:
        yield run_notebook, fn

if __name__ == '__main__':
    test_notebooks()
    shutil.rmtree(testdir)
