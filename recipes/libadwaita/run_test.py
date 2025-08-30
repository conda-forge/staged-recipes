import gi
gi.require_version('Adw', '1')
from gi.repository import Adw
import sys

# Test basic libadwaita functionality
try:
    # Initialize libadwaita
    Adw.init()
    
    # Test creating a basic widget
    about_dialog = Adw.AboutDialog()
    if about_dialog is None:
        print("Failed to create AboutDialog")
        sys.exit(1)
    
    # Test setting properties
    about_dialog.set_application_name("Test App")
    app_name = about_dialog.get_application_name()
    if app_name != "Test App":
        print(f"Failed to set/get application name: expected 'Test App', got '{app_name}'")
        sys.exit(1)
    
    print("libadwaita GObject Introspection test passed!")
    
except Exception as e:
    print(f"libadwaita test failed with error: {e}")
    sys.exit(1)
