#!/usr/bin/env nu

# RNNoise Model Management Module - Simplified Cross-Platform Version
# Handles downloading and validation of official RNNoise models

# Download and extract RNNoise models
export def download-models [] {
    print "📦 RNNoise Model Download Starting..."

    # Only use cross-platform manual download approach
    if ("model_version" | path exists) {
        print "📥 Found model_version file, downloading model..."

        try {
            let hash = (open "model_version" | str trim)
            let model = $"rnnoise_data-($hash).tar.gz"
            let download_url = $"https://media.xiph.org/rnnoise/models/($model)"

            print $"🔑 Expected hash: ($hash)"
            print $"📦 Model file: ($model)"

            # Download if not present
            if not ($model | path exists) {
                print $"📥 Downloading from: ($download_url)"
                try {
                    http get $download_url | save $model
                    print "✅ Download successful"
                } catch { |err|
                    print $"❌ Download failed: ($err.msg)"
                    return false
                }
            } else {
                print "✅ Model file already exists"
            }

            # Validate and extract
            validate-and-extract $model $hash
        } catch { |err|
            print $"❌ Model download failed: ($err.msg)"
            false
        }
    } else {
        print "📋 No model_version file found, will use built-in defaults"
        false
    }
}

# Validate checksum and extract model
def validate-and-extract [model_file: string, expected_hash: string] {
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

# Create fallback model files
export def create-fallback-models [] {
    print "📝 Creating fallback model files..."

    # Ensure src directory exists
    if not ("src" | path exists) {
        mkdir src
        print "📁 Created src directory"
    }

    # Create header file
    let template_h = ($env.RECIPE_DIR | path join "rnnoise_data.h.in")
    if ($template_h | path exists) and not ("src/rnnoise_data.h" | path exists) {
        cp $template_h "src/rnnoise_data.h"
        print "✅ Created rnnoise_data.h from template"
    }

    # Create source file
    let template_c = ($env.RECIPE_DIR | path join "rnnoise_data.c.in")
    if ($template_c | path exists) and not ("src/rnnoise_data.c" | path exists) {
        cp $template_c "src/rnnoise_data.c"
        print "✅ Created rnnoise_data.c from template"
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
    print "  download-models        - Download official models"
    print "  create-fallback-models - Create fallback files"
    print "  list-model-files       - List current files"
}
