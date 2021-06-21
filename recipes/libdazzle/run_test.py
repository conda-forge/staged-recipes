import gi

gi.require_version("Dazzle", "1.0")
gi.require_version("Gio", "2.0")
from gi.repository import Dazzle, Gio

monitor = Dazzle.RecursiveFileMonitor(root=Gio.File.new_for_path("."))

