import gi
gi.require_version("Gtk", "4.0")
gi.require_version("Vte", "3.91")
from gi.repository import Vte

Vte.Terminal().set_encoding("utf-8")
