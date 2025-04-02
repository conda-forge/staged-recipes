
echo "Setting Archive Path"
if [ "$(uname -s)" == "Darwin" ]
then
    ARCHIVE_PATH="Contents/Home/"
else
    ARCHIVE_PATH=""
fi

echo "... set to '$ARCHIVE_PATH'"

echo "Copying java files"
for ITEM in libawt_xawt libsplashscreen libjsound libjawt
do
    echo "... item $ITEM"
    cp ${ARCHIVE_PATH}lib/${ITEM}.* ${PREFIX}/opt/temurin/lib/
done
