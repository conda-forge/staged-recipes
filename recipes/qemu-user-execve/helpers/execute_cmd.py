import argparse
import os
import subprocess
import sys
import traceback


def run_command(command):
    """Run a command and print its output and errors."""
    try:
        # Print the exact command being run
        print("\nRelevant environment variables:")
        for var in ['PATH', 'PREFIX', 'CONDA_PREFIX', 'PYTHONPATH', 'LD_LIBRARY_PATH', 'QEMU_LD_PREFIX']:
            print("%s: %s" % (var, os.environ.get(var, '<not set>')))

        print("Executing command: %s" % command)

        process = subprocess.Popen(
            command,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            universal_newlines=True,
            shell=True
        )

        # Get output and errors
        stdout, stderr = process.communicate()

        # Print detailed information
        print("\nProcess Information:")
        print("PID: %d" % process.pid)
        print("Return Code: %d" % process.returncode)

        print("\nSTDOUT:")
        print(stdout if stdout else "<no output>")

        print("\nSTDERR:")
        print(stderr if stderr else "<no errors>")

        # Check for errors
        if process.returncode != 0:
            print("\nCommand failed with return code: %d" % process.returncode)
            print("Full command that failed: %s" % ' '.join(command if isinstance(command, list) else [command]))
            return process.returncode

        return 0

    except Exception as e:
        print("\nException occurred while running command:")
        print("Error type: %s" % type(e).__name__)
        print("Error message: %s" % str(e))
        print("\nTraceback:")
        traceback.print_exc()
        return 1

def main():
    # Set up argument parsing
    parser = argparse.ArgumentParser(description="Execute QEMU command.")
    parser.add_argument("qemu", help="QEMU exec.")
    parser.add_argument("--ld_version", default=2.17, help="Version of ld.so.")
    parser.add_argument("args", nargs=argparse.REMAINDER, help="Arguments for the command.")
    args = parser.parse_args()

    qemu_exec = os.path.join(os.environ["PREFIX"], "bin", args.qemu)
    ld_so = os.path.join(os.environ["QEMU_LD_PREFIX"], "lib", "ld-{0}.so".format(args.ld_version))

    # Run the default command 'ld.so --help' if no arguments are provided
    if not args.args:
        args.args = [ld_so]

    command = [qemu_exec] + args.args
    # Set environment variable for more verbose Python errors
    os.environ['PYTHONVERBOSE'] = '1'

    # Run your command with debug info
    result = run_command(command)
    if result != 0:
        print("\nFailed with debugging info above")
        sys.exit(result)

if __name__ == "__main__":
    main()
