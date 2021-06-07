#!/usr/bin/env bash
set -x

declare -a ARGS
ARGS+=("CC=${CC}")
ARGS+=("LINKER=${CC}")
ARGS+=("PREFIX=${PREFIX}")
ARGS+=("BIN_PATH=${PREFIX}")
ARGS+=("BIN_AFTER_INST_PATH=${BIN_PATH}")
ARGS+=("PROMPT_BIN_PATH=${PREFIX}")
ARGS+=("AGENTSERVER_BIN_PATH=${PREFIX}")
ARGS+=("LIB_PATH=${PREFIX}/lib/")
ARGS+=("LIBDEV_PATH=${PREFIX}/lib/")
ARGS+=("INCLUDE_PATH=${PREFIX}/include/")
ARGS+=("MAN_PATH=${PREFIX}/share/man")
ARGS+=("PROMPT_MAN_PATH=${PREFIX}/share/man")
ARGS+=("AGENTSERVER_MAN_PATH=${PREFIX}/share/man")
ARGS+=("CONFIG_PATH=${PREFIX}/etc")
ARGS+=("BASH_COMPLETION_PATH=${PREFIX}/share/bash-completion/completions")
ARGS+=("DESKTOP_APPLICATION_PATH=${PREFIX}/share/applications")
ARGS+=("XSESSION_PATH=${PREFIX}/etc/X11")
ARGS+=("SHELL=bash -x")

# Can't use multiple cores as the Makefile doesn't support it
make -j1 "${ARGS[@]}"
make install_lib "${ARGS[@]}"
make install "${ARGS[@]}"