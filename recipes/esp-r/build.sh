#!/bin/bash
# Build and install ESP-r.
#
# Upstream ships an interactive `Install` script that looks for its
# dependencies in /usr, hardcodes the compiler names and installs into
# /opt/esp-r. This script performs the same steps as
#   ./Install -d ${PREFIX}/opt/esp-r --silent --X11 --xml
# but drives the upstream makefiles directly with the conda toolchain.
set -euxo pipefail

HOMEdir="${SRC_DIR}"
SRCdir="${HOMEdir}/src"
DATdir="${HOMEdir}/data"
DOCdir="${HOMEdir}/doc"
MODdir="${HOMEdir}/models"
SCRIPTdir="${SRCdir}/bin"
ESPdir="${PREFIX}/opt/esp-r"

programs="aco b2e bps dfs dfv cdb c2e clm e2r ecnv eco enet grd ish mfs mld mrt pdb prj res vew"

# The makefiles call ar, ranlib and strip by their bare names.
shims="${HOMEdir}/_shims"
mkdir -p "${shims}"
ln -sf "$(command -v "${AR}")" "${shims}/ar"
ln -sf "$(command -v "${RANLIB}")" "${shims}/ranlib"
ln -sf "$(command -v "${STRIP}")" "${shims}/strip"
export PATH="${shims}:${PATH}"

# ---------------------------------------------------------------------------
# Generated headers (normally written by the Install script).
# ---------------------------------------------------------------------------

# Model complexity: "medium", the upstream default.
cp "${SRCdir}/include/building_medium.h" "${SRCdir}/include/building.h"

# Location of the installation. Upstream compiles the absolute install path
# into every executable, which is not relocatable; look it up at run time.
cat > "${SRCdir}/include/espinstalldir.h" << 'EOF'
c Where ESP-r is installed (conda-forge: resolved at run time from
c the ESPRDIR environment variable, then from the active conda
c environment).
       character instpath*60
       character instpfx*200
       integer instln,instst
       call get_environment_variable('ESPRDIR',instpath,instln,
     &   instst)
       if(instst.gt.0.or.instln.eq.0)then
         call get_environment_variable('CONDA_PREFIX',instpfx,instln,
     &     instst)
         if(instst.le.0.and.instln.gt.0)then
           instpath = instpfx(1:min(instln,200))//'/opt/esp-r'
           if(instln.gt.50) instst = -1
         else
           instpath = '/opt/esp-r'
           instst = 0
         endif
       endif
       if(instst.lt.0)then
         write(0,'(a)') 'ESP-r: the installation path is too long'
     &   //' (limit: 60 characters); set the ESPRDIR'
         write(0,'(a)') 'environment variable to a shorter symbolic'
     &   //' link to <environment>/opt/esp-r.'
       endif
EOF

release="$(grep "ESP-r " "${HOMEdir}/Version" | sed "s/ESP-r //g")"
cat > "${SRCdir}/include/build_info.h" << EOF
C      build_info.h
C
C      Versioning and build information for the ESP-r system, used by
C      ESPrVersion() in common/Startup.F (conda-forge build).

       logical  bRelease,bVersioned,bModified
       character cBuilder*32       ! User who compiled system
       character cArchitecture*32  ! Machine architecture
       character cOperSystem*32    ! Operating system
       character cOSversion*32     ! Operating system version
       character cHost*256         ! Host name
       character cRelease_Num*30   ! Release version
       character cSource*32        ! Repository version
       character cBranch*48        ! Branch name
       character cRevision*32      ! Revision number
       character cState*32         ! Flag for repository state
       character cCC*32            ! Flags for C compiler
       character cFC*32            ! Flags for Fortran compiler
       character cCPL*32           ! Flags for C++ compiler
       character cXML_support*32   ! XML compile-time options
       character cSQLite_support*32! SQLite compile-time options
       character cXlibrary*32      ! X11 library location

       cBuilder          = "conda-forge"
       cHost             = "conda-forge"
       cArchitecture     = "${target_platform#*-}"
       cOperSystem       = "Linux"
       cOSversion        = ""
       bRelease          = .TRUE.
       cRelease_num      = "${release}"
       bVersioned        = .FALSE.
       bModified         = .FALSE.
       cSource           = "v${PKG_VERSION}"
       cBranch           = ""
       cRevision         = ""
       cState            = "Vanilla"
       cCC               = "gcc"
       cFC               = "gfortran"
       cCPL              = "g++"
       cXML_support      = "supported"
       cSQLite_support   = "unsupported"
       cXlibrary         = "X11"
