qt5-conda-recipe
================

Strategy for a qt5 conda package that can be installed alongside qt(4), largely taken from http://www.linuxfromscratch.org/blfs/view/7.4/x/qt5.html , installing executables to `$PREFIX/qt5/bin` and making links in `$PREFIX/bin` with names like `designer-qt5`. (A different approach is now advocated at http://www.linuxfromscratch.org/blfs/view/7.5/x/qt5.html, where a shell script is used to switch between qt4 and qt5 by modifying the `PATH`.)

The second component of this strategy is a more extensive `qt.conf` in `$PREFIX/bin` and `$PREFIX/lib/qt5/bin`, so all of the appropriate paths can be found. Documentation on the use of `qt.conf` can be found at http://qt-project.org/doc/qt-5/qt-conf.html
