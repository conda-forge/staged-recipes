set -ex

mkdir -p "${PREFIX}/Menu"
cp "${RECIPE_DIR}/menu.json" "${PREFIX}/Menu/${PKG_NAME}_menu.json"
if [[ $(uname) == Darwin ]]; then
    mkdir -p "${PREFIX}/bin"
    ROOT_PREFIX=$(${CONDA_PYTHON_EXE} -c "from conda.base.context import context; print(context.root_prefix)")
    sed -e "s#__PREFIX__#${PREFIX}#" -e "s#__ROOT_PREFIX__#${ROOT_PREFIX}#" ${RECIPE_DIR}/miniforge_prompt_osx > "${PREFIX}/bin/miniforge_prompt"
    chmod 554 "${PREFIX}/bin/"
    ICON_EXT="icns"
else
    ICON_EXT="png"
fi
cp "${RECIPE_DIR}/miniforge_prompt.${ICON_EXT}" "${PREFIX}/Menu/"
