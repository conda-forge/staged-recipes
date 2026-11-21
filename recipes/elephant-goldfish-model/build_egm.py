"""Build the Claude and OpenAI runtime folders with upstream's packer.

scripts/pack_plugin.py copies only the runtime files (skills, agents,
resources, docs, manifests) and checks every manifest reference, then writes
egm-<target>/ and egm-<target>.zip into the output folder.
"""

import os
import subprocess
import sys
from pathlib import Path

output = Path(os.environ["PREFIX"], "share", "elephant-goldfish-model")
for target in ("claude", "openai"):
    subprocess.run(
        [sys.executable, "scripts/pack_plugin.py", "--target", target, "--output", str(output)],
        check=True,
    )
