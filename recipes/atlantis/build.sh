# Turn the work-folder into GOPATH
export GOPATH=${SRC_DIR}
export PATH=${GOPATH}/bin:$PATH
pushd src/github.com/runatlantis/${PKG_NAME}

# We want GO packages with static libraries
export CGO_ENABLED=0 

# Git Initialize
# Apps tend to use git info to create version string
git init
git config --local user.email "conda@conda-forge.github.io"
git config --local user.name "conda-forge"

echo $PKG_VERSION >> .conda_version
git add .conda_version
git commit -m "conda build of $PKG_NAME-v$PKG_VERSION"
git tag v${PKG_VERSION}

# Build
go build -v -o ${PKG_NAME} .

# Install Binary into PREFIX/bin
mkdir -p $PREFIX/bin
mv ${PKG_NAME} $PREFIX/bin/${PKG_NAME}
