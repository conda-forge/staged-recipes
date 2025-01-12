import subprocess

def check_plugin_in_trace_config():
    # Run pytest with --trace-config to get configuration info
    result = subprocess.run(['pytest', '--trace-config'], capture_output=True, text=True)

    # Check if the textual-snapshot plugin is in the output
    if "textual-snapshot" not in result.stdout:
        raise RuntimeError("The 'textual-snapshot' plugin is not loaded. ")

# Run the check
check_plugin_in_trace_config()