EOF

# ---------------------------------------------------------------------------
# Compiler and linker flags (same layout as in the Install script).
# ---------------------------------------------------------------------------

local_includes="-I../include -I../shocc -I../cetc/h3kreports"
defines="-DLIN -DX11"

# -O1 is the optimisation level upstream uses and tests; it comes last so
# that it takes precedence over the conda-forge default.
esp_fflags="${FFLAGS} ${local_includes} ${defines} -O1 -fno-automatic -DGCC4"
if [[ "${target_platform}" == "linux-64" ]]; then
  # Needed for the large static data structures of the simulator.
  esp_fflags="${esp_fflags} -mcmodel=medium"
fi

# The makefiles use CFLAGS for both C and C++ sources.
esp_cflags="${CFLAGS} ${local_includes} -I${PREFIX}/include"
esp_cflags="${esp_cflags} -I${PREFIX}/include/freetype2 -I${PREFIX}/include/libxml2"
esp_cflags="${esp_cflags} ${defines} -DXSL -O1"
# The C sources are pre-C99 (implicit int, implicit function declarations),
# which recent GCC versions reject by default.
esp_cflags="${esp_cflags} -fpermissive"
# They also declare functions as "void f();" and call them with arguments,
# which is an error in C23, the default standard from GCC 15 on. The option
# is given with the C compiler because CFLAGS is also passed to C++.
esp_cc="${CC} -std=gnu17"

esp_ulibs="-L${SRCdir}/lib -lversion -lxesru -L${PREFIX}/lib -lX11 -lXft"
esp_ulibs="${esp_ulibs} -lXML -lstdc++ -lxslt -lxml2 -lSQLite"

# GTKFLAGS is emptied because the makefile of the support library fills it
# from pkg-config (for GTK 2) even for the X11 build.
esp_make() {
  make -C "${SRCdir}" \
    MCTYPE=lin MCC="${esp_cc}" MCPL="${CXX}" MFC="${FC}" \
    DESTdir="${ESPdir}" ESPdir="${ESPdir}" ESPBinDir="${ESPdir}/bin" \
    WWLINK=unshared EXE="" XINSTALLDIR="${PREFIX}" \
    CFLAGS="${esp_cflags}" FFLAGS="${esp_fflags}" \
    LD_FLAGS="${LDFLAGS}" ULIBS="${esp_ulibs}" \
    FMIarg=disableFMI GTKFLAGS="" "$@"
}

# ---------------------------------------------------------------------------
# Build.
# ---------------------------------------------------------------------------

# Support libraries: X11 graphics, XML/CSV output (H3K reports), SQLite stub.
for target in libX11 enableXML disableSQLite; do
  esp_make "${target}"
done
for lib in libxesru.a libversion.a libXML.a libSQLite.a; do
  test -s "${SRCdir}/lib/${lib}"
done

# The makefiles do not track the Fortran module dependencies, so each program
# is built serially; the programs are independent and are built in parallel.
export -f esp_make
export SRCdir ESPdir esp_cc esp_cflags esp_fflags esp_ulibs
echo ${programs} | tr ' ' '\n' | xargs -P "${CPU_COUNT}" -I{} \
  bash -c 'esp_make "$1" > "build_$1.log" 2>&1 || { cat "build_$1.log"; exit 255; }' _ {}

# ---------------------------------------------------------------------------
# Install.
# ---------------------------------------------------------------------------

