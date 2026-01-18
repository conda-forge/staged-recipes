install_headers('sass.h', 'sass2scss.h')

version_conf_data = configuration_data()
version_conf_data.set('PACKAGE_VERSION', meson.project_version())

version_h = configure_file(
  input: 'sass/version.h.in',
  output: 'version.h',
  configuration: version_conf_data,
)

install_headers(
  'sass/base.h',
  'sass/context.h',
  'sass/functions.h',
  'sass/values.h',
  version_h,
  subdir: 'sass',
)
