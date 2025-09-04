#!/usr/bin/env nu

# Build script for GHC using ghcup
# This script installs GHC via ghcup and redistributes it to the conda prefix

print "Starting GHC build using ghcup..."
print $"Target version: ($env.PKG_VERSION)"
print $"Target prefix: ($env.PREFIX)"

# ghcup is already available from conda package
print "Using ghcup from conda package..."

# Verify ghcup installation
if not (which ghcup | is-not-empty) {
    print "ERROR: ghcup installation failed"
    exit 1
}

print $"ghcup version: (ghcup --version)"

# List available GHC versions (for debugging)
print "Available GHC versions:"
ghcup list -t ghc

# Install the specific GHC version
print $"Installing GHC ($env.PKG_VERSION)..."
ghcup install ghc $env.PKG_VERSION

# Set the installed version as active
ghcup set ghc $env.PKG_VERSION

# Verify GHC installation
try {
    ghcup whereis ghc $env.PKG_VERSION
} catch {
    print $"ERROR: GHC ($env.PKG_VERSION) installation failed"
    exit 1
}

# Get the GHC installation path
let ghc_binary_path = (ghcup whereis ghc $env.PKG_VERSION | str trim)
let ghc_install_dir = ($ghc_binary_path | path dirname | path dirname)

print $"GHC installed at: ($ghc_install_dir)"
print $"GHC binary path: ($ghc_binary_path)"

# Verify the installation directory exists and contains expected files
if not ($ghc_install_dir | path exists) {
    print $"ERROR: GHC installation directory not found: ($ghc_install_dir)"
    exit 1
}

if not ($ghc_binary_path | path exists) {
    print $"ERROR: GHC binary not found: ($ghc_binary_path)"
    exit 1
}

# Copy GHC installation to conda prefix
print "Copying GHC installation to conda prefix..."
# List all items in the GHC install directory and copy them
let items = (ls $ghc_install_dir | get name)
for item in $items {
    cp -r $item $env.PREFIX
}

# Ensure proper permissions
chmod -R u+w $env.PREFIX

# Fix GHC wrapper scripts and configuration files
print "Fixing GHC paths in wrapper scripts..."

# Update ghc wrapper script
let ghc_wrapper = ($env.PREFIX | path join "bin" "ghc")
if ($ghc_wrapper | path exists) {
    let content = (open $ghc_wrapper)
    let updated_content = ($content | str replace -a $ghc_install_dir $env.PREFIX)
    $updated_content | save -f $ghc_wrapper
    chmod +x $ghc_wrapper
}

# Update ghc-pkg wrapper script
let ghc_pkg_wrapper = ($env.PREFIX | path join "bin" "ghc-pkg")
if ($ghc_pkg_wrapper | path exists) {
    let content = (open $ghc_pkg_wrapper)
    let updated_content = ($content | str replace -a $ghc_install_dir $env.PREFIX)
    $updated_content | save -f $ghc_pkg_wrapper
    chmod +x $ghc_pkg_wrapper
}

# Update ghci wrapper script
let ghci_wrapper = ($env.PREFIX | path join "bin" "ghci")
if ($ghci_wrapper | path exists) {
    let content = (open $ghci_wrapper)
    let updated_content = ($content | str replace -a $ghc_install_dir $env.PREFIX)
    $updated_content | save -f $ghci_wrapper
    chmod +x $ghci_wrapper
}

# Update runghc wrapper script
let runghc_wrapper = ($env.PREFIX | path join "bin" "runghc")
if ($runghc_wrapper | path exists) {
    let content = (open $runghc_wrapper)
    let updated_content = ($content | str replace -a $ghc_install_dir $env.PREFIX)
    $updated_content | save -f $runghc_wrapper
    chmod +x $runghc_wrapper
}

