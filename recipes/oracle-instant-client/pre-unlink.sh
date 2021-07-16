pkgver=${PKG_VERSION}
majver=$(echo $pkgver | cut -d'.' -f1)
minver=$(echo $pkgver | cut -d'.' -f2)
uver=${majver}_${minver}

for fname in $(cat ${CONDA_PREFIX}/oracle_instant_client/instantclient_${uver}/CONDA_LINKS); do
  rm -f $fname
done

rm -rf ${CONDA_PREFIX}/oracle_instant_client/instantclient_${uver}
rm -f ${CONDA_PREFIX}/oracle_instant_client/instantclient*${pkgver}*.zip
