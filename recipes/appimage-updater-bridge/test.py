import sys
import os
from PySide2 import QtCore

loader = QtCore.QPluginLoader()
loader.setFileName("{}/plugins/libAppImageUpdaterBridge.so".format(os.environ["PREFIX"]))
loaded = loader.load()
print("plugin loaded: {}".format(loaded))
if not loaded:
	sys.exit(1)
