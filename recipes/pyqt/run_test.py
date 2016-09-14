import PyQt4.Qt
import PyQt4.QtCore
import PyQt4.QtDeclarative
import PyQt4.QtDesigner
import PyQt4.QtGui
import PyQt4.QtHelp
import PyQt4.QtMultimedia
import PyQt4.QtNetwork
import PyQt4.QtOpenGL
import PyQt4.QtScript
import PyQt4.QtScriptTools
import PyQt4.QtSql
import PyQt4.QtSvg
import PyQt4.QtTest
import PyQt4.QtWebKit  # Disabled on Windows due to VS2015 build issue (linker crash)
import PyQt4.QtXml
import PyQt4.QtXmlPatterns


# From http://zetcode.com/gui/pyqt4/firstprograms/
import os
import sys

from PyQt4 import QtGui

def main():
    app = QtGui.QApplication(sys.argv)
    w = QtGui.QWidget()
    w.resize(250, 150)
    w.move(300, 300)
    w.setWindowTitle('Simple')
    w.show()
    sys.exit(app.exec_())

if int(os.getenv('GUI_TEST', 0)):
    main()
