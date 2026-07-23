set -euo pipefail

readonly source_root="$PWD"
readonly recipe_dir="${RECIPE_DIR}"
readonly python_mm="$(${PYTHON} -c 'import sys; print(f"{sys.version_info[0]}.{sys.version_info[1]}")')"

case "${target_platform}" in
    linux-64)
        readonly isaac_platform="linux-x86_64"
        readonly cuda_target="x86_64-linux"
        ;;
    linux-aarch64)
        readonly isaac_platform="linux-aarch64"
        readonly cuda_target="aarch64-linux"
        ;;
    *)
        echo "Unsupported target platform: ${target_platform}" >&2
        exit 1
        ;;
esac

log() {
    printf '==> %s\n' "$*"
}

apply_local_overlay() {
    local overlay_root="${source_root}/local-overlay"

    if [[ ! -d "${overlay_root}" ]]; then
        return
    fi

    log "Applying local source overlay"

    if [[ -d "${overlay_root}/vendor" ]]; then
        mkdir -p "${source_root}/vendor"
        cp -a "${overlay_root}/vendor/." "${source_root}/vendor/"
    fi

    if [[ -d "${overlay_root}/source" ]]; then
        mkdir -p "${source_root}/source"
        cp -a "${overlay_root}/source/." "${source_root}/source/"
    fi
}

require_path() {
    local path="$1"
    if [[ ! -e "${path}" ]]; then
        echo "Required path is missing: ${path}" >&2
        exit 1
    fi
}

link_prefix_dependency() {
    local dep_name="$1"
    ln -sfn "${PREFIX}" "${source_root}/_build/target-deps/${dep_name}"
}

materialize_release_path() {
    local relative_path="$1"
    local release_path="${release_dir}/${relative_path}"
    local install_path="${install_root}/${relative_path}"

    if [[ -L "${install_path}" ]]; then
        rm -f "${install_path}"
    fi
    if [[ ! -e "${install_path}" ]]; then
        cp -aL "${release_path}" "${install_path}"
    fi
}

configure_build_cache() {
    readonly cache_root="$(cd "${source_root}/../../.." && pwd -P)/isaac-sim-cache"
    mkdir -p "${cache_root}"

    export HOME="${cache_root}/home"
    export XDG_CACHE_HOME="${HOME}/.cache"
    export PM_PACKAGES_ROOT="${cache_root}/packman"
    export PM_REMOTE_CLOUDFRONT_RETRYCOUNT="${PM_REMOTE_CLOUDFRONT_RETRYCOUNT:-6}"
    export PM_REMOTE_CLOUDFRONT_RETRYDELAY="${PM_REMOTE_CLOUDFRONT_RETRYDELAY:-30}"
    export PM_REMOTE_CLOUDFRONT_TIMEOUT="${PM_REMOTE_CLOUDFRONT_TIMEOUT:-180}"

    mkdir -p "${HOME}" "${XDG_CACHE_HOME}"
}

resolve_archive_extractor() {
    if command -v 7zz >/dev/null 2>&1; then
        printf '7zz\n'
        return
    fi
    if command -v 7z >/dev/null 2>&1; then
        printf '7z\n'
        return
    fi

    echo "No 7z extractor found in PATH (expected 7zz or 7z)" >&2
    exit 1
}

stage_packman_archive() {
    local archive_path="$1"
    local package_name="$2"
    local package_version="$3"
    local destination="${PM_PACKAGES_ROOT}/chk/${package_name}/${package_version}"

    if [[ ! -f "${archive_path}" ]]; then
        return
    fi
    if [[ -e "${destination}/PACKAGE-INFO.yaml" ]] || [[ -e "${destination}/.packman.lock" ]]; then
        return
    fi

    local extractor
    extractor="$(resolve_archive_extractor)"

    log "Staging packman payload ${package_name}@${package_version}"
    rm -rf "${destination}"
    mkdir -p "${destination}"
    "${extractor}" x -y -bd "-o${destination}" "${archive_path}" >/dev/null
}

