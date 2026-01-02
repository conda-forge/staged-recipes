project(
  'libsass',
  'c',
  'cpp',
  version: '3.6.6',
  license: 'MIT',
  meson_version: '>= 0.48.0',
  default_options: ['c_std=c99', 'cpp_std=c++11'],
)

add_project_arguments(
  '-DLIBSASS_VERSION="@0@"'.format(meson.project_version()),
  language: ['cpp'],
)

inc = include_directories('include')
winres_path = files(join_paths('res', 'resource.rc'))

subdir('include')
subdir('src')
