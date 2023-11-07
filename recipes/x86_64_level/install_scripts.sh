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

cat << EOF > "${PREFIX}/etc/conda/activate.d/~activate-${family}-level.sh"
export CXXFLAGS="\${CXXFLAGS} ${flag}"
export CFLAGS="\${CFLAGS} ${flag}"
export CPPFLAGS="\${CPPFLAGS} ${flag}"
EOF
