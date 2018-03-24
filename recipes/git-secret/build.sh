if [[ $OS == "Windows" ]]; then
  make git-secret install PREFIX=$LIBRARY_PREFIX
else
  make git-secret install
fi
