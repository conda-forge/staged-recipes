#include <rtabmap/gui/MainWindow.h>

int main()
{
    using Getter = QString (rtabmap::MainWindow::*)() const;
    volatile Getter getter = &rtabmap::MainWindow::getWorkingDirectory;
    return getter == nullptr;
}