materialize_packman_target_dep() {
    local source_dir="$1"
    local destination="$2"

    require_path "${source_dir}"
    rm -rf "${destination}"
    mkdir -p "$(dirname "${destination}")"
    cp -a "${source_dir}" "${destination}"
}

stage_packman_payloads() {
    local packman_source_dir=""
    local candidate_dir
    local lula_version="v0.10.1_f39b9da.linux-x86_64.release"
    local usd_ext_physics_version="24.05+release.40469.09c54277.gl.manylinux_2_35_x86_64.release"

    for candidate_dir in \
        "${source_root}/vendor/packman" \
        "${source_root}/local-overlay/vendor/packman"
    do
        if [[ -d "${candidate_dir}" ]]; then
            packman_source_dir="${candidate_dir}"
            break
        fi
    done

    if [[ -z "${packman_source_dir}" ]]; then
        echo "Missing vendored Packman payload directory." >&2
        echo "Expected either ${source_root}/vendor/packman or ${source_root}/local-overlay/vendor/packman." >&2
        exit 1
    fi

    require_path "${packman_source_dir}/lula-linux-x86_64.7z"
    require_path "${packman_source_dir}/usd_ext_physics-manylinux_2_35_x86_64-release.7z"

    stage_packman_archive \
        "${packman_source_dir}/lula-linux-x86_64.7z" \
        "lula" \
        "${lula_version}"
    stage_packman_archive \
        "${packman_source_dir}/usd_ext_physics-manylinux_2_35_x86_64-release.7z" \
        "usd_ext_physics" \
        "${usd_ext_physics_version}"

    # Upstream looks for these payloads under _build/target-deps even after we
    # remove the corresponding packman dependencies from the manifests.
    materialize_packman_target_dep \
        "${PM_PACKAGES_ROOT}/chk/lula/${lula_version}" \
        "${source_root}/_build/target-deps/lula"
    require_path "${source_root}/_build/target-deps/lula/pip-packages/nvidia_lula_no_cuda-0.10.1-cp311-cp311-linux_x86_64.whl"

    materialize_packman_target_dep \
        "${PM_PACKAGES_ROOT}/chk/usd_ext_physics/${usd_ext_physics_version}" \
        "${source_root}/_build/target-deps/usd_ext_physics/release"
    materialize_packman_target_dep \
        "${PM_PACKAGES_ROOT}/chk/usd_ext_physics/${usd_ext_physics_version}" \
        "${source_root}/_build/target-deps/usd_ext_physics/debug"
}

stage_python_prebundles() {
    local source_dir="${source_root}/vendor/python-prebundles/isaac_usd_to_urdf_prebundle"
    local target_dir="${source_root}/_build/target-deps/isaac_usd_to_urdf_prebundle"

    if [[ ! -d "${source_dir}" ]]; then
        return
    fi

    log "Staging usd-to-urdf Python prebundle"
    rm -rf "${target_dir}"
    mkdir -p "${target_dir}"
    cp -a "${source_dir}/." "${target_dir}/"
    require_path "${target_dir}/nvidia/srl/from_usd/to_urdf.py"
}

initialize_packman() {
    local packman_cmd="tools/packman/packman"
    if [[ ! -f "${packman_cmd}" ]]; then
        packman_cmd+=".sh"
    fi

    export PM_PYTHON_EXT="${PYTHON}"
    # shellcheck source=/dev/null
    source "${packman_cmd}" init
    set -euo pipefail
    export PYTHONPATH="${PM_MODULE_DIR}${PYTHONPATH:+:${PYTHONPATH}}"
}

patch_source_tree() {
    log "Patching upstream source tree"
    "${PYTHON}" "${recipe_dir}/scripts/patch_source_tree.py"
}