mkdir -p "${ESPdir}"/{bin,climate,databases,electric_loads,lib,manual,xsl,scripts}

# Executables.
esp_make InstBins ${programs}
ln -s mrt "${ESPdir}/bin/vwf"
cp -r "${HOMEdir}/modish" "${ESPdir}/bin"

cat > "${ESPdir}/bin/esp-r" << 'EOF'
#!/bin/sh
# Start the ESP-r Project Manager.
if [ "X$EFONT_0" = "X" ]; then
  EFONT_0=6x12
  EFONT_1=6x13
  EFONT_2=8x13
  EFONT_3=9x15
  export EFONT_0 EFONT_1 EFONT_2 EFONT_3
fi
prj "$@" &
EOF
chmod a+x "${ESPdir}/bin/esp-r"

# Make the executables available on the PATH of the environment.
mkdir -p "${PREFIX}/bin"
for exe in "${ESPdir}"/bin/*; do
  if [[ -f "${exe}" && -x "${exe}" ]]; then
    ln -s "../opt/esp-r/bin/$(basename "${exe}")" "${PREFIX}/bin/$(basename "${exe}")"
  fi
done

# Help files and bitmaps.
cp "${SRCdir}"/tutorial/*.help "${ESPdir}/lib"
cp "${SRCdir}"/bitmaps/*.xbm "${ESPdir}/lib"

# Defaults file.
cat > "${ESPdir}/default" << EOF
*ESP-r Defaults
*ipth ${ESPdir}
*cfg ${ESPdir}/training/basic/cfg/bld_basic.cfg
*ctl ${ESPdir}/training/basic/ctl/bld_basic.ctl
*mfn ${ESPdir}/training/basic/nets/bld_basic_af1.afn
*dfd ${ESPdir}/training/cfd/template.dfd
*pnf ${ESPdir}/training/plant/vent_simple/cfg/vent.cfg
*res ${ESPdir}/databases/test.res
*mfr ${ESPdir}/databases/test.mfr
*clm ${ESPdir}/climate/clm67
*prs ${ESPdir}/databases/pressc.db1
*prm ${ESPdir}/databases/material.db
*mlc ${ESPdir}/databases/multicon.db
*opt ${ESPdir}/databases/optics.db
*evn ${ESPdir}/databases/profiles.db2.a
*pdb ${ESPdir}/databases/plantc.db1
*ecdb ${ESPdir}/databases/elcomp.db1
*mcdb ${ESPdir}/databases/mscomp.db1
*icdb ${ESPdir}/databases/icons.db1
*mldb ${ESPdir}/databases/mould.db1
*sbem ${ESPdir}/databases/SBEM.db1
*cfcdb ${ESPdir}/databases/CFClayers.db2.a
*pre ${ESPdir}/databases/predefined.db1
*end
EOF

# Preferences file. The upstream entries locating the defaults file, the
# weather list, the exemplars and the validation standards are left out: the
# programs then derive them from the installation path found at run time.
cat > "${ESPdir}/esprc" << EOF
*ESPRC
*gprn,rectangular dump,import
*tprn,Text dump,/tmp/tx_dump
*gxwd,screen dump,import -window root
*cad,CAD package,gtool,UNKN
*image_display,TIF,display
*image_display,XBMP,display
*image_display,GIF,display
*image_display,XWD,display
*image_display,PNG,display
*journal,OFF
*session,OFF
*editor,editor,nedit
*report_gen,Reporting tool,xfs
*end
EOF

# The freshly built tools are needed to convert the ASCII databases to
# binary. They are run through a short symbolic link to the installation
# because ESP-r cannot handle a path as long as the conda build prefix.
short_esp="$(mktemp -u /tmp/espr-XXXXXX)"
ln -s "${ESPdir}" "${short_esp}"
trap 'rm -f "${short_esp}"' EXIT
export ESPRDIR="${short_esp}"
PDB="${ESPdir}/bin/pdb"
CLM="${ESPdir}/bin/clm"

# Materials, constructions, optics and miscellaneous databases.
cd "${DATdir}/databases"
cp multicon.db multicon.db3 multicon.db4 multicon.db5 \
   ccht_constr.db1 ccht_na_constr.db1 ccht_material.ascii \
   cellular.materialdb north_american.materialdb.a north_american.constrdb \
   material.db material.db3.a material.db4.a \
   CFClayers.db1.a CFClayers.db2.a SBEM.db1 UK_notional.constrdb \
   optics.db optics.db2 optics.db3 ccht-optics.db1 mould.db1 pressc.db1 \
   predefined.db1 flow_icons.db6 profiles.db2.a icons.db1 \
   multi_seg_occup_DB.txt \
   components.db1 mscomp.db1 mscomp.db2 *.desc \
   "${ESPdir}/databases"

# Plant component databases.
for db in plantc.db1 plantc.db2 plantc.tt; do
  "${PDB}" -mode text -file "${db}" -act asci2bin "${db}.a" > /dev/null
  test -s "${db}"
  mv "${db}" "${ESPdir}/databases"
done

# Weather databases.
cd "${DATdir}/climate"
sed -e "s|/opt/esp-r|${ESPdir}|" climatelist > "${ESPdir}/climate/climatelist"
cp README "${ESPdir}/climate/Readme"
cp README_IWEC "${ESPdir}/climate/Readme_iwec"
for ascii in *.a; do
  binary="${ascii%.a}"
  rm -f "${binary}"
  "${CLM}" -mode text -file "${binary}" -act asci2bin silent "${ascii}" > /dev/null 2>&1
  test -s "${binary}"
  mv "${binary}" "${ESPdir}/climate"
done

# Manual, support scripts and XSLT style sheets for the XML output.
cp -r "${DOCdir}/manual/." "${ESPdir}/manual"
cp "${SCRIPTdir}"/{link_to_bash,link_to,Linux_model_2dos,Linux_model_to_dos,dos_model_to_linux} \
   "${SCRIPTdir}"/convert_idf_2_espr.sh "${SCRIPTdir}"/*_fromEplusModel.py \
   "${SCRIPTdir}"/pandoc_ref.docx \
   "${ESPdir}/scripts"
cp "${SRCdir}"/cetc/h3kreports/xsl/*.xsl "${ESPdir}/xsl"

# Training and validation models.
cd "${MODdir}/training/Temporal_Clm"
"${CLM}" -mode text -file 15265.climate -act asci2bin 15265.climate.a > /dev/null
cd "${MODdir}/validation/CEN/13791/databases"
for clm in Cond.clm WM_A.clm WM_B.clm; do
  "${CLM}" -mode text -file "${clm}" -act asci2bin silent "${clm}.a" > /dev/null
  test -s "${clm}"
done
cp -r "${MODdir}/training" "${MODdir}/validation" "${ESPdir}"
# Prebuilt 32-bit executable shipped with one of the validation models.
rm "${ESPdir}/validation/CEN/13791/whole_model/glazing"
cd "${MODdir}"
sed -e "s|/opt/esp-r|${ESPdir}|" training/exemplars > "${ESPdir}/training/exemplars"
sed -e "s|/opt/esp-r|${ESPdir}|" validation/stds_list > "${ESPdir}/validation/stds_list"
# Point the models to the installation directory.
find training validation \( -name "*.cfg" -o -name "*.pln" \) -print0 |
  while IFS= read -r -d '' file; do
    sed -e "s|/usr/esru|${ESPdir}|" "${file}" > "${ESPdir}/${file}"
  done

# The example results database of an upstream installation
# (databases/test.res) is not generated: it would record the absolute
# location of the model at build time, which no longer exists once the
# package is installed.

# Conda packages cannot contain empty directories, but the models rely on
# their (initially empty) folders, e.g. "tmp" where the results are written.
find "${ESPdir}" -type d -empty -exec touch {}/.keep \;
