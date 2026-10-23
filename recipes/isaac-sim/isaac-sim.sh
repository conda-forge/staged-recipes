#!/usr/bin/env bash

set -euo pipefail

prefix="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd -P)"
root="${prefix}/lib/isaac-sim"

export ISAACSIM_ROOT="${root}"
unset PYTHONHOME

prepend_conda_site_packages() {
    local -a site_dirs=()
    local site_dir

    map_conda_site_packages site_dirs
    for site_dir in "${site_dirs[@]}"; do
        case ":${PYTHONPATH:-}:" in
            *":${site_dir}:"*) ;;
            *)
                if [[ -n "${PYTHONPATH:-}" ]]; then
                    PYTHONPATH="${site_dir}:${PYTHONPATH}"
                else
                    PYTHONPATH="${site_dir}"
                fi
                ;;
        esac
    done

    export PYTHONPATH
}

map_conda_site_packages() {
    local -n out_dirs_ref="$1"
    local python_mm=
    local site_dir

    out_dirs_ref=()

    if [[ -x "${prefix}/bin/python3" ]]; then
        python_mm="$("${prefix}/bin/python3" -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")' 2>/dev/null || true)"
    fi

    if [[ -n "${python_mm}" ]]; then
        for site_dir in \
            "${prefix}/lib/python${python_mm}/site-packages" \
            "${prefix}/lib/python${python_mm}/dist-packages"
        do
            [[ -d "${site_dir}" ]] || continue
            out_dirs_ref+=("${site_dir}")
        done
        [[ "${#out_dirs_ref[@]}" -gt 0 ]] && return
    fi

    shopt -s nullglob
    for site_dir in \
        "${prefix}"/lib/python[0-9].[0-9][0-9]/site-packages \
        "${prefix}"/lib/python[0-9].[0-9][0-9]/dist-packages \
        "${prefix}"/lib/python[0-9].[0-9]/site-packages \
        "${prefix}"/lib/python[0-9].[0-9]/dist-packages
    do
        [[ -d "${site_dir}" ]] || continue
        out_dirs_ref+=("${site_dir}")
    done
    shopt -u nullglob
}

build_kit_python_extra_args() {
    local -n out_args_ref="$1"
    local -a site_dirs=()
    local site_dir
    local path_index=0

    out_args_ref=()

    map_conda_site_packages site_dirs
    for site_dir in "${site_dirs[@]}"; do
        out_args_ref+=("--/app/python/extraPaths/${path_index}=${site_dir}")
        ((path_index += 1))
    done
}

if [[ -f "${root}/setup_conda_env.sh" ]]; then
    # This is the upstream entrypoint for a conda-backed runtime layout.
    # It sets Kit's extension import paths and removes the bundled Python stdlib.
    set +u
    # shellcheck source=/dev/null
    source "${root}/setup_conda_env.sh"
    set -u
elif [[ -f "${root}/setup_python_env.sh" ]]; then
    set +u
    # shellcheck source=/dev/null
    source "${root}/setup_python_env.sh"
    set -u
fi

prepend_conda_site_packages
kit_extra_args=()
build_kit_python_extra_args kit_extra_args

exec "${root}/isaac-sim.sh" "${kit_extra_args[@]}" "$@"
