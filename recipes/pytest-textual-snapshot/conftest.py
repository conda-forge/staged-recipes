import pytest

def pytest_configure(config):
    if not config.pluginmanager.hasplugin("textual-snapshot"):
        raise RuntimeError("The 'textual-snapshot' plugin is not loaded. ")
