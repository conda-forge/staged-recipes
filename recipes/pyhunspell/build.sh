
# Fix hunalign conda package
if [[ ! -f $PREFIX/lib/libhunspell.so ]]; then
  ln -s $PREFIX/lib/libhunspell{-1.7,}.so
fi
if [[ ! -f $PREFIX/lib/libhunspell.a ]]; then
  ln -s $PREFIX/lib/libhunspell{-1.7,}.a
fi

# We need to set the headers path
INCLUDE_PATH="$PREFIX/include" $PYTHON -m pip install . -vv
