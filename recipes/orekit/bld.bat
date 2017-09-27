"%PYTHON%" -m jcc  ^
--use_full_names ^
--python orekit ^
--version %PKG_VERSION% ^
--jar %SRC_DIR%\orekit-9.0.jar ^
--jar %SRC_DIR%\hipparchus-core-1.1.jar ^
--jar %SRC_DIR%\hipparchus-fitting-1.1.jar ^
--jar %SRC_DIR%\hipparchus-geometry-1.1.jar ^
--jar %SRC_DIR%\hipparchus-ode-1.1.jar ^
--jar %SRC_DIR%\hipparchus-optim-1.1.jar ^
--jar %SRC_DIR%\hipparchus-stat-1.1.jar ^
--package java.io ^
--package java.util ^
--package java.text ^
--package org.orekit ^
java.io.BufferedReader ^
java.io.FileInputStream ^
java.io.FileOutputStream ^
java.io.InputStream ^
java.io.InputStreamReader ^
java.io.ObjectInputStream ^
java.io.ObjectOutputStream ^
java.io.PrintStream ^
java.io.StringReader ^
java.io.StringWriter ^
java.lang.System ^
java.text.DecimalFormat ^
java.text.DecimalFormatSymbols ^
java.util.ArrayList  ^
java.util.Arrays  ^
java.util.Collection  ^
java.util.Collections ^
java.util.Date ^
java.util.HashMap ^
java.util.HashSet ^
java.util.List  ^
java.util.Locale ^
java.util.Map ^
java.util.Set ^
java.util.TreeSet ^
--module %SRC_DIR%\pyhelpers ^
--reserved INFINITE ^
--reserved ERROR ^
--reserved NAN ^
--reserved OVERFLOW ^
--reserved NO_DATA ^
--reserved min ^
--reserved max ^
--reserved mean ^
--build ^
--install
if errorlevel 1 exit 1
