#!/bin/bash 

# Download cpptraj
curl -L -O https://github.com/Amber-MD/cpptraj/archive/18.00.tar.gz
sha256=`openssl dgst -sha256 18.00.tar.gz`
expected_sha256="SHA256(18.00.tar.gz)= e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
if [ "$sha256" != "$expected_sha256" ]
then
    echo "18.00.tar.gz checksum failure"
    exit 1;
fi
tar -xvf 18.00.tar.gz

python -m pip install . --no-deps --ignore-installed --no-cache-dir -vvv
