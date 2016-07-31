# Unfortunately, this can't detect if you actually did install a dictionary
# alongside aspell, as aspell would be a dependency of such a package and
# would be linked first.
if [ ! -e "$PREFIX/conda-meta/aspell-[!0123456789]*" ]; then
    echo "Note: The aspell package does not come with any dictionaries. You should
install at least one dictionary, e.g., aspell-en." > "$PREFIX/.messages.txt"
fi
