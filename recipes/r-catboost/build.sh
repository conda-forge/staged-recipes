
if [ "$(uname)" == "Darwin" ]; then
  xcode-select --install
fi

R -e 'devtools::install()'
