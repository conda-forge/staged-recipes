#!/bin/sh

if [[ $(uname -s) == Linux ]]; then
  export CPPFLAGS=$CPPFLAGS" -fPIC"
  # I have no idea why I'm having to do this. libtool issue?
  mkdir -p {stogo,util,mma,direct,praxis,cobyla,api,test,auglag,cdirect,newuoa,bobyqa,neldermead,luksan,slsqp,octave,crs,swig,mlsl,isres,esch}/mc/lib
  mkdir -p mc/lib
fi

./configure          \
  --prefix=${PREFIX} \
  --enable-static    \
  --disable-shared   \
  --with-cxx         \
  --without-octave   \
  --without-matlab   \
  --without-guile    \
  --without-python

make
make install
