import json
import os
import sys

def modify_config(config_file, prefix, pg_version):
    try:
        with open(config_file, "r") as f:
            content = f.read()

        tablespace_path = os.path.abspath(f".postgresql/{pg_version}-main/tablespaces")

        # Replace placeholders
        content = content.replace("__PREFIX__", prefix)
        content = content.replace("__PGVER__", pg_version)
        content = content.replace("__TABLESPACE_PATH__", tablespace_path)

        with open(config_file, "w") as f:
            f.write(content)

    except IOError as e:
        print(f"Error modifying config file: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    if len(sys.argv) > 1:
        config_file = sys.argv[1]
    else:
        raise ValueError("Config file relative path required")
    prefix = os.environ.get("PREFIX")
    pg_version = os.environ.get("POSTGRESQL_VERSION")

    if not all([config_file, prefix, pg_version]):
        print("Error: SRC_DIR, PREFIX, and POSTGRESQL_VERSION environment variables must be set.", file=sys.stderr)
        sys.exit(1)

    modify_config(config_file, prefix, pg_version)

