cmake_minimum_required(VERSION 3.15)

project(chooch VERSION 5.0.9 LANGUAGES C)

find_path(PLPLOT_INCLUDE_DIR NAMES plplot/plplot.h)
include_directories("${PLPLOT_INCLUDE_DIR}/plplot")

set(CHOOCH_SOURCES
    checks.c
    chooch.c
    copyright.c
    fdprime.c
    fits.c
    fluread.c
    integrate.c
    license.c
    minmax.c
    mucal.c
    normalize.c
    parse.c
    plpng.c
    printbanner.c
    savwin.c
    selwavel.c
    smooth.c
    toplot.c
    usage.c
)

add_executable(chooch ${CHOOCH_SOURCES})

target_link_libraries(chooch gsl gslcblas m plplot)


include(GNUInstallDirs)

install(TARGETS
    chooch
    RUNTIME DESTINATION "${CMAKE_INSTALL_FULL_BINDIR}"
)
