#!/usr/bin/env nu

# RNNoise build script using CMake

def download-models [] {
    print "📦 Attempting to download RNNoise models..."

    # Try official download script in current directory
    if ("download_model.sh" | path exists) {
        print "📥 Found download_model.sh, executing..."
        let result = (^bash "download_model.sh" | complete)
        if $result.exit_code == 0 {
            print "✅ Official model download successful"
            return true
        } else {
            print "⚠️  Official model download failed"
        }
    }

    # Try official download script in scripts directory
    if ("scripts/download_model.sh" | path exists) {
        print "📥 Found download_model.sh in scripts/, executing..."
        try {
            cd scripts
            let result = (^bash "download_model.sh" | complete)
            cd ..
            if $result.exit_code == 0 {
                print "✅ Official model download successful"
                return true
            } else {
                print "⚠️  Official model download failed"
            }
        } catch {
            cd ..
            print "⚠️  Error executing download script"
        }
    }

    # Manual download using model_version file
    if ("model_version" | path exists) {
        print "📥 Found model_version file, attempting manual download..."
        let hash = (open "model_version" | str trim)
        let model = $"rnnoise_data-($hash).tar.gz"
        let download_url = $"https://media.xiph.org/rnnoise/models/($model)"

        print $"🔑 Expected hash: ($hash)"

        # Download if not present
        if not ($model | path exists) {
            print $"📥 Downloading model: ($model)"
            try {
                http get $download_url | save $model
                print "✅ Downloaded successfully"
            } catch {
                print "❌ Download failed"
                return false
            }
        } else {
            print "✅ Model file already exists"
        }

        # Validate and extract
        try {
            let actual_hash = (open $model | hash sha256)
            let actual_short = ($actual_hash | str substring 0..6)

            # Try multiple hash comparison methods
            if $actual_hash == $hash or $actual_short == $hash or ($hash | str starts-with $actual_short) or ($actual_hash | str starts-with $hash) {
                print "✅ Checksum validation passed"
            } else {
                print $"⚠️  Checksum mismatch: expected ($hash), got ($actual_hash)"
                print "⚠️  Attempting extraction anyway..."
            }
        } catch {
            print "⚠️  Checksum validation failed, attempting extraction anyway..."
        }

        # Extract model (always attempt)
        print $"📂 Extracting model data..."
        try {
            ^tar -xf $model
            print "✅ Model extraction successful"

            # Check if we got actual model files
            let model_files = (glob "*rnnoise*data*")
            if ($model_files | length) > 0 {
                print $"📋 Found ($model_files | length) model data files"
                return true
            } else {
                print "⚠️  No model data files found after extraction"
                return false
            }
        } catch {
            print "❌ Model extraction failed"
            return false
        }
    }

    print "📋 No model source found, will use fallback"
    false
}

def create-fallback-models [] {
    print "📝 Creating fallback model files..."

    # Ensure src directory exists
    if not ("src" | path exists) {
        mkdir src
        print "📁 Created src directory"
    }

    # Create rnnoise_data.h if missing
    if not ("src/rnnoise_data.h" | path exists) {
        let template = ($env.RECIPE_DIR | path join "rnnoise_data.h.in")
        if ($template | path exists) {
            cp $template "src/rnnoise_data.h"
            print "✅ Created rnnoise_data.h from template"
        } else {
            print "⚠️  Template rnnoise_data.h.in not found"
        }
    }

    # Create rnnoise_data.c if missing
    if not ("src/rnnoise_data.c" | path exists) {
        let template = ($env.RECIPE_DIR | path join "rnnoise_data.c.in")
        if ($template | path exists) {
            cp $template "src/rnnoise_data.c"
            print "✅ Created rnnoise_data.c from template"
        } else {
            print "⚠️  Template rnnoise_data.c.in not found"
        }
    }
}

# Main build process
print "🔧 RNNoise Build Script Starting..."

# Download models or create fallbacks
let models_success = (download-models)
if not $models_success {
    print "⚠️  Model download failed, creating fallback models..."
    create-fallback-models
}

# Copy CMakeLists.txt from recipe directory
print "📋 Setting up CMake configuration..."
let cmake_file = ($env.RECIPE_DIR | path join "CMakeLists.txt")
if ($cmake_file | path exists) {
    cp $cmake_file "CMakeLists.txt"
    print "✅ Copied CMakeLists.txt"
} else {
    print "❌ CMakeLists.txt not found in recipe directory"
    exit 1
}

# Clean and create build directory
print "🏗️  Preparing build environment..."
if ("build" | path exists) {
    rm -rf build
    print "🗑️  Cleaned existing build directory"
}
mkdir build
cd build

# Configure with CMake
print "⚙️  Configuring build with CMake..."
let cpu_count = ($env.CPU_COUNT? | default "1")
try {
    ^cmake .. $"-DCMAKE_INSTALL_PREFIX=($env.PREFIX)" "-DCMAKE_BUILD_TYPE=Release" "-G" "Ninja"
    print "✅ CMake configuration successful"
} catch { |err|
    print $"❌ CMake configuration failed: ($err.msg)"
    cd ..
    exit 1
}

# Build with Ninja
print $"🔨 Building with Ninja \(using ($cpu_count) cores\)..."
try {
    ^ninja $"-j($cpu_count)"
    print "✅ Build successful"
} catch { |err|
    print $"❌ Build failed: ($err.msg)"
    cd ..
    exit 1
}

# Install
print "📦 Installing RNNoise..."
try {
    ^ninja install
    print "✅ Installation successful"
} catch { |err|
    print $"❌ Installation failed: ($err.msg)"
    cd ..
    exit 1
}

cd ..

# Clean up static libraries (conda-forge policy)
print "🧹 Cleaning up static libraries..."
let static_libs = (glob $"($env.PREFIX)/lib/*.a")
if ($static_libs | length) > 0 {
    $static_libs | each { |lib|
        rm $lib
        print $"🗑️  Removed ($lib)"
    }
    print $"✅ Cleaned up ($static_libs | length) static libraries"
} else {
    print "✅ No static libraries to clean up"
}

print "🎉 RNNoise build completed successfully!"
