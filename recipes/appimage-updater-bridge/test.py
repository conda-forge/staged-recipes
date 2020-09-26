import sys
from PySide2 import QtCore

loader = QtCore.QPluginLoader()
loader.setFileName("libAppImageUpdaterBridge")
loaded = loader.load()
print("plugin loaded: {}".format(loaded))
if not loaded:
	sys.exit(1)