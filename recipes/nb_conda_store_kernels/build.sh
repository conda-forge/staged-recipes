$PYTHON -m pip install --no-deps --ignore-installed .

mkdir -p "$PREFIX"/bin

POST_LINK="$PREFIX"/bin/.nb_conda_store_kernels-post-link.sh
PRE_UNLINK="$PREFIX"/bin/.nb_conda_store_kernels-pre-unlink.sh

cp "$RECIPE_DIR"/post-link.sh "$POST_LINK"
cp "$RECIPE_DIR"/pre-unlink.sh "$PRE_UNLINK"

chmod +x "$POST_LINK" "$PRE_UNLINK"
