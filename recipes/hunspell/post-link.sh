# Unfortunately, this can't detect if you actually did install a dictionary
# alongside aspell, as hunpell would be a dependency of such a package and
# would be linked first.
if [ ! -e "$PREFIX/conda-meta/aspell-[!0123456789]*" || ! -e "$PREFIX/share/hunspell_dictionaries/*.[da][if][cf]" ]; then
    echo "Note: The hunspell package does not come with any dictionaries. You should
install at least one dictionary, e.g., hunspell-en." > "$PREFIX/.messages.txt"
fi
