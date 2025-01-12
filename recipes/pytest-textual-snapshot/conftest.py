import pytest

def pytest_configure(session):
    if not session.config.pluginmanager.hasplugin("textual-snapshot"):
        raise RuntimeError("The 'textual-snapshot' plugin is not loaded. ")