# From http://zetcode.com/gui/pyqt4/firstprograms/

import sys
from PyQt5 import QtWidgets
from PyQt5.QtCore import QTimer, QUrl
from PyQt5.QtWebKit import QWebSettings
from PyQt5.QtWebKitWidgets import QWebView


def main():

    app = QtWidgets.QApplication(sys.argv)

    web = QWebView()
    settings = web.settings()
    settings.setAttribute(QWebSettings.JavascriptEnabled, True)
    web.load(QUrl("https://www.google.com"))
    web.show()
    web.setWindowTitle("Google Images Redirect")
    web.page().mainFrame().evaluateJavaScript(
        'window.location.href="https://images.google.com/"')

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
