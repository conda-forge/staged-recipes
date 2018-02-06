if [ "$(uname)" == "Darwin" ]; then
  export LDFLAGS="-rpath ${PREFIX}/lib ${LDFLAGS}"
  export LINKFLAGS="${LDFLAGS}"
fi

$R CMD INSTALL --build .
