if [[ $OS == "Windows" ]]; then
  export PREFIX=$LIBRARY_PREFIX
  make -e git-secret install
else
  make git-secret install
fi
