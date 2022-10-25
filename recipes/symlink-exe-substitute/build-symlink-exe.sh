#! /bin/sh

set -eu

source_file="$( dirname -- "$( readlink -e "${0}" )" )/../Library/symlink-exe.c"

err_exit() {
  1>&2 printf '%s\n' "${@}"
  exit 1
}

for out_path do true ; done
[ -n "${out_path-}" ] ||
  err_exit 'Last argument must be output directory, e.g., "%PREFIX%\Scripts"'
if ! [ -e "${out_path}" ] ; then
  mkdir -p "${out_path}" ||
    err_exit "Could not create output directory \"${out_path}\""
fi
[ -d "${out_path}" ] ||
  err_exit 'Last argument must be output directory, e.g., "%PREFIX%\Scripts"'

paths="$(
  for arg do
    if ! [ "${arg}" = "${out_path}" ] ; then
      printf '%s|%s\n' \
        "$(
          dirname "$( realpath --relative-to="${out_path}" -- "${arg}" )" |
            sed -e 's / \\ g' -e 's \\ \\\\ g'
        )" \
        "${arg}"
    fi
  done | sort
)"

IFS='
'
set -- ${paths}
prev_basename=
prev_rel_path=
for arg do
  exe_path="${arg#*|}"
  rel_path="${arg%|*}"
  [ "${exe_path}" = "${out_path}" ] && continue
  [ -e "${exe_path}" ] ||
    err_exit "Path \"${exe_path}\" does not exist"
  [ -f "${exe_path}" ] && [ -x "${exe_path}" ] ||
    err_exit "Path \"${exe_path}\" must be an executable"
  basename="$( basename "${exe_path}" )"
  if [ "${rel_path}" = "${prev_rel_path}" ] ; then
    cp "${out_path}/${prev_basename}" "${out_path}/${basename}" ||
      err_exit "Could not create \"${out_path}/${basename}\""
  else
    cl -O1 -Os -Gy -MD \
      "-DRELATIVE_PATH=\"${rel_path}\"" \
      -Fe"${out_path}\\${basename}" \
      "${source_file}" -link -FIXED ||
        err_exit "Could not compile \"${out_path}/${basename}\""
    prev_basename="${basename}"
    prev_rel_path="${rel_path}"
  fi
done
