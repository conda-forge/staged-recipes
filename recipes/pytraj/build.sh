#!/bin/bash 

# Download cpptraj
curl -L -O https://github.com/Amber-MD/cpptraj/archive/18.00.tar.gz
sha256=`openssl dgst -sha256 18.00.tar.gz`
expected_sha256="SHA256(18.00.tar.gz)= 69e781d8ca74ee94b90bf23353b1a894f32a7a0be4f9a6993f7c7f25457ee13b"
if [ "$sha256" != "$expected_sha256" ]
then
    echo "18.00.tar.gz checksum failure"
    exit 1;
fi
tar -xvf 18.00.tar.gz
mv cpptraj-* cpptraj

python -m pip install . --no-deps --ignore-installed --no-cache-dir -vvv