install_build_helpers() {
    log "Installing build-time helper scripts"

    install -m 0644 \
        "${recipe_dir}/scripts/repair_packman_python.py" \
        "${source_root}/repair_packman_python.py"
    install -m 0644 \
        "${recipe_dir}/scripts/stage_local_extscache.py" \
        "${source_root}/stage_local_extscache.py"

    cat > "${source_root}/repair_packman_python.sh" <<EOF
#!/usr/bin/env bash
set -euo pipefail

script_dir="\$(cd "\$(dirname "\${BASH_SOURCE[0]}")" && pwd -P)"
exec "\${script_dir}/_build/target-deps/python/bin/python3" \
    "\${script_dir}/repair_packman_python.py" \
    --root "\${script_dir}" \
    --python-mm "${python_mm}" \
    --isaac-platform "${isaac_platform}"
EOF
    chmod 0755 "${source_root}/repair_packman_python.sh"

    cat > "${source_root}/stage_local_extscache.sh" <<EOF
#!/usr/bin/env bash
set -euo pipefail

script_dir="\$(cd "\$(dirname "\${BASH_SOURCE[0]}")" && pwd -P)"
exec "${PYTHON}" \
    "\${script_dir}/stage_local_extscache.py" \
    --root "\${script_dir}" \
    --isaac-platform "${isaac_platform}"
EOF
    chmod 0755 "${source_root}/stage_local_extscache.sh"

    cat > "${source_root}/NVIDIA-ISAAC-SIM-ADDITIONAL-LICENSE.txt" <<'EOF'
This package bundles or builds against additional NVIDIA-owned Omniverse
components that are not covered by the repository's Apache-2.0 license.

The upstream project points users to the following terms for those components:
https://www.nvidia.com/en-us/agreements/enterprise-software/isaac-sim-additional-software-and-materials-license/
EOF
}

prepare_python_target_dep() {
    log "Preparing Python target dependency layout"

    rm -rf "${source_root}/_build/target-deps/python"
    ln -sfn "${PREFIX}" "${source_root}/_build/target-deps/python"
    mkdir -p "${source_root}/_repo/python"

    local py_link
    for py_link in \
        "${source_root}/_build/target-deps/python/python" \
        "${source_root}/_build/target-deps/python/python3" \
        "${source_root}/_repo/python/python" \
        "${source_root}/_repo/python/python3"
    do
        ln -sf "${PYTHON}" "${py_link}"
    done
}

prepare_static_target_deps() {
    log "Preparing packman-style target dependency layout"

    mkdir -p \
        "${source_root}/_build/target-deps" \
        "${source_root}/_build/target-deps/isaac_core_prebundle" \
        "${source_root}/_build/target-deps/isaac_ml_prebundle" \
        "${source_root}/_build/target-deps/octomap" \
        "${source_root}/_build/target-deps/pip_cloud_prebundle" \
        "${source_root}/_build/target-deps/pip_compute_prebundle" \
        "${source_root}/_repo/python"

    local dep_name
    for dep_name in fmt doctest gsl nvtx pybind11 rapidjson tinyxml2 nlohmann_json; do
        link_prefix_dependency "${dep_name}"
    done

    ln -sfn "${PREFIX}" "${source_root}/_build/target-deps/octomap/release"
    prepare_python_target_dep
}

