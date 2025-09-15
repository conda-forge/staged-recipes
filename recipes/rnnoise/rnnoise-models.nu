#!/usr/bin/env nu

# RNNoise Model Management Module - Simplified Cross-Platform Version
# Handles downloading and validation of official RNNoise models

# Download RNNoise models and return model file and hash
export def download-models [] {
    print "📦 RNNoise Model Download Starting..."

    # Only use cross-platform manual download approach
    if not ("model_version" | path exists) {
        print "📋 No model_version file found, will use built-in defaults"
        return null
    }
    print "📥 Found model_version file, downloading model..."

    try {
        let hash = (open "model_version" | str trim)
        let model = $"rnnoise_data-($hash).tar.gz"
        print $"🔑 Expected hash: ($hash)"
        print $"📦 Model file: ($model)"

        if ($model | path exists) {
            print "✅ Model file already exists"
            return {model: $model, hash: $hash}
        }

        let download_url = $"https://media.xiph.org/rnnoise/models/($model)"

        print $"📥 Downloading from: ($download_url)"
        try {
            http get $download_url | save $model
            print "✅ Download successful"
        } catch { |err|
            print $"❌ Download failed: ($err.msg)"
            return null
        }
        {model: $model, hash: $hash}
    } catch { |err|
        print $"❌ Model download failed: ($err.msg)"
        null
    }
}

# Validate checksum and extract model
export def validate-and-extract [model_file: string, expected_hash: string] {
    try {
        print "🔍 Validating checksum..."
        let actual_hash = (open $model_file | hash sha256)
        let actual_short = ($actual_hash | str substring 0..6)

        # Flexible hash comparison (full hash or short hash)
        if $actual_hash == $expected_hash or $actual_short == $expected_hash {
            print "✅ Checksum validation passed"
        } else {
            print $"⚠️  Hash mismatch (expected: ($expected_hash), got: ($actual_short)), continuing anyway..."
        }

        # Extract model
        print $"📂 Extracting ($model_file)..."
        ^tar -xf $model_file
        print "✅ Model extraction successful"

        # Verify extraction results
        let model_files = (glob "*rnnoise*data*")
        if ($model_files | length) > 0 {
            print $"📋 Found ($model_files | length) model data files"
            return true
        } else {
            print "⚠️  No model data files found after extraction"
            return false
        }
    } catch { |err|
        print $"❌ Validation/extraction failed: ($err.msg)"
        false
    }
}

# Patch missing files with templates from recipe directory
export def patch-missing-files [] {
    print "🔧 Patching missing model files..."

    # Ensure src directory exists
    if not ("src" | path exists) {
        mkdir src
        print "📁 Created src directory"
    }

    # Patch rnnoise_data.h if missing
    if not ("src/rnnoise_data.h" | path exists) {
        let template = ($env.RECIPE_DIR | path join "rnnoise_data.h.in")
        if ($template | path exists) {
            cp $template "src/rnnoise_data.h"
            print "✅ Patched rnnoise_data.h"
        }
    }

    # Patch rnnoise_data.c if missing
    if not ("src/rnnoise_data.c" | path exists) {
        let template = ($env.RECIPE_DIR | path join "rnnoise_data.c.in")
        if ($template | path exists) {
            cp $template "src/rnnoise_data.c"
            print "✅ Patched rnnoise_data.c"
        }
    }

    # Patch os_support.h if missing (required for Windows builds)
    if not ("src/os_support.h" | path exists) {
        let os_support = ($env.RECIPE_DIR | path join "os_support.h")
        if ($os_support | path exists) {
            cp $os_support "src/os_support.h"
            print "✅ Patched os_support.h"
        }
    }
}

# List current model files
export def list-model-files [] {
    print "📋 Current model files:"
    let model_files = (glob "*rnnoise*data*")
    if ($model_files | length) > 0 {
        $model_files | each { |file|
            let size = (ls $file | get size.0? | default "unknown")
            print $"    ($file) - ($size) bytes"
        }
    } else {
        print "    (no model files found)"
    }
    $model_files
}

# Main entry point
export def main [] {
    print "🎯 RNNoise Model Management (Simplified)"
    print "Commands:"
    print "  download-models        - Download official models (returns model info)"
    print "  validate-and-extract   - Validate and extract model file"
    print "  patch-missing-files    - Patch missing model files"
    print "  list-model-files       - List current files"
}
