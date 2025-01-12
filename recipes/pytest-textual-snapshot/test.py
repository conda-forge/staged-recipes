import pytest

def test_plugin_installed():
    try:
        # Access pytest's plugin manager
        plugin_manager = pytest.PytestPluginManager()
        # Check if the "textual-snapshot" plugin is registered
        if not plugin_manager.hasplugin("textual-snapshot"):
            raise ImportError("textual-snapshot plugin is not installed or not registered.")
        print("textual-snapshot plugin is installed and registered.")
    except Exception as e:
        print(f"Error: {e}")

# Run the test
test_plugin_installed()
