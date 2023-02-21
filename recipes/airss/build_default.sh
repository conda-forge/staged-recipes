#!/usr/bin/env bash

mkdir -p ${PREFIX}/bin
for bin in $(cat ${RECIPE_DIR}/airss-bin.txt)
do
  cat > ${PREFIX}/bin/${bin} <<EOF
#!/usr/bin/env bash
exec "${PREFIX}/libexec/airss/${bin}" "$@"
EOF
  chmod +x ${PREFIX}/bin/${bin}
done
