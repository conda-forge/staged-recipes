# PROBLEMS when building within emscripten_forge
# python3 dependency does not find the right headers: it must be added when calling meson
# pybind11 dependency is not found, due to the lack of pybind11-config: it is also added in meson call

# thread_dep = dependency('threads')

py3_inst = import('python').find_installation('python')
python3 = py3_inst.dependency()

# pybind11_inc = include_directories(meson.project_build_root() + '/include/pybind11')
# pybind11 = declare_dependency(include_directories : pybind11_inc)

#pybind11 = dependency('pybind11')
#pybind11_inc = include_directories('/home/pablo/.local/opt/micromamba/envs/emscripten-forge/conda-bld/dynare-preprocessor-pylib-0_1701688424528/_h_env_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_placehold_/include/pybind11')
#pybind11 = declare_dependency(include_directories : pybind11_inc)

# boost_dep = dependency('pybind11')

boost_dep = dependency('boost')

## Flex stuff
flex_exe = find_program('flex')
# The -Ca flag comes from hitting a hard-coded size limit.
# Partial explanation: https://www.owlfolio.org/possibly-useful/flex-input-scanner-rules-are-too-complicated
# There is a Debian bug report about this: https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=642040
flex_gen = generator(flex_exe, output : '@BASENAME@.cc',
                     arguments : ['-Ca', '-o', '@OUTPUT@', '@INPUT@'])
flex_src = flex_gen.process('macro/Tokenizer.ll', 'DynareFlex.ll')
# If FlexLexer.h is not found by the compiler, copy it to the build directory
# (adding an include directory could create problems for cross-compilation, because
# flex is typically provided by the system of the build machine)
if not cpp_compiler.has_header('FlexLexer.h')
  message('FlexLexer.h cannot be found by the compiler, it will be manually copied to the build directory')
  fs = import('fs')
  flexlexer_h = fs.copyfile(fs.parent(fs.parent(flex_exe.full_path())) / 'include' / 'FlexLexer.h', 'FlexLexer.h')
else
  flexlexer_h = []
endif

## Bison stuff
bison_exe = find_program('bison')
# By convention, all our Bison source files define the api.location.file variable
# so that the generated location file follows the @BASENAME@Location.hh pattern
bison_gen = generator(bison_exe, output : ['@BASENAME@.cc', '@BASENAME@.hh', '@BASENAME@Location.hh'],
                      arguments : ['-W', '-o', '@OUTPUT0@', '@INPUT@'])
bison_src = bison_gen.process('macro/Parser.yy', 'DynareBison.yy')

preprocessor_incdir = include_directories('.', 'macro')

preprocessor_src = [ 'ComputingTasks.cc',
	             'EquationTags.cc',
	             'ModelTree.cc',
	             'StaticModel.cc',
	             'DynamicModel.cc',
	             'NumericalConstants.cc',
	             'NumericalInitialization.cc',
	             'Shocks.cc',
	             'SymbolTable.cc',
	             'SymbolList.cc',
	             'ParsingDriver.cc',
	             'DataTree.cc',
	             'ModFile.cc',
	             'ConfigFile.cc',
	             'Statement.cc',
	             'ExprNode.cc',
	             'VariableDependencyGraph.cc',
	             'DynareMain.cc',
	             'MacroExpandModFile.cc',
	             'Bytecode.cc',
	             'ExternalFunctionsTable.cc',
	             'ModelEquationBlock.cc',
	             'WarningConsolidation.cc',
	             'SubModel.cc',
                     'macro/Driver.cc',
	             'macro/Environment.cc',
	             'macro/Expressions.cc',
	             'macro/Directives.cc' ]

if get_option('prefer_static')
  preprocessor_link_args = [ '-static-libgcc', '-static-libstdc++' ]
  if host_machine.system() == 'windows'
    # See comment in rules for MEX files
    preprocessor_link_args += [ '-Wl,-Bstatic', '-lssp', '-Wl,-Bdynamic',
                                '-Wl,-Bstatic,--whole-archive', '-lwinpthread', '-Wl,-Bdynamic,--no-whole-archive' ]
  endif
else
  preprocessor_link_args = []
endif

# executable('dynare-preprocessor', preprocessor_src, flex_src, flexlexer_h, bison_src,
#           include_directories : preprocessor_incdir, dependencies : boost_dep,
#           link_args : preprocessor_link_args,
#           install : true)

py3_inst.extension_module('dynare_preprocessor', preprocessor_src, flex_src, flexlexer_h, bison_src, 'DynLib.cc', include_directories : preprocessor_incdir,
	dependencies : [boost_dep, python3],
	#dependencies : [boost_dep, python3, pybind11],
    link_args : preprocessor_link_args, install: true)