:: Windows really uses a different store of certificates (see
::   http://superuser.com/questions/411909/where-is-the-certificate-folder-in-windows-7)

:: The certs here are probably only useful for unix-type apps, such as git, that don't necessarily
::    respect the windows way of doing things.

:: version at time of writing is 1.25
curl -O https://raw.githubusercontent.com/curl/curl/master/lib/mk-ca-bundle.pl
if ( $($(CertUtil -hashfile mk-ca-bundle.pl SHA256)[1] -replace " ","") -eq "6fbdd1c76a41b7ab41cd616b19e52522e2b7efb636120950f053ef2c22de44af" ) { echo "mk-ca-bundle download ok" } else {echo "mk-ca-bundle.pl checksum bad.  Has it changed?" && exit 1}

perl mk-ca-bundle.pl

MKDIR %LIBRARY_PREFIX%/etc/ssl/certs && COPY ca-bundle.crt %LIBRARY_PREFIX%/etc/ssl/certs/ca-certificates.crt
MKDIR %LIBRARY_PREFIX%/etc/pki/tls/certs && COPY ca-bundle.crt %LIBRARY_PREFIX%/etc/pki/tls/certs/ca-bundle.crt
MKDIR %LIBRARY_PREFIX%/etc/ssl && COPY ca-bundle.crt %LIBRARY_PREFIX%/etc/ssl/ca-bundle.pem
MKDIR %LIBRARY_PREFIX%/etc/pki/tls && COPY ca-bundle.crt %LIBRARY_PREFIX%/etc/pki/tls/cacert.pem
