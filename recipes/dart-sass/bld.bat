:: would be better to build a native binary, but this seems broken.
:: error looks like this:
::
:: (%PREFIX%) %SRC_DIR%>dart compile exe bin\sass.dart -o %PREFIX%\Library\bin\sass.exe
:: Unhandled exception:
:: Crash when compiling null,
:: at character offset null:
:: Bad state: No element
:: #0      List.single (dart:core-patch/growable_array.dart:353:22)
:: #1      ClassBuilderImpl.buildTypeWithBuiltArguments (package:front_end/src/fasta/builder/class_builder.dart:324:44)
:: #2      ClassBuilderImpl.buildType (package:front_end/src/fasta/builder/class_builder.dart:335:12)

:: may be related to https://github.com/flutter/flutter/issues/92757

:: dart pub get
:: dart compile exe bin\sass.dart -o %LIBRARY_BIN%\sass.exe

npm i -g sass@%PKG_VERSION%
