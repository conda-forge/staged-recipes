scons \
        --%ARCH% \
        --ssl \
        --prefix=%PREFIX% \
        --cpppath=%LIBRARY_INC% \
        --libpath=%LIBRARY_LIB% \
        --use-system-boost=%LIBRARY_PREFIX% \
        --use-system-pcre=%LIBRARY_PREFIX% \
        --use-system-snappy=%LIBRARY_PREFIX% \
        all

scons \
        --prefix=%PREFIX% \
        install
