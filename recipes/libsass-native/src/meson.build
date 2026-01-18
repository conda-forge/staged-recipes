cpp_sources = [
  'ast.cpp',
  'ast_values.cpp',
  'ast_supports.cpp',
  'ast_sel_cmp.cpp',
  'ast_sel_unify.cpp',
  'ast_sel_super.cpp',
  'ast_sel_weave.cpp',
  'ast_selectors.cpp',
  'context.cpp',
  'constants.cpp',
  'fn_utils.cpp',
  'fn_miscs.cpp',
  'fn_maps.cpp',
  'fn_lists.cpp',
  'fn_colors.cpp',
  'fn_numbers.cpp',
  'fn_strings.cpp',
  'fn_selectors.cpp',
  'color_maps.cpp',
  'environment.cpp',
  'ast_fwd_decl.cpp',
  'bind.cpp',
  'file.cpp',
  'util.cpp',
  'util_string.cpp',
  'json.cpp',
  'units.cpp',
  'values.cpp',
  'plugins.cpp',
  'source.cpp',
  'position.cpp',
  'lexer.cpp',
  'parser.cpp',
  'parser_selectors.cpp',
  'prelexer.cpp',
  'eval.cpp',
  'eval_selectors.cpp',
  'expand.cpp',
  'listize.cpp',
  'cssize.cpp',
  'extender.cpp',
  'extension.cpp',
  'stylesheet.cpp',
  'output.cpp',
  'inspect.cpp',
  'emitter.cpp',
  'check_nesting.cpp',
  'remove_placeholders.cpp',
  'sass.cpp',
  'sass_values.cpp',
  'sass_context.cpp',
  'sass_functions.cpp',
  'sass2scss.cpp',
  'backtrace.cpp',
  'operators.cpp',
  'ast2c.cpp',
  'c2ast.cpp',
  'to_value.cpp',
  'source_map.cpp',
  'error_handling.cpp',
  'memory/allocator.cpp',
  'memory/shared_ptr.cpp',
  'utf8_string.cpp',
  'base64vlq.cpp',
]

c_sources = ['cencode.c']

sass_sources = cpp_sources + c_sources

if host_machine.system() == 'windows'
  windows = import('windows')
  sass_sources += [windows.compile_resources(winres_path)]
endif

if host_machine.system() != 'windows'
  if meson.version().version_compare('>= 0.62')
    dl_dep = dependency('dl')
  else
    dl_dep = cc.find_library(
      'dl',
      required: false,
    )
  endif
else
  dl_dep = dependency(
    '',
    required: false,
  )
endif

lib_args = []
if host_machine.system() == 'windows' and get_option('default_library') != 'static'
  lib_args += ['-DADD_EXPORTS']
endif

libsass = library(
  'sass',
  sass_sources,
  dependencies: [dl_dep],
  c_args: lib_args,
  cpp_args: lib_args,
  include_directories: inc,
  soversion: '1',
  install: true,
)

libsass_dep = declare_dependency(
  link_with: libsass,
  include_directories: [inc],
)

pkg = import('pkgconfig')
pkg.generate(
  libsass,
  name: 'libsass',
  description: 'A C implementation of a Sass compiler',
  url: 'https://github.com/sass/libsass',
)
