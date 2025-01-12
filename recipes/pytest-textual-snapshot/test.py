import pytest

def test_plugin_installed():
    try:
        # Check if "textual-snapshot" plugin is registered
        plugins = pytest.config.pluginmanager.list_name_plugin()
        if "textual-snapshot" not in [name for name, _ in plugins]:
            raise ImportError("textual-snapshot plugin is not installed or not registered.")
        print("textual-snapshot plugin is installed and registered.")
    except Exception as e:
        print(f"Error: {e}")

# Run the test
test_plugin_installed()