configure_cuda_target_deps() {
    local cuda_prefix=""
    local candidate_prefix
    local targets_dir=""
    local include_dir=""
    local lib_dir=""
    local stubs_dir=""

    for candidate_prefix in "${BUILD_PREFIX:-}" "${PREFIX}"; do
        if [[ -z "${candidate_prefix}" ]] || [[ ! -x "${candidate_prefix}/bin/nvcc" ]]; then
            continue
        fi

        targets_dir="${candidate_prefix}/targets/${cuda_target}"
        include_dir="${targets_dir}/include"
        lib_dir="${targets_dir}/lib"
        stubs_dir="${lib_dir}/stubs"

        if [[ -f "${include_dir}/cuda.h" ]] \
            && [[ -f "${lib_dir}/libcudart_static.a" ]] \
            && [[ -f "${stubs_dir}/libcuda.so" ]]; then
            cuda_prefix="${candidate_prefix}"
            break
        fi
    done

    if [[ -z "${cuda_prefix}" ]]; then
        echo "Missing conda-forge CUDA toolkit layout for ${cuda_target}" >&2
        echo "Expected bin/nvcc and targets/${cuda_target}/{include,lib,lib/stubs} in BUILD_PREFIX or PREFIX" >&2
        exit 1
    fi

    log "Preparing CUDA target dependency layout from ${cuda_prefix}"

    rm -rf "${source_root}/_build/target-deps/cuda"
    mkdir -p "${source_root}/_build/target-deps/cuda"
    ln -sfn "${include_dir}" "${source_root}/_build/target-deps/cuda/include"
    ln -sfn "${lib_dir}" "${source_root}/_build/target-deps/cuda/lib64"
    ln -sfn "${cuda_prefix}/bin" "${source_root}/_build/target-deps/cuda/bin"

    if [[ -d "${cuda_prefix}/nvvm" ]]; then
        ln -sfn "${cuda_prefix}/nvvm" "${source_root}/_build/target-deps/cuda/nvvm"
    fi
    if [[ -d "${cuda_prefix}/targets" ]]; then
        ln -sfn "${cuda_prefix}/targets" "${source_root}/_build/target-deps/cuda/targets"
    fi

    export CUDA_HOME="${source_root}/_build/target-deps/cuda"
    export CUDA_PATH="${CUDA_HOME}"
}

configure_runtime_environment() {
    export PATH="${PREFIX}/bin:${PATH}"
    export CMAKE_PREFIX_PATH="${PREFIX}${CMAKE_PREFIX_PATH:+:${CMAKE_PREFIX_PATH}}"
    export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig:${PREFIX}/share/pkgconfig${PKG_CONFIG_PATH:+:${PKG_CONFIG_PATH}}"
    export LD_LIBRARY_PATH="${PREFIX}/lib${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"
    export PYTHONPATH="${PREFIX}/lib/python${python_mm}/lib-dynload${PYTHONPATH:+:${PYTHONPATH}}"
}

run_repoman_build() {
    log "Running repoman build"
    touch "${source_root}/.eula_accepted"
    "${source_root}/repair_packman_python.sh"
    initialize_packman
    stage_packman_payloads
    stage_python_prebundles
    "${PYTHON}" tools/repoman/repoman.py build --release --skip-compiler-version-check -j "${CPU_COUNT:-1}"
}

install_release_tree() {
    readonly release_dir="${source_root}/_build/${isaac_platform}/release"
    readonly install_root="${PREFIX}/lib/isaac-sim"

    require_path "${release_dir}"

    log "Installing release tree"
    mkdir -p "${install_root}" "${PREFIX}/bin"
    cp -a "${release_dir}/." "${install_root}/"

    rm -rf \
        "${install_root}/.vscode" \
        "${install_root}/dev" \
        "${install_root}/dockertests" \
        "${install_root}/tests"
    rm -f "${install_root}/compile_commands.json"

    materialize_release_path "kit"
    materialize_release_path "apps"
    require_path "${install_root}/kit"
    require_path "${install_root}/apps/isaacsim.exp.full.kit"
}

