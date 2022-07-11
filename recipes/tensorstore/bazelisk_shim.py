import os
import sys
import subprocess

BAZEL_EXE = os.environ.get("BAZEL_EXE", "bazel")

def execute_bazel(bazel_path, argv):
  # We cannot use close_fds on Windows, so disable it there.
  p = subprocess.Popen([bazel_path] + argv, close_fds=os.name != "nt")
  while True:
    try:
      return p.wait()
    except KeyboardInterrupt:
      # Bazel will also get the signal and terminate.
      # We should continue waiting until it does so.
      pass


def main(argv=None):
  if argv is None:
    argv = sys.argv

  print(argv)
  return execute_bazel(BAZEL_EXE, argv[1:])


if __name__ == "__main__":
  sys.exit(main())