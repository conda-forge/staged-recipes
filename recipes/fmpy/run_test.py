import sys
import pytest

if __name__ == '__main__':
  argv = sys.argv + ['tests']
  errors = pytest.main(argv)
  if errors:
    print("THERE HAVE BEEN ERRORS DURING THE TESTS. PLEASE CHECK MANUALLY")
