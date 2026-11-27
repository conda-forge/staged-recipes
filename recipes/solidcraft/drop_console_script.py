"""Drop the ``solidcraft`` console script the package installs.

The desktop app package owns ``bin/solidcraft`` (``Scripts\\solidcraft.exe`` on Windows), so a
second script of that name from the Python client would clobber it. The client's daemon entry
point, ``solidcraft-session``, is a declared conda entry point and is left alone; the CLI it
wraps is ``solidcraft-cli``, which the package already depends on.
"""

import os
import sysconfig

scripts = sysconfig.get_path("scripts")
removed = []
for name in os.listdir(scripts):
    if name == "solidcraft" or name.startswith(("solidcraft.", "solidcraft-script")):
        os.remove(os.path.join(scripts, name))
        removed.append(name)
print("removed console scripts:", ", ".join(sorted(removed)) or "(none)")
