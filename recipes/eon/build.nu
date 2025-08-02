let host_prefix_expanded = ($env.PREFIX | path expand)
# Create the "native.ini" file to explicitly tell Meson which Python to use.
# This hard-codes the path to the correct Python from the conda host environment.
let python_path = ($env.PREFIX | path join 'bin/python')
let content = $"[binaries]\npython = '($python_path)'\n"
$content | save native.ini

# --- Configure ---
let configure_args = [
    $"--prefix=($host_prefix_expanded)",
    "--libdir=lib",
    "--buildtype=release",
    "-Dpython.install_env=prefix",
    # Needed to pin the right Python file
    "--native-file", "native.ini",
    # Handling conditionals
    ...(if ($env.WITH_LAMMPS == "1") {
        ["-Dwith_lammps=True"]
    } else {
        []
    })
    # Always build metatomic support here
    "-Dwith_metatomic=True",
    "-Dpip_metatomic=False"
    $"-Dtorch_path=($host_prefix_expanded)"
]

print $"INFO: Running meson setup with ($configure_args | str join ' ')"
# External commands will get LIBS, CPPFLAGS, CXXFLAGS as space-separated strings
# due to the to_string closure in ENV_CONVERSIONS.
meson setup bbdir ...$configure_args
meson install -C bbdir

# --- Post-Install Linking Fix for macOS ---
# Delete all existing rpaths, and then add back a single correct one.
if ($env.target_platform | str starts-with "osx") {
    print "INFO: Running post-install rpath fix for macOS..."
    let eonclient_path = $"($host_prefix_expanded)/bin/eonclient"

    # Get a list of all current rpaths in the executable
    let current_rpaths = (otool -l $eonclient_path | grep LC_RPATH -A 2 | lines | where $it =~ 'path' | parse --regex `path\s+(?<path>\S+)` | get path)

    # Delete each existing rpath
    for rpath in $current_rpaths {
        print $"INFO: Deleting existing rpath: ($rpath)"
        install_name_tool -delete_rpath $rpath $eonclient_path
    }

    # Add a single, correct rpath
    print "INFO: Adding correct rpath: @loader_path/../lib"
    install_name_tool -add_rpath "@loader_path/../lib" $eonclient_path

    print "INFO: Rpath fix applied. Verifying with otool:"
    otool -l $eonclient_path | grep LC_RPATH -A 2
}
