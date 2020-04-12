import re
import sys
from pathlib import Path

from jupyter_lsp import tests


if __name__ == "__main__":
    # Reduce the number of known language servers
    conftest = Path(tests.__file__).parent / "conftest.py"
    conf = conftest.read_text()

    servers = ",".join(map(lambda s: '"{:s}"'.format(s), sys.argv[1:]))
    new_conf = re.sub(
        r"KNOWN_SERVERS = \[(.*?)\]", 
        "KNOWN_SERVERS =[{}]".format(servers), 
        conf, 
        flags=re.M|re.S
    )
    conftest.write_text(new_conf)
