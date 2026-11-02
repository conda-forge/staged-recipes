# Starts TagLab through the installed launcher (offscreen, from another cwd), quits after the main window is up.
import os, sys, tempfile, faulthandler
faulthandler.dump_traceback_later(900, exit=True)
os.environ["QT_QPA_PLATFORM"] = "offscreen"
os.environ["TAGLAB_MODELS"] = tempfile.mkdtemp()
os.chdir(tempfile.mkdtemp())
from PySide6.QtCore import QTimer
from PySide6.QtWidgets import QApplication
orig = QApplication.exec
def ex(*a):
    def up():
        print("MAIN WINDOW UP")
        QApplication.quit()
    QTimer.singleShot(3000, up)
    return orig(*a)
QApplication.exec = staticmethod(ex)
import taglab_launcher
sys.argv = ["taglab"]
try:
    taglab_launcher.main()
except SystemExit as e:
    assert e.code in (0, None), e.code
from source.genutils import modelsDir
assert modelsDir() == os.environ["TAGLAB_MODELS"]
print("OK")
