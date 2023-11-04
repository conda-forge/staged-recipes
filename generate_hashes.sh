# To generate the version number

# name=asmjit/asmjit
name=maratyszcza/nnpack
name=facebookincubator/gloo
name=maratyszcza/pthreadpool
name=maratyszcza/fxdiv
name=maratyszcza/fp16
name=maratyszcza/psimd
name=pytorch/cpuinfo
name=maratyszcza/peachpy
name=pytorch/qnnpack
name=pytorch/fbgemm
name=google/xnnpack
name=pytorch/kineto
name=google/libnop
name=pytorch/tensorpipe

rm -rf source > /dev/null
git clone --quiet git@github.com:${name}.git source > /dev/null
pushd source > /dev/null
echo ${name} | cut -d '/' -f 2
echo "{% set version = \"0.0.0.$(date  +%Y%m%d -d "$(git show -s --format=%ci HEAD)").$(git rev-list HEAD --count).$(git rev-parse --short HEAD)\" %}"
echo "{% set gitrev = \"$(git rev-parse HEAD)\" %}"
wget --quiet https://github.com/${name}/archive/$(git rev-parse HEAD).tar.gz
echo "{% set sha256 = \"$(openssl sha256 $(git rev-parse HEAD).tar.gz | cut -d "=" -f2 | cut -d " " -f 2)\" %}"
popd > /dev/null