restore_extension_metadata() {
    log "Restoring extension metadata from unpacked source tree"

    local mapping group src_group dest_group src_ext name dest_ext
    for mapping in \
        "exts:${source_root}/extensions" \
        "exts:${source_root}/source/extensions" \
        "extsDeprecated:${source_root}/deprecated" \
        "extsDeprecated:${source_root}/extensionsDeprecated" \
        "extsDeprecated:${source_root}/source/deprecated" \
        "extsDeprecated:${source_root}/source/extensionsDeprecated"
    do
        group="${mapping%%:*}"
        src_group="${mapping#*:}"
        dest_group="${install_root}/${group}"

        [[ -d "${src_group}" ]] || continue
        [[ -d "${dest_group}" ]] || continue

        for src_ext in "${src_group}"/*; do
            [[ -d "${src_ext}" ]] || continue

            name="${src_ext##*/}"
            dest_ext="${dest_group}/${name}"
            [[ -d "${dest_ext}" ]] || continue

            if [[ -d "${src_ext}/config" ]]; then
                if [[ -e "${dest_ext}/config/extension.toml" ]] \
                    && [[ "${src_ext}/config/extension.toml" -ef "${dest_ext}/config/extension.toml" ]]; then
                    rm -rf "${dest_ext}/config"
                elif [[ -L "${dest_ext}/config" ]]; then
                    rm -f "${dest_ext}/config"
                fi
                mkdir -p "${dest_ext}/config"
                cp -a "${src_ext}/config/." "${dest_ext}/config/"
            fi

            if [[ -f "${src_ext}/extension.toml" ]] \
                && [[ -e "${dest_ext}/extension.toml" ]] \
                && [[ "${src_ext}/extension.toml" -ef "${dest_ext}/extension.toml" ]]; then
                rm -f "${dest_ext}/extension.toml"
            fi

            if [[ -f "${src_ext}/extension.toml" && ! -e "${dest_ext}/extension.toml" ]]; then
                cp -a "${src_ext}/extension.toml" "${dest_ext}/"
            fi

        done
    done
}

