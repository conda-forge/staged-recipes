project(
  'sassc',
  'c',
  version: '3.6.2',
  meson_version: '>= 0.48.0',
  default_options: ['c_std=c99'],
)

version_conf_data = configuration_data()
version_conf_data.set('PACKAGE_VERSION', meson.project_version())

add_project_arguments(
  '-D_POSIX_C_SOURCE',
  '-DSASSC_VERSION="@0@"'.format(meson.project_version()),
  language: ['c'],
)

configure_file(
  input: 'sassc_version.h.in',
  output: 'sassc_version.h',
  configuration: version_conf_data,
)

libsass_dep = dependency(
  'libsass',
  fallback: ['libsass', 'libsass_dep'],
)

sassc_sources = ['sassc.c']

incs = []
if host_machine.system() == 'windows'
  windows = import('windows')
  win_res = windows.compile_resources(
    'res/libsass.rc',
    depend_files: ['res/libsass.ico'],
  )
  sassc_sources += win_res
  incs += include_directories('win/posix')
  sassc_sources += 'win/posix/getopt.c'
endif

sassc = executable(
  'sassc',
  sassc_sources,
  dependencies: [libsass_dep],
  include_directories: incs,
  install: true,
)

meson.override_find_program('sassc', sassc)
