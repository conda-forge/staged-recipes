import os
import sys
import pytest


def test_import():
    os.environ["DJANGO_SETTINGS_MODULE"] = "quantityfield.settings"
    import django_pint
    import quantityfield


if __name__ == "__main__":
    sys.exit(pytest.main([__file__]))
