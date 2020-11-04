#! /bin/sh

mkdir -p "${PREFIX}/etc/containers"
mkdir -p "${PREFIX}/share/containers"

mkdir "${PREFIX}/etc/containers/registries.conf.d"
cp buildah/tests/registries.conf "${PREFIX}/etc/containers/"

mkdir "${PREFIX}/etc/containers/registries.d"
cp skopeo/default.yaml "${PREFIX}/etc/containers/registries.d/"

cp skopeo/default-policy.json "${PREFIX}/etc/containers/policy.json"
cp common/pkg/seccomp/seccomp.json "${PREFIX}/share/containers/"

sed '
  /^# hooks_dir = \[/ {
    :loop_hooks_dir
    N
    /\]/b end_hooks_dir
    b loop_hooks_dir
    :end_hooks_dir
    s/# //g
    s|"/usr/|"'"${PREFIX}"'/|
  }

  /^# seccomp_profile = "/ {
    s/# //g
    s|"/usr/|"'"${PREFIX}"'/|
  }

  /^# cni_plugin_dirs = \["/ {
    s/# //g
    s|"/usr/|"'"${PREFIX}"'/|
  }

  /^# network_config_dir = "/ {
    s/# //g
    s|"/|"'"${PREFIX}"'/|
  }
  ' \
  common/pkg/config/containers.conf \
  > "${PREFIX}/share/containers/containers.conf"