materialize_external_link() {
    local link_path="$1"
    local resolved_target

    [[ -L "${link_path}" ]] || return 1

    resolved_target="$(readlink -f "${link_path}" 2>/dev/null || true)"
    [[ -n "${resolved_target}" ]] || return 1

    case "${resolved_target}" in
        "${install_root}"/*|"${PREFIX}"/*)
            return 1
            ;;
    esac

    rm -rf "${link_path}"
    if [[ -d "${resolved_target}" ]]; then
        mkdir -p "${link_path}"
        cp -aL "${resolved_target}/." "${link_path}/"
    else
        cp -aL "${resolved_target}" "${link_path}"
    fi

    return 0
}

materialize_external_extension_links() {
    log "Materializing extension links that still point outside the package"

    local nullglob_was_set=0
    local group ext changed
    if shopt -q nullglob; then
        nullglob_was_set=1
    fi
    shopt -s nullglob

    for group in "${install_root}/exts" "${install_root}/extsDeprecated"; do
        [[ -d "${group}" ]] || continue

        for ext in "${group}"/*; do
            [[ -d "${ext}" ]] || continue

            while true; do
                changed=0
                while IFS= read -r -d '' link_path; do
                    if materialize_external_link "${link_path}"; then
                        changed=1
                    fi
                done < <(find -P "${ext}" -type l -print0)
                [[ "${changed}" -eq 1 ]] || break
            done
        done
    done

    if [[ "${nullglob_was_set}" -eq 0 ]]; then
        shopt -u nullglob
    fi
}

ensure_declared_pip_prebundles() {
    log "Ensuring declared pip_prebundle directories exist"

    local nullglob_was_set=0
    local group ext extension_toml
    if shopt -q nullglob; then
        nullglob_was_set=1
    fi
    shopt -s nullglob

    for group in "${install_root}/exts" "${install_root}/extsDeprecated"; do
        [[ -d "${group}" ]] || continue

        for ext in "${group}"/*; do
            [[ -d "${ext}" ]] || continue

            extension_toml="${ext}/config/extension.toml"
            [[ -f "${extension_toml}" ]] || extension_toml="${ext}/extension.toml"
            [[ -f "${extension_toml}" ]] || continue

            if grep -q 'pip_prebundle' "${extension_toml}"; then
                mkdir -p "${ext}/pip_prebundle"
                printf 'Retain empty directory in conda package.\n' > "${ext}/pip_prebundle/.conda-keep"
            fi
        done
    done

    if [[ "${nullglob_was_set}" -eq 0 ]]; then
        shopt -u nullglob
    fi
}

repair_lfs_placeholder_icons() {
    log "Repairing Git LFS placeholder icon assets"

    local source_icon="${install_root}/exts/isaacsim.app.selector/icons/isaacsim.png"
    local target icon_header

    [[ -f "${source_icon}" ]] || return

    for target in \
        "${install_root}/exts/isaacsim.simulation_app/data/omni.isaac.sim.png" \
        "${install_root}/exts/isaacsim.app.setup/data/omni.isaac.sim.png" \
        "${install_root}/extsDeprecated/omni.isaac.app.setup/data/omni.isaac.sim.png" \
        "${install_root}/extsDeprecated/omni.isaac.app.selector/data/omni.isaac.sim.png" \
        "${install_root}/extsDeprecated/omni.isaac.kit/data/omni.isaac.sim.png"
    do
        [[ -f "${target}" ]] || continue

        icon_header="$(head -c 48 "${target}" 2>/dev/null || true)"
        if [[ "${icon_header}" == version\ https://git-lfs.github.com/spec/v1* ]]; then
            install -D -m 0644 "${source_icon}" "${target}"
        fi
    done
}

configure_app_python_extra_paths() {
    log "Configuring Kit app Python extra paths"

    local base_kit="${install_root}/apps/isaacsim.exp.base.kit"

    [[ -f "${base_kit}" ]] || return

    if grep -q '\[settings.app.python\]' "${base_kit}"; then
        return
    fi

    cat >> "${base_kit}" <<EOF

[settings.app.python]
extraPaths = [
    "\${app}/../../python${python_mm}/site-packages",
]
EOF
}

disable_broken_dynamic_control_dependencies() {
    local config_path

    for config_path in \
        "${install_root}/apps/isaacsim.exp.base.kit" \
        "${install_root}/exts/isaacsim.core.utils/config/extension.toml" \
        "${install_root}/exts/isaacsim.core.nodes/config/extension.toml" \
        "${install_root}/exts/isaacsim.robot.wheeled_robots/config/extension.toml" \
        "${install_root}/exts/isaacsim.examples.interactive/config/extension.toml"
    do
        [[ -f "${config_path}" ]] || continue
        python - "${config_path}" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
text = path.read_text()
updated = text.replace('"omni.isaac.dynamic_control" = {}\n', "")
if updated != text:
    path.write_text(updated)
PY
    done
}

disable_broken_physics_sensor_dependencies() {
    local config_path

    for config_path in \
        "${install_root}/apps/isaacsim.exp.base.kit" \
        "${install_root}/apps/isaacsim.exp.full.kit" \
        "${install_root}/extsDeprecated/omni.isaac.sensor/config/extension.toml" \
        "${install_root}/exts/isaacsim.robot.policy.examples/config/extension.toml"
    do
        [[ -f "${config_path}" ]] || continue
        python - "${config_path}" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
text = path.read_text()
for needle in (
    '"isaacsim.sensors.physics" = {}\n',
    '"isaacsim.sensors.physics.examples" = {}\n',
    '"isaacsim.sensors.physics.ui" = {}\n',
    '"omni.isaac.sensor" = {}\n',
):
    text = text.replace(needle, "")
path.write_text(text)
PY
    done
}

finalize_install_tree() {
    log "Repairing installed extension tree"
    "${PYTHON}" "${recipe_dir}/scripts/finalize_install_tree.py" \
        --install-root "${install_root}" \
        --release-dir "${release_dir}" \
        --source-root "${source_root}"
}

configure_kit_python_layout() {
    log "Materializing embedded Python home from conda runtime"

    local kit_python_dir="${install_root}/kit/python"
    local stdlib_dir="${PREFIX}/lib/python${python_mm}"
    local python_flat="${python_mm//./}"

    require_path "${stdlib_dir}/encodings/__init__.py"

    rm -rf "${kit_python_dir}"
    mkdir -p \
        "${kit_python_dir}/bin" \
        "${kit_python_dir}/include" \
        "${kit_python_dir}/lib/python${python_mm}" \
        "${kit_python_dir}/lib/python${python_mm}/site-packages"

    ln -sfn "../../../../../bin/python3" "${kit_python_dir}/bin/python3"
    if [[ -x "${PREFIX}/bin/python" ]]; then
        ln -sfn "../../../../../bin/python" "${kit_python_dir}/bin/python"
    else
        ln -sfn "python3" "${kit_python_dir}/bin/python"
    fi
    if [[ -x "${PREFIX}/bin/python${python_mm}" ]]; then
        ln -sfn "../../../../../bin/python${python_mm}" "${kit_python_dir}/bin/python${python_mm}"
    fi
    ln -sfn "bin/python" "${kit_python_dir}/python"
    ln -sfn "bin/python3" "${kit_python_dir}/python3"

    if [[ -d "${PREFIX}/include/python${python_mm}" ]]; then
        ln -sfn "../../../../../include/python${python_mm}" "${kit_python_dir}/include/python${python_mm}"
    fi

    if [[ -f "${PREFIX}/lib/python${python_flat}.zip" ]]; then
        ln -sfn "../../../../python${python_flat}.zip" "${kit_python_dir}/lib/python${python_flat}.zip"
    fi

    local entry name
    for entry in "${stdlib_dir}"/*; do
        name="${entry##*/}"
        case "${name}" in
            site-packages|dist-packages|__pycache__)
                continue
                ;;
        esac
        ln -sfn "../../../../../python${python_mm}/${name}" "${kit_python_dir}/lib/python${python_mm}/${name}"
    done
}

