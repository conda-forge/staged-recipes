#!/bin/bash

set -xe

wolfssl-config --help

pkg-config --print-provides "$PKG_NAME"
pkg-config --exact-version="$PKG_VERSION" "$PKG_NAME"

# existence check the contents 
files=( \
lib/libwolfssl.so.32.0.0 \
lib/libwolfssl.so.32 \
lib/libwolfssl.so \
lib/pkgconfig/wolfssl.pc \
lib/libwolfssl.a \
include/wolfssl/openssl/ui.h \
include/wolfssl/openssl/ssl23.h \
include/wolfssl/openssl/opensslconf.h \
include/wolfssl/openssl/engine.h \
include/wolfssl/openssl/cms.h \
include/wolfssl/openssl/camellia.h \
include/wolfssl/openssl/srp.h \
include/wolfssl/openssl/ossl_typ.h \
include/wolfssl/openssl/asn1t.h \
include/wolfssl/openssl/rand.h \
include/wolfssl/openssl/tls1.h \
include/wolfssl/openssl/ec448.h \
include/wolfssl/openssl/ec25519.h \
include/wolfssl/openssl/x509_vfy.h \
include/wolfssl/openssl/obj_mac.h \
include/wolfssl/openssl/ed448.h \
include/wolfssl/openssl/ecdh.h \
include/wolfssl/openssl/ed25519.h \
include/wolfssl/openssl/ripemd.h \
include/wolfssl/openssl/md4.h \
include/wolfssl/openssl/buffer.h \
include/wolfssl/openssl/pkcs12.h \
include/wolfssl/openssl/modes.h \
include/wolfssl/openssl/rc4.h \
include/wolfssl/openssl/stack.h \
include/wolfssl/openssl/lhash.h \
include/wolfssl/openssl/cmac.h \
include/wolfssl/openssl/txt_db.h \
include/wolfssl/openssl/compat_types.h \
include/wolfssl/openssl/err.h \
include/wolfssl/openssl/opensslv.h \
include/wolfssl/openssl/objects.h \
include/wolfssl/openssl/x509.h \
include/wolfssl/openssl/ecdsa.h \
include/wolfssl/openssl/md5.h \
include/wolfssl/openssl/aes.h \
include/wolfssl/openssl/hmac.h \
include/wolfssl/openssl/pkcs7.h \
include/wolfssl/openssl/ocsp.h \
include/wolfssl/openssl/conf.h \
include/wolfssl/openssl/des.h \
include/wolfssl/openssl/dh.h \
include/wolfssl/openssl/fips_rand.h \
include/wolfssl/openssl/sha3.h \
include/wolfssl/openssl/crypto.h \
include/wolfssl/openssl/dsa.h \
include/wolfssl/openssl/x509v3.h \
include/wolfssl/openssl/bio.h \
include/wolfssl/openssl/asn1.h \
include/wolfssl/openssl/sha.h \
include/wolfssl/openssl/bn.h \
include/wolfssl/openssl/rsa.h \
include/wolfssl/openssl/pem.h \
include/wolfssl/openssl/ec.h \
include/wolfssl/openssl/evp.h \
include/wolfssl/openssl/ssl.h \
include/wolfssl/version.h \
include/wolfssl/crl.h \
include/wolfssl/wolfcrypt/compress.h \
include/wolfssl/wolfcrypt/md2.h \
include/wolfssl/wolfcrypt/md4.h \
include/wolfssl/wolfcrypt/arc4.h \
include/wolfssl/wolfcrypt/ripemd.h \
include/wolfssl/wolfcrypt/rc2.h \
include/wolfssl/wolfcrypt/cpuid.h \
include/wolfssl/wolfcrypt/ge_448.h \
include/wolfssl/wolfcrypt/pkcs12.h \
include/wolfssl/wolfcrypt/fips_test.h \
include/wolfssl/wolfcrypt/visibility.h \
include/wolfssl/wolfcrypt/coding.h \
include/wolfssl/wolfcrypt/signature.h \
include/wolfssl/wolfcrypt/ge_operations.h \
include/wolfssl/wolfcrypt/blake2.h \
include/wolfssl/wolfcrypt/pwdbased.h \
include/wolfssl/wolfcrypt/wolfmath.h \
include/wolfssl/wolfcrypt/mpi_superclass.h \
include/wolfssl/wolfcrypt/cmac.h \
include/wolfssl/wolfcrypt/siphash.h \
include/wolfssl/wolfcrypt/chacha.h \
include/wolfssl/wolfcrypt/kdf.h \
include/wolfssl/wolfcrypt/wolfevent.h \
include/wolfssl/wolfcrypt/poly1305.h \
include/wolfssl/wolfcrypt/md5.h \
include/wolfssl/wolfcrypt/camellia.h \
include/wolfssl/wolfcrypt/misc.h \
include/wolfssl/wolfcrypt/falcon.h \
include/wolfssl/wolfcrypt/blake2-impl.h \
include/wolfssl/wolfcrypt/fe_448.h \
include/wolfssl/wolfcrypt/dsa.h \
include/wolfssl/wolfcrypt/wc_encrypt.h \
include/wolfssl/wolfcrypt/curve448.h \
include/wolfssl/wolfcrypt/des3.h \
include/wolfssl/wolfcrypt/chacha20_poly1305.h \
include/wolfssl/wolfcrypt/blake2-int.h \
include/wolfssl/wolfcrypt/dh.h \
include/wolfssl/wolfcrypt/sha.h \
include/wolfssl/wolfcrypt/sha3.h \
include/wolfssl/wolfcrypt/curve25519.h \
include/wolfssl/wolfcrypt/eccsi.h \
include/wolfssl/wolfcrypt/hmac.h \
include/wolfssl/wolfcrypt/ed448.h \
include/wolfssl/wolfcrypt/logging.h \
include/wolfssl/wolfcrypt/hash.h \
include/wolfssl/wolfcrypt/ed25519.h \
include/wolfssl/wolfcrypt/sakke.h \
include/wolfssl/wolfcrypt/fe_operations.h \
include/wolfssl/wolfcrypt/random.h \
include/wolfssl/wolfcrypt/sha256.h \
include/wolfssl/wolfcrypt/sha512.h \
include/wolfssl/wolfcrypt/memory.h \
include/wolfssl/wolfcrypt/srp.h \
include/wolfssl/wolfcrypt/mem_track.h \
include/wolfssl/wolfcrypt/error-crypt.h \
include/wolfssl/wolfcrypt/cryptocb.h \
include/wolfssl/wolfcrypt/rsa.h \
include/wolfssl/wolfcrypt/integer.h \
include/wolfssl/wolfcrypt/aes.h \
include/wolfssl/wolfcrypt/pkcs7.h \
include/wolfssl/wolfcrypt/mpi_class.h \
include/wolfssl/wolfcrypt/tfm.h \
include/wolfssl/wolfcrypt/ecc.h \
include/wolfssl/wolfcrypt/asn_public.h \
include/wolfssl/wolfcrypt/wc_port.h \
include/wolfssl/wolfcrypt/types.h \
include/wolfssl/wolfcrypt/settings.h \
include/wolfssl/wolfcrypt/asn.h \
include/wolfssl/callbacks.h \
include/wolfssl/sniffer_error.h \
include/wolfssl/ocsp.h \
include/wolfssl/sniffer.h \
include/wolfssl/error-ssl.h \
include/wolfssl/wolfio.h \
include/wolfssl/test.h \
include/wolfssl/ssl.h \
include/wolfssl/certs_test.h \
include/cyassl/test.h \
include/cyassl/openssl/ed448.h \
include/cyassl/openssl/ec448.h \
include/cyassl/openssl/ec25519.h \
include/cyassl/openssl/ed25519.h \
include/cyassl/openssl/ec.h \
include/cyassl/openssl/ui.h \
include/cyassl/openssl/bn.h \
include/cyassl/openssl/dh.h \
include/cyassl/openssl/sha.h \
include/cyassl/openssl/err.h \
include/cyassl/openssl/pem.h \
include/cyassl/openssl/md4.h \
include/cyassl/openssl/rand.h \
include/cyassl/openssl/x509.h \
include/cyassl/openssl/bio.h \
include/cyassl/openssl/ocsp.h \
include/cyassl/openssl/md5.h \
include/cyassl/openssl/asn1.h \
include/cyassl/openssl/ecdh.h \
include/cyassl/openssl/conf.h \
include/cyassl/openssl/lhash.h \
include/cyassl/openssl/ecdsa.h \
include/cyassl/openssl/ssl23.h \
include/cyassl/openssl/stack.h \
include/cyassl/openssl/pkcs12.h \
include/cyassl/openssl/ripemd.h \
include/cyassl/openssl/x509v3.h \
include/cyassl/openssl/crypto.h \
include/cyassl/openssl/engine.h \
include/cyassl/openssl/ossl_typ.h \
include/cyassl/openssl/opensslv.h \
include/cyassl/openssl/opensslconf.h \
include/cyassl/openssl/rsa.h \
include/cyassl/openssl/dsa.h \
include/cyassl/openssl/des.h \
include/cyassl/openssl/hmac.h \
include/cyassl/openssl/ssl.h \
include/cyassl/openssl/evp.h \
include/cyassl/certs_test.h \
include/cyassl/crl.h \
include/cyassl/ocsp.h \
include/cyassl/sniffer.h \
include/cyassl/error-ssl.h \
include/cyassl/callbacks.h \
include/cyassl/sniffer_error.h \
include/cyassl/ctaocrypt/mpi_class.h \
include/cyassl/ctaocrypt/mpi_superclass.h \
include/cyassl/ctaocrypt/misc.h \
include/cyassl/ctaocrypt/coding.h \
include/cyassl/ctaocrypt/dsa.h \
include/cyassl/ctaocrypt/wc_port.h \
include/cyassl/ctaocrypt/md4.h \
include/cyassl/ctaocrypt/integer.h \
include/cyassl/ctaocrypt/sha.h \
include/cyassl/ctaocrypt/compress.h \
include/cyassl/ctaocrypt/error-crypt.h \
include/cyassl/ctaocrypt/ripemd.h \
include/cyassl/ctaocrypt/pwdbased.h \
include/cyassl/ctaocrypt/chacha.h \
include/cyassl/ctaocrypt/arc4.h \
include/cyassl/ctaocrypt/tfm.h \
include/cyassl/ctaocrypt/poly1305.h \
include/cyassl/ctaocrypt/md2.h \
include/cyassl/ctaocrypt/logging.h \
include/cyassl/ctaocrypt/types.h \
include/cyassl/ctaocrypt/dh.h \
include/cyassl/ctaocrypt/random.h \
include/cyassl/ctaocrypt/hmac.h \
include/cyassl/ctaocrypt/memory.h \
include/cyassl/ctaocrypt/sha256.h \
include/cyassl/ctaocrypt/sha512.h \
include/cyassl/ctaocrypt/camellia.h \
include/cyassl/ctaocrypt/md5.h \
include/cyassl/ctaocrypt/asn.h \
include/cyassl/ctaocrypt/blake2.h \
include/cyassl/ctaocrypt/blake2-int.h \
include/cyassl/ctaocrypt/blake2-impl.h \
include/cyassl/ctaocrypt/des3.h \
include/cyassl/ctaocrypt/fips_test.h \
include/cyassl/ctaocrypt/pkcs7.h \
include/cyassl/ctaocrypt/rsa.h \
include/cyassl/ctaocrypt/aes.h \
include/cyassl/ctaocrypt/settings_comp.h \
include/cyassl/ctaocrypt/asn_public.h \
include/cyassl/ctaocrypt/visibility.h \
include/cyassl/ctaocrypt/ecc.h \
include/cyassl/ctaocrypt/settings.h \
include/cyassl/version.h \
include/cyassl/ssl.h \
share/doc/wolfssl/example/sctp-client.c \
share/doc/wolfssl/example/sctp-server.c \
share/doc/wolfssl/example/sctp-server-dtls.c \
share/doc/wolfssl/example/sctp-client-dtls.c \
share/doc/wolfssl/example/echoclient.c \
share/doc/wolfssl/example/echoserver.c \
share/doc/wolfssl/example/tls_bench.c \
share/doc/wolfssl/example/server.c \
share/doc/wolfssl/example/client.c \
share/doc/wolfssl/README.txt \
share/doc/wolfssl/taoCert.txt \
)

for f in "${files[@]}"; do
    test -e "$PREFIX/$f"
done

# compile&run the examples and tests, using the installed library
# assumes test.source_files has '*' in it and we have the contents of the build dir
make distclean

# hack configure.ac to expose ENABLE_NO_LIBRARY to cmdline
for p in "$RECIPE_DIR"/test-patches/*; do
    patch -p1 <"$p"
done


autoreconf --install
./configure --prefix="$PREFIX" \
            --enable-jobserver="$CPU_COUNT" \
	    --with-libz="$PREFIX" \
	    --enable-distro \
	    --enable-nolibrary

make check || { cat ./test-suite.log; exit 1 }
