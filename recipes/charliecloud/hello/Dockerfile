# ch-test-scope: standard
FROM centos:8

RUN dnf install -y --setopt=install_weak_deps=false openssh-clients \
 && dnf clean all

COPY . hello

RUN touch /usr/bin/ch-ssh