write_launcher_wrapper() {
    local command_name="$1"
    local target_script="$2"
    local target_path="${install_root}/${target_script}"

    if [[ ! -f "${target_path}" ]]; then
        return
    fi

    cat > "${PREFIX}/bin/${command_name}" <<EOF
#!/usr/bin/env bash
set -euo pipefail

prefix="\$(cd "\$(dirname "\${BASH_SOURCE[0]}")"/.. && pwd -P)"
root="\${prefix}/lib/isaac-sim"

export ISAACSIM_ROOT="\${root}"
unset PYTHONHOME

prepend_conda_site_packages() {
    local -a site_dirs=()
    local site_dir

    map_conda_site_packages site_dirs
    for site_dir in "\${site_dirs[@]}"; do
        case ":\${PYTHONPATH:-}:" in
            *":\${site_dir}:"*) ;;
            *)
                if [[ -n "\${PYTHONPATH:-}" ]]; then
                    PYTHONPATH="\${site_dir}:\${PYTHONPATH}"
                else
                    PYTHONPATH="\${site_dir}"
                fi
                ;;
        esac
    done

    export PYTHONPATH
}

map_conda_site_packages() {
    local -n out_dirs_ref="\$1"
    local python_mm=
    local site_dir

    out_dirs_ref=()

    if [[ -x "\${prefix}/bin/python3" ]]; then
        python_mm="\$("\${prefix}/bin/python3" -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")' 2>/dev/null || true)"
    fi

    if [[ -n "\${python_mm}" ]]; then
        for site_dir in \
            "\${prefix}/lib/python\${python_mm}/site-packages" \
            "\${prefix}/lib/python\${python_mm}/dist-packages"
        do
            [[ -d "\${site_dir}" ]] || continue
            out_dirs_ref+=("\${site_dir}")
        done
        [[ "\${#out_dirs_ref[@]}" -gt 0 ]] && return
    fi

    shopt -s nullglob
    for site_dir in \
        "\${prefix}"/lib/python[0-9].[0-9][0-9]/site-packages \
        "\${prefix}"/lib/python[0-9].[0-9][0-9]/dist-packages \
        "\${prefix}"/lib/python[0-9].[0-9]/site-packages \
        "\${prefix}"/lib/python[0-9].[0-9]/dist-packages
    do
        [[ -d "\${site_dir}" ]] || continue
        out_dirs_ref+=("\${site_dir}")
    done
    shopt -u nullglob
}

