set -exou

# All files have been built by build.sh, this just installs them into ${PREFIX}

mkdir -p "${PREFIX}/bin"
mkdir -p "${PREFIX}/lib"
mkdir -p "${PREFIX}/lib/festival"
mkdir -p "${PREFIX}/share/festival"

# Prepare the dicts and voices directories. Dependent packages will put their dicts and voices there.
mkdir -p "${PREFIX}/share/festival/dicts"
mkdir -p "${PREFIX}/share/festival/voices"
# Conda would delete the directories if they were left empty, so we use a placeholder file.
echo "keep" > "${PREFIX}/share/festival/dicts/.keep"
echo "keep" > "${PREFIX}/share/festival/voices/.keep"

cp src/main/festival "${PREFIX}/bin/"
cp src/main/festival_client "${PREFIX}/bin/"
cp bin/text2wave "${PREFIX}/bin/"

# Yes, we're copying lib files into share, as there it makes sense. In a later part of this script, we'll make symlinks from lib.
cp -a lib/* "${PREFIX}/share/festival/"
rm -fv $(find "${PREFIX}/share/festival" -name Makefile)

# Crazy...
ln -s "${PREFIX}/share/festival/etc/unknown_Linux/audsp" "${PREFIX}/lib/festival/audsp"
ln -s "${PREFIX}/share/festival/etc/unknown_Linux/audsp" "${PREFIX}/bin/audsp"

# text2wave contains a hardcoded path to the festival binary, so fix it
sed -i "s:$(pwd):${PREFIX}:g" "${PREFIX}/bin/text2wave"

# Crazy... All files from share/festival have to also be accessible from lib/
for f in "${PREFIX}"/share/festival/*; do
  ln -s "$f" "${PREFIX}/lib/$(basename "$f")"
done
