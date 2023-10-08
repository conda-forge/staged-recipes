set -exou

# All files have been built by build.sh, this just installs them into ${PREFIX}

mkdir -p "${PREFIX}/bin"
mkdir -p "${PREFIX}/lib"
mkdir -p "${PREFIX}/lib/festival"
mkdir -p "${PREFIX}/share/festival"

# Prepare the dicts and voices directories. Dependent packages will put their dicts and voices there.
mkdir -p "${PREFIX}/share/festival/dicts"
mkdir -p "${PREFIX}/share/festival/voices"

cp src/main/festival "${PREFIX}/bin/"
cp src/main/festival_client "${PREFIX}/bin/"
cp bin/text2wave "${PREFIX}/bin/"
cp lib/etc/unknown_Linux/audsp "${PREFIX}/bin/audsp"

# The upstream package doesn't have separate libdir and datadir - it puts everything into lib, even data files like
# voices. Debian has more proper patches for this, however, we work it around by making the files and directories
# accessible both from lib and share/festival. This allows us to put data files into share/festival without the
# need for maintaining the more proper patch introducing separate datadir.
# https://salsa.debian.org/tts-team/festival/-/blob/master/debian/patches/20-debian-filesystem-standard.diff
cp -a lib/* "${PREFIX}/share/festival/"
rm -fv $(find "${PREFIX}/share/festival" -name Makefile)
for f in "${PREFIX}"/share/festival/*; do
  ln -s "$f" "${PREFIX}/lib/$(basename "$f")"
done
# Conda would delete the directories and symlinks to them if they were left empty, so we use a placeholder file.
echo "keep" > "${PREFIX}/share/festival/dicts/.keep"
echo "keep" > "${PREFIX}/share/festival/voices/.keep"

# text2wave contains a hardcoded path to the festival binary, so fix it
sed -i "s:$(pwd):${PREFIX}:g" "${PREFIX}/bin/text2wave"