build_kit_python_extra_args() {
    local -n out_args_ref="\$1"
    local -a site_dirs=()
    local site_dir
    local path_index=0

    out_args_ref=()

    map_conda_site_packages site_dirs
    for site_dir in "\${site_dirs[@]}"; do
        out_args_ref+=("--/app/python/extraPaths/\${path_index}=\${site_dir}")
        ((path_index += 1))
    done
}

if [[ -f "\${root}/setup_conda_env.sh" ]]; then
    set +u
    # shellcheck source=/dev/null
    source "\${root}/setup_conda_env.sh"
    set -u
elif [[ -f "\${root}/setup_python_env.sh" ]]; then
    set +u
    # shellcheck source=/dev/null
    source "\${root}/setup_python_env.sh"
    set -u
fi

prepend_conda_site_packages
kit_extra_args=()
build_kit_python_extra_args kit_extra_args

exec "\${root}/${target_script}" "\${kit_extra_args[@]}" "\$@"
EOF
    chmod 0755 "${PREFIX}/bin/${command_name}"
}

install_launchers() {
    log "Installing launcher wrappers"

    install -m 0755 "${recipe_dir}/isaac-sim.sh" "${PREFIX}/bin/isaac-sim"

    local spec name target
    for spec in \
        'isaac-sim-selector:isaac-sim.selector.sh' \
        'isaac-sim-streaming:isaac-sim.streaming.sh' \
        'isaac-sim-fabric:isaac-sim.fabric.sh' \
        'isaac-sim-compatibility-check:isaac-sim.compatibility_check.sh' \
        'isaac-sim-action-and-event-data-generation:isaac-sim.action_and_event_data_generation.sh' \
        'isaac-sim-xr-vr:isaac-sim.xr.vr.sh' \
        'isaac-sim-jupyter-notebook:jupyter_notebook.sh' \
        'isaac-sim-python:python.sh' \
        'isaac-sim-clear-caches:clear_caches.sh' \
        'isaac-sim-warmup:warmup.sh'
    do
        name="${spec%%:*}"
        target="${spec#*:}"
        write_launcher_wrapper "${name}" "${target}"
    done
}

cleanup_install_tree() {
    log "Removing static archives"
    find "${install_root}" -type f \( -name '*.a' -o -name '*.la' \) -delete

    # These top-level links are not part of the intended isaac-sim payload.
    rm -f "${PREFIX}/python" "${PREFIX}/python3"
}

main() {
    apply_local_overlay
    patch_source_tree
    install_build_helpers
    prepare_static_target_deps

    if [[ "${cuda_compiler_version}" != "None" ]]; then
        configure_cuda_target_deps
    else
        rm -rf "${source_root}/_build/target-deps/cuda"
        unset CUDA_HOME CUDA_PATH || true
    fi

    configure_build_cache
    configure_runtime_environment
    run_repoman_build
    install_release_tree
    restore_extension_metadata
    materialize_external_extension_links
    finalize_install_tree
    ensure_declared_pip_prebundles
    repair_lfs_placeholder_icons
    disable_broken_dynamic_control_dependencies
    disable_broken_physics_sensor_dependencies
    configure_app_python_extra_paths
    configure_kit_python_layout
    cleanup_install_tree
    install_launchers
}

main "$@"
