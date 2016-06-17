# Info about the PyGithub development version we want to install.
PYGITHUB_COMMIT="8bb765a2dacfac73e98d09191e1decb2bdbe2584"
PYGITHUB_CHECKSUM="9d653d58cdacac2161d85788e31f5ddb25d8bbd57361da27810ca2f7accfc0f8"

# Install a development build of PyGithub.
# This is a workaround for the fact there is no PyGithub release with the changes needed.
# See PR ( https://github.com/conda-forge/pygithub-feedstock/pull/9 ).
# Also see PR ( https://github.com/PyGithub/PyGithub/pull/379 ).
curl -L "https://github.com/PyGithub/PyGithub/archive/${PYGITHUB_COMMIT}.tar.gz" > PyGithub.tar.gz
openssl sha256 PyGithub.tar.gz | grep "${PYGITHUB_CHECKSUM}"
mkdir PyGithub
tar -xzf PyGithub.tar.gz -C PyGithub --strip-components=1
rm -f PyGithub.tar.gz
pushd PyGithub
python setup.py install --single-version-externally-managed --record=record.txt
popd
rm -rf PyGithub

# Build and install statuspage as a single binary with PyInstaller.
pyinstaller -p "${PREFIX}/lib:${SP_DIR}" statuspage/statuspage.spec
cp dist/statuspage "${PREFIX}/bin/"
chmod +x "${PREFIX}/bin/statuspage"

# Remove PyGithub development version install.
rm -rf "${SP_DIR}"

# Install [de]activation scripts for determining where to find the certificates.
# This is a workaround for the fact that this has not been added to `ca-certificates`.
# See PR ( https://github.com/conda-forge/ca-certificates-feedstock/pull/4 ).
for CHANGE in "activate" "deactivate"
do
    mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
    cp "${RECIPE_DIR}/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.sh"
done
