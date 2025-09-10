#!/usr/bin/env nu

# RNNoise build script using nushell for cross-platform compatibility

print "🔨 RNNoise build script starting..."

# Check environment variables
print $"📁 Current directory: (pwd)"
print $"📂 SRC_DIR: ($env.SRC_DIR)"
print $"🖥️  Platform: ($nu.os-info.name)"

# Verify source directory exists
if not ($env.SRC_DIR | path exists) {
    print "❌ Error: SRC_DIR does not exist"
    exit 1
}

print $"✅ Found source directory at ($env.SRC_DIR)"

# Platform-specific build logic
if ($nu.os-info.name == "windows") {
    # Windows build using CMake approach
    print "🪟 Building on Windows using CMake approach..."

    let build_type = "Release"

    # Use Ninja generator since it's a declared dependency
    print "🔧 Using Ninja generator (declared as dependency)"
    let generator = "Ninja"

    # Check source directory contents for debugging
    print "🔍 Debugging: Source directory contents..."
    try {
        let src_files = (ls $"($env.SRC_DIR)/src" | get name | str join ", ")
        print $"📋 Source files: ($src_files)"
    } catch {
        print "⚠️  Could not list source directory"
    }

    # Try to download model data (optional - will create placeholders if fails)
    print "📥 Attempting to download RNNoise model data..."
    let model_version_file = ($env.SRC_DIR | path join "model_version")
    if ($model_version_file | path exists) {
        let version = (open $model_version_file | str trim)
        let model_file = $"rnnoise_data-($version).tar.gz"
        let model_url = $"https://media.xiph.org/rnnoise/models/($model_file)"

        print $"📋 Model version: ($version)"
        print $"📥 Downloading from: ($model_url)"

        # Download model data using Nushell's native http get command
        try {
            print "🔧 Using Nushell http get for download..."
            http get $model_url | save --force $model_file
            print "✅ Model data downloaded successfully"

            # Extract the model data (tar should be available in conda environments)
            # The model data needs to be extracted to the src directory
            let extract_result = (^tar -xf $model_file -C src | complete)
            if $extract_result.exit_code == 0 {
                print "✅ Model data extracted successfully"
                # Verify that rnnoise_data.c was created
                let rnnoise_data_file = "src/rnnoise_data.c"
                if ($rnnoise_data_file | path exists) {
                    print "✅ rnnoise_data.c found after extraction"
                } else {
                    print "⚠️  Warning: rnnoise_data.c not found after extraction"
                    print "📋 Files extracted to src/:"
                    if ("src" | path exists) {
                        ls src | where name =~ "rnnoise" | each { |file| print $"    ($file.name)" }
                    }
                }
            } else {
                print "⚠️  Model extraction failed, will use placeholder files"
                print $"📋 Extract stderr: ($extract_result.stderr)"
            }
        } catch { |err|
            print "⚠️  Model download failed, will use placeholder files"
            print $"📋 Download error: ($err.msg)"
            print "ℹ️  CMake will create placeholder files automatically"
        }
    } else {
        print "⚠️  No model_version file found, will use placeholder files"
    }

    # Copy CMakeLists.txt from recipe directory
    print "📝 Using CMakeLists.txt from recipe..."
    let recipe_cmake = ($env.RECIPE_DIR | path join "CMakeLists.txt")
    if ($recipe_cmake | path exists) {
        cp $recipe_cmake $env.SRC_DIR
        print "✅ CMakeLists.txt copied successfully"
    } else {
        print "❌ Error: CMakeLists.txt not found in recipe directory"
        exit 1
    }

    # Create build directory
    print "📁 Creating build directory..."
    mkdir build
    cd build

    # Show CMake version for debugging
    let cmake_version = (^cmake --version | complete)
    if $cmake_version.exit_code == 0 {
        print $"📋 CMake version: ($cmake_version.stdout | lines | first)"
    } else {
        print "❌ Error: CMake not found or not working"
        exit 1
    }

    # Configure with CMake
    print "🔧 Configuring with CMake..."

    # Debug: Show environment variables
    print $"📋 CMAKE_PREFIX_PATH: ($env.CMAKE_PREFIX_PATH? | default 'not set')"
    print $"📋 LIBRARY_PREFIX: ($env.LIBRARY_PREFIX? | default 'not set')"
    print $"📋 Current working directory: (pwd)"

    let cmake_args = [
        $"-DCMAKE_BUILD_TYPE=($build_type)"
        $"-DCMAKE_INSTALL_PREFIX=($env.LIBRARY_PREFIX)"
        $"-DCMAKE_PREFIX_PATH=($env.LIBRARY_PREFIX)"
        $"-DCMAKE_FIND_ROOT_PATH=($env.LIBRARY_PREFIX)"
        "-DBUILD_SHARED_LIBS=ON"
        "-DBUILD_STATIC_LIBS=OFF"
        "."
    ]

    print $"🎯 Using generator: ($generator)"
    print $"📋 Full CMake command: cmake -G\"($generator)\" ($cmake_args | str join ' ')"
    let cmake_result = ^cmake $"-G($generator)" ...$cmake_args $env.SRC_DIR | complete

    if $cmake_result.exit_code != 0 {
        print "❌ Error: CMake configuration failed"
        print $"📋 stdout: ($cmake_result.stdout)"
        print $"📋 stderr: ($cmake_result.stderr)"

        # Try to provide helpful debugging info
        print "🔍 Debugging information:"
        print $"📋 Available CMake generators:"
        let generators_result = (^cmake --help | complete)
        if $generators_result.exit_code == 0 {
            let lines = ($generators_result.stdout | lines)
            let generator_section = ($lines | where ($it | str contains "The following generators are available"))
            if ($generator_section | length) > 0 {
                let start_idx = ($lines | enumerate | where item.1 =~ "The following generators are available" | get index.0 | first)
                let relevant_lines = ($lines | skip ($start_idx) | take 20)
                $relevant_lines | each { |line| print $"    ($line)" }
            }
        }

        exit 1
    }
    print "✅ CMake configuration successful"

    # Build
    print "🏗️  Building with CMake..."
    let build_result = (^cmake --build . --config $build_type | complete)

    if $build_result.exit_code != 0 {
        print "❌ Error: CMake build failed"
        print $"📋 stdout: ($build_result.stdout)"
        print $"📋 stderr: ($build_result.stderr)"
        exit 1
    }
    print "✅ CMake build successful"

    # Install
    print "📦 Installing with CMake..."
    let install_result = (^cmake --install . --config $build_type | complete)

    if $install_result.exit_code != 0 {
        print "❌ Error: CMake install failed"
        print $"📋 stdout: ($install_result.stdout)"
        print $"📋 stderr: ($install_result.stderr)"
        exit 1
    }
    print "✅ CMake install successful"

    # Verify installation for Windows
    print "🔍 Verifying Windows installation..."
    let lib_file = ($env.LIBRARY_LIB | path join "rnnoise.lib")
    let header_file = ($env.LIBRARY_INC | path join "rnnoise.h")

    if ($lib_file | path exists) {
        print "✅ RNNoise library installed successfully"
    } else {
        print "❌ Error: RNNoise library not found after installation"
        print $"📋 Expected: ($lib_file)"
        if ($env.LIBRARY_LIB | path exists) {
            print $"📋 Library directory contents: (ls ($env.LIBRARY_LIB) | get name)"
        }
        exit 1
    }

    if ($header_file | path exists) {
        print "✅ RNNoise header installed successfully"
    } else {
        print "❌ Error: RNNoise header not found after installation"
        print $"📋 Expected: ($header_file)"
        if ($env.LIBRARY_INC | path exists) {
            print $"📋 Include directory contents: (ls ($env.LIBRARY_INC) | get name)"
        }
        exit 1
    }

} else {
    # Unix build using autotools approach
    print "🐧 Building on Unix using autotools approach..."

    # Download the model data first
    print "📥 Downloading RNNoise model data..."
    let model_version_file = ($env.SRC_DIR | path join "model_version")
    if ($model_version_file | path exists) {
        let version = (open $model_version_file | str trim)
        let model_file = $"rnnoise_data-($version).tar.gz"
        let model_url = $"https://media.xiph.org/rnnoise/models/($model_file)"

        print $"📋 Model version: ($version)"
        print $"📥 Downloading from: ($model_url)"

        # Download model data using Nushell's native http get command
        try {
            print "🔧 Using Nushell http get for download..."
            http get $model_url | save --force $model_file
            print "✅ Model data downloaded successfully"

            # Extract the model data (tar should be available in conda environments)
            # The model data needs to be extracted to the src directory
            let extract_result = (^tar -xf $model_file -C src | complete)
            if $extract_result.exit_code == 0 {
                print "✅ Model data extracted successfully"
                # Verify that rnnoise_data.c was created
                let rnnoise_data_file = "src/rnnoise_data.c"
                if ($rnnoise_data_file | path exists) {
                    print "✅ rnnoise_data.c found after extraction"
                } else {
                    print "⚠️  Warning: rnnoise_data.c not found after extraction"
                    print "📋 Files extracted to src/:"
                    if ("src" | path exists) {
                        ls src | where name =~ "rnnoise" | each { |file| print $"    ($file.name)" }
                    }
                }
            } else {
                print "⚠️  Model extraction failed, continuing anyway..."
                print $"📋 Extract stderr: ($extract_result.stderr)"
            }
        } catch { |err|
            print "⚠️  Model download failed, continuing anyway..."
            print $"📋 Download error: ($err.msg)"
        }
    } else {
        print "⚠️  No model_version file found, skipping model download"
    }

    # Generate configure script if it doesn't exist
    if not ("configure" | path exists) {
        print "🔧 Generating configure script with autoreconf..."
        let autoreconf_result = (^autoreconf -fiv | complete)
        if $autoreconf_result.exit_code != 0 {
            print "❌ Error: autoreconf failed"
            print $"📋 stderr: ($autoreconf_result.stderr)"
            exit 1
        }
        print "✅ Configure script generated successfully"
    }

    # Configure with autotools
    print "🔧 Configuring with autotools..."
    let configure_result = (^"./configure"
        $"--prefix=($env.PREFIX)"
        $"--libdir=($env.PREFIX)/lib"
        $"--includedir=($env.PREFIX)/include"
        "--enable-shared"
        "--disable-static"
        "--disable-examples"
        "--disable-doc"
        | complete)

    if $configure_result.exit_code != 0 {
        print "❌ Error: Configure failed"
        print $"📋 stdout: ($configure_result.stdout)"
        print $"📋 stderr: ($configure_result.stderr)"
        exit 1
    }
    print "✅ Configure successful"

    # Build with make
    print "🏗️  Building with make..."
    let cpu_count = ($env.CPU_COUNT? | default "1")
    let make_result = (^make $"-j($cpu_count)" | complete)

    if $make_result.exit_code != 0 {
        print "❌ Error: Make build failed"
        print $"📋 stdout: ($make_result.stdout)"
        print $"📋 stderr: ($make_result.stderr)"
        exit 1
    }
    print "✅ Make build successful"

    # Install with make
    print "📦 Installing with make..."
    let install_result = (^make install | complete)

    if $install_result.exit_code != 0 {
        print "❌ Error: Make install failed"
        print $"📋 stdout: ($install_result.stdout)"
        print $"📋 stderr: ($install_result.stderr)"
        exit 1
    }
    print "✅ Make install successful"

    # Remove static libraries if they were built
    let static_libs = (glob $"($env.PREFIX)/lib/*.a")
    if ($static_libs | length) > 0 {
        print "🧹 Removing static libraries..."
        $static_libs | each { |lib| rm $lib }
    }

    # Verify pkg-config file installation
    let pkgconfig_file = ($env.PREFIX | path join "lib" "pkgconfig" "rnnoise.pc")
    if ($pkgconfig_file | path exists) {
        print "✅ pkg-config file installed successfully"
    } else {
        print "⚠️  Warning: pkg-config file not found"
    }

    # Verify installation for Unix
    print "🔍 Verifying Unix installation..."
    let shlib_ext = ($env.SHLIB_EXT? | default ".so")
    let lib_file = ($env.PREFIX | path join "lib" $"librnnoise($shlib_ext)")
    let header_file = ($env.PREFIX | path join "include" "rnnoise.h")

    if ($lib_file | path exists) {
        print "✅ RNNoise shared library installed successfully"
    } else {
        print "❌ Error: RNNoise shared library not found after installation"
        print $"📋 Expected: ($lib_file)"
        let lib_dir = ($env.PREFIX | path join "lib")
        if ($lib_dir | path exists) {
            print $"📋 Library directory contents: (ls ($lib_dir) | where name =~ rnnoise | get name)"
        }
        exit 1
    }

    if ($header_file | path exists) {
        print "✅ RNNoise header installed successfully"
    } else {
        print "❌ Error: RNNoise header not found after installation"
        print $"📋 Expected: ($header_file)"
        let inc_dir = ($env.PREFIX | path join "include")
        if ($inc_dir | path exists) {
            print $"📋 Include directory contents: (ls ($inc_dir) | where name =~ rnnoise | get name)"
        }
        exit 1
    }
}

print "🎉 RNNoise build completed successfully!"
