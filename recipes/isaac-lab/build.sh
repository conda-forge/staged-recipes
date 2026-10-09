set -exo pipefail

entries=(
    "source/isaaclab:isaaclab"
    "source/isaaclab_assets:isaaclab_assets"
    "source/isaaclab_contrib:isaaclab_contrib"
    "source/isaaclab_mimic:isaaclab_mimic"
    "source/isaaclab_rl:isaaclab_rl"
    "source/isaaclab_tasks:isaaclab_tasks"
)

# Upstream carries a few pip-oriented pins that are either unavailable on conda-forge
# or unnecessarily restrictive for the shared isaac-sim environment. Relax them in
# package metadata so the installed distribution matches the conda recipe.
while IFS= read -r -d '' file; do
    sed -E -i 's/hidapi==0\.14\.0\.post[0-9]+/hidapi>=0.14,<0.15/g' "${file}"
    sed -E -i 's/pyglet<2/pyglet>=2,<3/g' "${file}"
    sed -E -i 's/starlette==0\.49\.1/starlette>=0.49.1,<1/g' "${file}"
    sed -E -i 's/pin-pink==3\.1\.0/pin-pink>=3.1,<5/g' "${file}"
    sed -E -i 's/daqp==0\.7\.2/daqp>=0.7.1,<0.8/g' "${file}"
done < <(find source -type f \( -name "setup.py" -o -name "setup.cfg" -o -name "pyproject.toml" \) -print0)

# Install each extension package wheel-style and let conda own dependency solving.
for entry in "${entries[@]}"; do
    "${PYTHON}" -m pip install "${entry%%:*}" --no-build-isolation --no-deps
done

# Determine site-packages for the active build interpreter.
site_packages="$("${PYTHON}" - <<'PY'
import sysconfig
print(sysconfig.get_path("purelib"))
PY
)"

stage_module_tree() {
    local source_dir="$1"
    local dest_dir="$2"
    mkdir -p "${dest_dir}"
    cp -a "${source_dir}/." "${dest_dir}/"
}

copy_optional_sibling_dir() {
    local extension_root="$1"
    local dest_module="$2"
    local sibling="$3"
    local source_sibling="${extension_root}/${sibling}"
    local dest_sibling="${dest_module}/${sibling}"
    if [[ ! -d "${source_sibling}" ]]; then
        return
    fi
    rm -rf "${dest_sibling}"
    cp -a "${source_sibling}" "${dest_sibling}"
}

# Relocate sibling asset folders (config/data) under each module root.
# IsaacLab keeps them next to the package directory, which is not relocatable
# once installed into conda site-packages.
for entry in "${entries[@]}"; do
    extension_rel="${entry%%:*}"
    module="${entry##*:}"
    extension_root="${extension_rel}"
    src_module="${extension_root}/${module}"
    dst_module="${site_packages}/${module}"

    if [[ ! -d "${src_module}" ]]; then
        echo "Missing module directory: ${src_module}" >&2
        exit 1
    fi

    stage_module_tree "${src_module}" "${dst_module}"
    copy_optional_sibling_dir "${extension_root}" "${dst_module}" "config"
    copy_optional_sibling_dir "${extension_root}" "${dst_module}" "data"
done

# IsaacLab computes extension root as one level above the module directory.
# In conda we colocate package assets inside each module, so patch the root.
for module in isaaclab isaaclab_assets isaaclab_contrib isaaclab_tasks; do
    init_py="${site_packages}/${module}/__init__.py"
    if [[ ! -f "${init_py}" ]]; then
        echo "Missing __init__.py for ${module}: ${init_py}" >&2
        exit 1
    fi
    legacy_expr='os.path.abspath(os.path.join(os.path.dirname(__file__), "../"))'
    patched_expr='os.path.abspath(os.path.dirname(__file__))'
    if grep -Fq "${legacy_expr}" "${init_py}"; then
        sed -i "s|${legacy_expr}|${patched_expr}|g" "${init_py}"
    fi
done
