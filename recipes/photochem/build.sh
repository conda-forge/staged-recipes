echo "BUILD STARTS HERE"
echo "ls"
ls

if [ -d photochem-${PKG_VERSION}_withdata ]; then
  echo "mv photochem-${PKG_VERSION}_withdata/* ."
  mv photochem-${PKG_VERSION}_withdata/* .
fi

echo "ls"
ls

echo "$PYTHON -m pip install . -vv"
$PYTHON -m pip install . -vv