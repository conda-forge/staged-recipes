"""Tests for sphinx-prompt.

Because sphinx-prompt has not unit tests of its own and can't be traditionally
imported (its package name in ``sphinx-prompt``), the strategy here is to
test if Sphinx can load sphinx-prompt as an extension.
"""

from importlib import import_module


def main():
    extension_name = "sphinx-prompt"

    # Test that the extension is importable
    mod = import_module(extension_name)

    # Sphinx extensions need a setup function
    setup = getattr(mod, 'setup', None)
    assert setup is not None


if __name__ == '__main__':
    main()
