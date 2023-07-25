set -exou

# The festival file system hierarchy is insane; here we correct a few preconfigured folders

sed -i "s#^EST=.*\$#EST=${BUILD_PREFIX}/lib/speech_tools#" config/config.in  # Path to libestools
sed -i "s#^FTLIBDIR =.*\$#FTLIBDIR = ${PREFIX}/lib#" config/project.mak  # Where the installed libraries AND dictionaries/voices can be found
sed -i "s#^INSTALL_PREFIX=.*\$#INSTALL_PREFIX=${PREFIX}#" config/systems/default.mak
sed -i "s#\$(FESTIVAL_HOME)/bin/festival#${PREFIX}/bin/festival#" examples/Makefile
sed -i "s#/projects/festival/lib/dicts#${PREFIX}/share/festival/dicts#" lib/lexicons.scm  # Default path for dictionaires (can be overriden with --libdir).

./configure

# This make call just generates a file on which we need to apply the following sed commands, too
make modules
(cd src/modules; make init_modules.cc)

# The include statements do not follow any filesystem hierarchy. This command straightens that up. Let's pray it is correct!
# Base for this command was taken from Arch linux: https://github.com/archlinux/svntogit-packages/blob/packages/festival/trunk/PKGBUILD
for i in $(find src/ -type f); do
  sed -i -e 's,"EST.*\.h",\<speech_tools/&\>,g' -e 's,speech_tools/\",speech_tools/,g' -e 's,<\(EST_walloc\.h\)>,\<speech_tools/\1\>,g' \
      -e 's,"siod.*\.h",\<speech_tools/&\>,g' -e 's,speech_tools/\",speech_tools/,g' \
      -e 's,"instantiate/.*\.h",\<speech_tools/&\>,g' -e 's,speech_tools/instantiate/\",speech_tools/instantiate/,g' -e 's,"instantiate,instantiate,g' \
      -e 's,"ling_class/.*\.h",\<speech_tools/&\>,g' -e 's,speech_tools/ling_class/\",speech_tools/ling_class/,g' -e 's,"ling_class,ling_class,g' \
      -e 's,"rxp/.*\.h",\<speech_tools/&\>,g' -e 's,speech_tools/rxp/\",speech_tools/rxp/,g' -e 's,\"rxp.h\",\<speech_tools/rxp/rxp.h\>,' \
      -e 's,"sigpr/.*\.h",\<speech_tools/&\>,g' -e 's,speech_tools/sigpr/\",speech_tools/sigpr/,g' -e 's,"sigpr,sigpr,g' \
      -e 's,"unix/.*\.h",\<speech_tools/&\>,g' -e 's,speech_tools/unix/\",speech_tools/unix/,g' -e 's,\.h\">,.h\>,g' -e 's,"unix,unix,g' \
      -e 's,<speech_tools/\(EST_.*Cost.h\)>,\"\1\",g'  -e 's,<speech_tools/\(EST_.*Cache.h\)>,\"\1\",g'  -e 's,<speech_tools/\(EST_.*Coverage.h\)>,\"\1\",g' \
      -e 's,\"\.\./\(base_class/.*\)\",\<speech_tools/\1\>,g' $i;
done

# Use shared libs
echo "GCC_MAKE_SHARED_LIB = gcc -shared -o XXX" >> config/systems/default.mak

make  # cannot build in parallel, the build system does not support it

make install  # only copies files inside the build directory

# Now also impose hierarchy on the festival-own includes (cannot do that before build, it would fail)
for i in $(find src/ -type f); do
  sed -i -e 's,"festival\.h",\<festival/festival.h\>,g' \
      -e 's,"ModuleDescription\.h",\<festival/ModuleDescription.h\>,g' \
      -e 's,"Phone\.h",\<festival/Phone.h\>,g' $i
done