# Update GHC settings file if it exists
let settings_file = ($env.PREFIX | path join "lib" $"ghc-($env.PKG_VERSION)" "settings")
if ($settings_file | path exists) {
    print "Updating GHC settings file..."
    let content = (open $settings_file)
    let updated_content = ($content | str replace -a $ghc_install_dir $env.PREFIX)

    # Get compiler paths - use relative names that will be found in PATH
    let cc_path = "gcc"
    let cxx_path = "g++"
    let ld_path = "ld"

    print $"Setting C compiler to: ($cc_path)"
    print $"Setting C++ compiler to: ($cxx_path)"
    print $"Setting linker to: ($ld_path)"

    # Fix all compiler and tool paths in the settings file
    mut final_content = $updated_content

    # Replace build environment paths with simple tool names
    $final_content = ($final_content | str replace -a -r '"/[^"]*build_env/bin/[^"/]*-cc"' $'"($cc_path)"')
    $final_content = ($final_content | str replace -a -r '"/[^"]*build_env/bin/[^"/]*-c\+\+"' $'"($cxx_path)"')
    $final_content = ($final_content | str replace -a -r '"/[^"]*build_env/bin/[^"/]*-ld"' $'"($ld_path)"')
    $final_content = ($final_content | str replace -a -r '"/[^"]*build_env/bin/[^"/]*-ar"' $'"ar"')
    $final_content = ($final_content | str replace -a -r '"/[^"]*build_env/bin/[^"/]*-nm"' $'"nm"')
    $final_content = ($final_content | str replace -a -r '"/[^"]*build_env/bin/[^"/]*-objdump"' $'"objdump"')
    $final_content = ($final_content | str replace -a -r '"/[^"]*build_env/bin/[^"/]*-ranlib"' $'"ranlib"')
    $final_content = ($final_content | str replace -a -r '"/[^"]*build_env/bin/[^"/]*-strip"' $'"strip"')

    # Handle any remaining build environment paths
    $final_content = ($final_content | str replace -a -r '/[^"]*build_env' $env.PREFIX)

    $final_content | save -f $settings_file
    print "Updated GHC settings file with corrected tool paths"
}

# Fix any configuration files that might contain build paths
print "Fixing additional GHC configuration files..."
let ghc_lib_dir = ($env.PREFIX | path join "lib" $"ghc-($env.PKG_VERSION)")
if ($ghc_lib_dir | path exists) {
    # Find and fix any .conf files in package.conf.d
    let pkg_conf_dir = ($ghc_lib_dir | path join "package.conf.d")
    if ($pkg_conf_dir | path exists) {
        let conf_files = (ls $pkg_conf_dir | where name =~ ".conf$" | get name)
        for conf_file in $conf_files {
            try {
                let content = (open $conf_file)
                let fixed_content = ($content | str replace -a -r '/[^"]*build_env' $env.PREFIX)
                $fixed_content | save -f $conf_file
            } catch {
                print $"Warning: Could not update ($conf_file)"
            }
        }
    }

    # Update package cache
    try {
        ^($env.PREFIX | path join "bin" $"ghc-pkg-($env.PKG_VERSION)") recache --package-db=$pkg_conf_dir
        print "Updated GHC package database"
    } catch {
        print "Warning: Could not recache package database"
    }
}

# Create version-agnostic symlinks for main binaries
print "Creating symlinks for GHC binaries..."

let binaries = ["ghc", "ghci", "ghc-pkg", "runghc", "runhaskell"]
for binary in $binaries {
    let versioned_binary = $"($binary)-($env.PKG_VERSION)"
    let binary_path = ($env.PREFIX | path join "bin" $versioned_binary)
    let target_path = ($env.PREFIX | path join "bin" $binary)

    if ($binary_path | path exists) and not ($target_path | path exists) {
        print $"Creating symlink: ($versioned_binary) -> ($binary)"
        # Create symlink in the bin directory using-sf $versioned_binary $binary
    } else if ($target_path | path exists) {
        print $"Binary ($binary) already exists"
    } else {
        print $"WARNING: Expected binary not found: ($versioned_binary)"
    }
}

# Handle license file - GHC installations typically include LICENSE file
print "Handling license file..."
let license_locations = [
    ($env.PREFIX | path join "LICENSE"),
    ($env.PREFIX | path join "share" "doc" "ghc" "LICENSE"),
    ($env.PREFIX | path join "share" "doc" $"ghc-($env.PKG_VERSION)" "LICENSE")
]

let existing_licenses = ($license_locations | where {|path| $path | path exists})

if ($existing_licenses | length) > 0 {
    let existing_license = ($existing_licenses | first)
    print $"License file found at ($existing_license)"
    if $existing_license != ($env.PREFIX | path join "LICENSE") {
        cp $existing_license ($env.PREFIX | path join "LICENSE")
    }
} else {
    print "WARNING: License file not found, copying from recipe directory"
    cp ($env.RECIPE_DIR | path join "LICENSE.txt") ($env.PREFIX | path join "LICENSE")
}

print "GHC build completed successfully!"
