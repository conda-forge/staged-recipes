import gi
gi.require_version("Gtk", "4.0")
gi.require_version("Vte", "3.91")
from gi.repository import Vte

# Note: cannot instantiate without a X server
# otherwise, it leads to segfault
# Vte.Terminal().set_encoding("utf-8")
