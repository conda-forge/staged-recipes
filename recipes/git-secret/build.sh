if [[ $OS == "Windows" ]]; then
  PREFIX=$LIBRARY_PREFIX make git-secret install
else
  make git-secret install
fi
