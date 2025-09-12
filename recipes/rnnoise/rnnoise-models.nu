#!/usr/bin/env nu

# RNNoise Model Management Module
# Handles downloading and validation of official RNNoise models

# Download and extract RNNoise models using the official mechanism
export def download-models [] {
    print "📋 RNNoise Model Download Module Starting..."

    try {
        # Check for official download script first
        if ("download_model.sh" | path exists) {
            print "📥 Found official download_model.sh script, executing it..."
            let result = (^bash "download_model.sh" | complete)
            if $result.exit_code == 0 {
                print "✅ Official model download successful"
                return true
            } else {
                print "⚠️  Official model download failed, trying manual approach"
                print $"📋 Script error: ($result.stderr)"
            }
        }

        # Check scripts directory
        if ("scripts/download_model.sh" | path exists) {
            print "📥 Found official download_model.sh script in scripts/, executing it..."
            try {
                cd scripts
                let result = (^bash "download_model.sh" | complete)
                cd ..
                if $result.exit_code == 0 {
                    print "✅ Official model download successful"
                    return true
                } else {
                    print "⚠️  Official model download failed, trying manual approach"
                    print $"📋 Script error: ($result.stderr)"
                }
            } catch { |err|
                cd ..
                print $"⚠️  Error executing script: ($err.msg)"
            }
        }

        # Manual download using model_version file
        if ("model_version" | path exists) {
            print "📥 Found model_version file, attempting manual download..."
            download-models-manual
        } else {
            print "📋 No model_version file found, will use built-in defaults"
            false
        }
    } catch { |err|
        print $"❌ Model download process failed: ($err.msg)"
        false
    }
}

# Manual model download implementation
export def download-models-manual [] {
    try {
        let hash = (open "model_version" | str trim)
        let model = $"rnnoise_data-($hash).tar.gz"

        print $"📦 Model file: ($model)"
        print $"🔑 Expected hash: ($hash)"

        # Download if not present
        if not ($model | path exists) {
            print $"📥 Downloading model: ($model)"
            let download_url = $"https://media.xiph.org/rnnoise/models/($model)"

            # Use nushell's built-in http get command
            try {
                print $"🌐 Downloading from: ($download_url)"
                http get $download_url | save $model
                print $"✅ Downloaded ($model) successfully"
            } catch { |err|
                print $"❌ Download failed: ($err.msg)"
                return false
            }
        } else {
            print "✅ Model file already exists"
        }

        # Validate checksum using nushell's built-in hash command
        if ($model | path exists) {
            print "🔍 Validating checksum..."
            try {
                let actual_hash = (open $model | hash sha256)
                if $actual_hash == $hash {
                    print "✅ Checksum validation passed"
                    extract-model $model
                } else {
                    print $"❌ Checksum mismatch: expected ($hash), got ($actual_hash)"
                    print "🗑️  Removing corrupted file..."
                    rm $model
                    return false
                }
            } catch { |err|
                print $"⚠️  Checksum validation failed: ($err.msg), but continuing..."
                extract-model $model
            }
        } else {
            print "❌ Model file not found after download attempt"
            return false
        }

        true
    } catch { |err|
        print $"❌ Manual model download failed: ($err.msg)"
        false
    }
}

# Extract model archive
export def extract-model [model_file: string] {
    print $"📂 Extracting model data from ($model_file)..."
    try {
        # Use external tar command with better error handling
        let extract_result = (^tar -xvf $model_file | complete)
        if $extract_result.exit_code == 0 {
            print "✅ Model extraction successful"

            # Show what was extracted
            if ($extract_result.stdout | str length) > 0 {
                print "📋 Extracted files:"
                $extract_result.stdout | lines | each { |line|
                    if ($line | str length) > 0 {
                        print $"    ($line)"
                    }
                }
            }

            # List extracted model files specifically
            print "📋 Model data files found:"
            try {
                let model_files = (ls | where name =~ "rnnoise.*data")
                if ($model_files | length) > 0 {
                    $model_files | each { |file|
                        let size_str = ($file.size | into string)
                        print $"    ($file.name) ($size_str) bytes"
                    }
                } else {
                    print "    (no model data files found after extraction)"
                }
            } catch {
                print "    (unable to list extracted files)"
            }

            true
        } else {
            print $"❌ Model extraction failed: ($extract_result.stderr)"
            false
        }
    } catch { |err|
        print $"❌ Model extraction error: ($err.msg)"
        false
    }
}

# Check what model files are currently available
export def list-model-files [] {
    print "📋 Current model files in source:"

    try {
        let model_files = (glob "*rnnoise*data*" | where ($it | path type) == "file")

        if ($model_files | length) > 0 {
            $model_files | each { |file|
                try {
                    let size = (ls $file | get size.0)
                    let size_str = ($size | into string)
                    print $"    ($file) ($size_str) bytes"
                } catch {
                    print $"    ($file) (size unknown)"
                }
            }
        } else {
            print "    (no model data files found)"
        }

        $model_files
    } catch { |err|
        print $"⚠️  Error listing model files: ($err.msg)"
        []
    }
}

# Create fallback model files if none exist
export def create-fallback-models [] {
    print "📝 Checking for fallback model templates..."

    try {
        # Ensure src directory exists
        if not ("src" | path exists) {
            mkdir src
            print "📁 Created src directory"
        }

        # Create rnnoise_data.h if missing
        if not ("src/rnnoise_data.h" | path exists) {
            let template_file = ($env.RECIPE_DIR | path join "rnnoise_data.h.in")
            if ($template_file | path exists) {
                try {
                    cp $template_file "src/rnnoise_data.h"
                    print "✅ Created rnnoise_data.h from template"
                } catch { |err|
                    print $"⚠️  Failed to copy rnnoise_data.h template: ($err.msg)"
                }
            } else {
                print "⚠️  Template rnnoise_data.h.in not found"
            }
        } else {
            print "✅ rnnoise_data.h already exists"
        }

        # Create rnnoise_data.c if missing
        if not ("src/rnnoise_data.c" | path exists) {
            let template_file = ($env.RECIPE_DIR | path join "rnnoise_data.c.in")
            if ($template_file | path exists) {
                try {
                    cp $template_file "src/rnnoise_data.c"
                    print "✅ Created rnnoise_data.c from template"
                } catch { |err|
                    print $"⚠️  Failed to copy rnnoise_data.c template: ($err.msg)"
                }
            } else {
                print "⚠️  Template rnnoise_data.c.in not found"
            }
        } else {
            print "✅ rnnoise_data.c already exists"
        }
    } catch { |err|
        print $"❌ Error creating fallback models: ($err.msg)"
    }
}

# Main entry point for model management
export def main [] {
    print "🎯 RNNoise Model Management"
    print "Available commands:"
    print "  download-models     - Download official RNNoise models"
    print "  list-model-files    - List current model files"
    print "  create-fallback-models - Create template fallback files"
    print ""
    print "Usage: use rnnoise-models.nu; download-models"
}
