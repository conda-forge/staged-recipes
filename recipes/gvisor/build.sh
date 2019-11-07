#!/usr/bin/env bash

#export GOPATH=bazel-bin/gopath

bazel build runsc
sudo cp ./bazel-bin/runsc/linux_amd64_pure_stripped/runsc /usr/local/bin


#git clone https://gvisor.googlesource.com/gvisor gvisor
#cd gvisor
#
#bazel build runsc
#sudo cp ./bazel-bin/runsc/linux_amd64_pure_stripped/runsc /usr/local/bin

