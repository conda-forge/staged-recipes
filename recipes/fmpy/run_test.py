import sys
import pytest

if __name__ == '__main__':
  argv = sys.argv + ['tests']
  sys.exit(pytest.main(argv))
