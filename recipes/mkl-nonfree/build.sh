#!/usr/bin/env bash
#  Taken from: https://aur.archlinux.org/packages/intel-mkl/

#     Copyright (C) 2016       Ignat Harczuk
# 
#     This program is free software: you can redistribute it and/or modify
#     it under the terms of the GNU General Public License as published by
#     the Free Software Foundation, either version 3 of the License, or
#     (at your option) any later version.
# 
#     This program is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#     GNU General Public License for more details.
# 
#     You should have received a copy of the GNU General Public License
#     along with this program.  If not, see <http://www.gnu.org/licenses/>.


export xe_build_dir=${SRC_DIR}
export _composer_xe_dir="compilers_and_libraries_2016.3.210"

if [ "$ARCH" = "32" ]; then
    _i_arch='ia32'
    _i_arch2='i486'

    _not_arch='intel64'
    _not_arch2='x86_64'
else
    _i_arch='intel64' 
    _i_arch2='x86_64'

    _not_arch='ia32' 
    _not_arch2='i486'
fi

# mkdir -p ${xe_build_dir}/opt
# mkdir -p ${xe_build_dir}/etc/ld.so.conf.d

# mkdir -p ${xe_build_dir}/etc/profile.d

# cp ${srcdir}/intel-mkl.sh ${xe_build_dir}/etc/profile.d
# chmod a+x ${xe_build_dir}/etc/profile.d/intel-mkl.sh

# cp ${srcdir}/intel-mkl-th.conf ${xe_build_dir}/etc/

# if [ "$ARCH" = "32" ]; then
#   sed 's/<arch>/ia32/' < ${srcdir}/intel-mkl.conf > ${xe_build_dir}/etc/ld.so.conf.d/intel-mkl.conf
# else
#   sed 's/<arch>/intel64/' < ${srcdir}/intel-mkl.conf > ${xe_build_dir}/etc/ld.so.conf.d/intel-mkl.conf
# fi

# cd ${xe_build_dir}

# extract_rpms() {
#   cd $2
#   for rpm_file in $1 ; do
#     echo -e "    Extracting: ${rpm_file}"
#     tar -xf ${rpm_file} 
#   done
# }

echo -e " # intel-mkl: Extracting RPMS"
for rpm_file in rpm/intel-mkl-*.rpm ; do
	echo -e "    Extracting: ${rpm_file}"
	rpm2cpio ${rpm_file} | cpio -idm
done

echo -e " # intel-mkl: Editing variables"
cd ${xe_build_dir}/opt/intel/${_composer_xe_dir}/linux/mkl/bin
rm mklvars.csh
sed -i "s:<INSTALLDIR>:$PREFIX:g" mklvars.sh

rm -rf ./${_not_arch}

#cd $_i_arch
#rm mklvars_${_i_arch}.csh
#sed -i 's/<INSTALLDIR>/\/opt\/intel\/composerxe\/linux/g' mklvars_${_i_arch}.sh

# if ${_remove_docs} ; then
echo -e " # intel-mkl: remove documentation"
#rm -rf ${xe_build_dir}/opt/intel/${_composer_xe_dir}/linux/Documentation
rm -rf ${xe_build_dir}/opt/intel/${_composer_xe_dir}/linux/mkl/examples
rm -rf ${xe_build_dir}/opt/intel/${_composer_xe_dir}/linux/mkl/benchmarks
# fi

# if ${_remove_static_objects_mkl} ; then
#   echo -e " # intel-mkl: remove static objects"
#   rm -f ${xe_build_dir}/opt/intel/${_composer_xe_dir}/linux/mkl/lib/${_i_arch}/libmkl_*.a
#   rm -f ${xe_build_dir}/opt/intel/${_composer_xe_dir}/linux/mkl/lib/mic/libmkl_*.a
# fi

echo -e " # intel-mkl: Move package"
mv ${xe_build_dir}/opt ${PREFIX}
# mv ${xe_build_dir}/etc ${PREFIX}