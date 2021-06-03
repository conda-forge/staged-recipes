import sys
import os


def is_disabled(fname):
    with open(fname) as fh:
        for line in fh:
            if line.startswith('ok=True'):
                return False
    return True


def get_disabled_modules():
    subdir = 'build_info'
    for f in os.listdir(subdir):
        if f.startswith('IMP.'):
            if is_disabled(os.path.join(subdir, f)):
                yield f[4:]


expected_disabled = frozenset(sys.argv[1].split(':'))

disabled = frozenset(get_disabled_modules())

if disabled != expected_disabled:
    raise ValueError("Expecting %s to be disabled, found %s"
                     % (sorted(expected_disabled), sorted(disabled)))
