# Temporary hacks. Remove after bootstrapping is done

HOST=x86_64-w64-mingw32
if [[ "$target_platform" == "win-64" ]]; then
  cp -r ${PREFIX}/Library/${HOST}/sysroot/usr $PREFIX/Library/ucrt64
else
  ln -sf ${PREFIX}/${HOST}/sysroot/usr ${PREFIX}/${HOST}/sysroot/ucrt64
fi
