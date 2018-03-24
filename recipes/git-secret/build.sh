if [[ $OS == "Windows" ]]; then
  export
  PREFIX=$LIBRARY_PREFIX make git-secret install
else
  make git-secret install
fi
