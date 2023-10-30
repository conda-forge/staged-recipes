mkdir -p "${PREFIX}"/etc/conda/{de,}activate.d/

if [[ "${family}" == "x86_64" ]]; then
  if [[ "${level}" == "1" ]]; then
    flag="-march=x86-64"
  else
    flag="-march=x86-64-v${level}"
  fi
elif [[ "${family}" == "ppc64le" ]]; then
  flag="-mcpu=${level}"
fi

echo 'export CXXFLAGS="${CXXFLAGS} '$flag'"' >> "${PREFIX}"/etc/conda/activate.d/~activate-x86-64-level.sh
echo 'export CFLAGS="${CFLAGS} '$flag'"' >> "${PREFIX}"/etc/conda/activate.d/~activate-x86-64-level.sh
echo 'export CPPFLAGS="${CPPFLAGS} '$flag'"' >> "${PREFIX}"/etc/conda/activate.d/~activate-x86-64-level.sh
chmod +x "${PREFIX}"/etc/conda/activate.d/~activate-x86-64-level.sh
