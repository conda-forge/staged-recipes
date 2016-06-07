# From http://zetcode.com/gui/pyqt4/firstprograms/

import sys
from PyQt5 import QtWidgets
from PyQt5.QtCore import QTimer


def main():

    app = QtWidgets.QApplication(sys.argv)

    w = QtWidgets.QWidget()
    w.resize(250, 150)
    w.move(300, 300)
    w.setWindowTitle('Simple Test')
    w.show()

    def quit_app():
        app.quit()

    close_timer = QTimer()
    close_timer.setInterval(5000)
    close_timer.setSingleShot(True)
    close_timer.timeout.connect(quit_app)
    close_timer.start()

    sys.exit(app.exec_())


if __name__ == '__main__':
    main()
