"""Keep the native Python extension; do not ship its auxiliary C++ static library."""
from pathlib import Path
import shutil
import sys
import sysconfig

prefix=Path(sys.prefix).resolve()
platlib=Path(sysconfig.get_path('platlib')).resolve()
assert platlib.is_relative_to(prefix)
removed=[]
for folder in [platlib/'lib',prefix/'lib',prefix/'Library/lib']:
    for path in folder.glob('*DanceRudiments*'):
        if path.suffix.lower() in ['.a','.lib']:
            assert path.resolve().is_relative_to(prefix) and not path.is_symlink()
            path.unlink();removed.append(path.name)
    config=folder/'cmake/DanceRudiments'
    if config.exists():
        assert config.resolve().is_relative_to(prefix) and not config.is_symlink()
        shutil.rmtree(config)
import dancerudiments as d
assert len(d.catalogue())==1731
assert d.sample('circle',0).as_tuple()==d.sample('circle',64).as_tuple()
print('Native Python import verified; auxiliary C++ library removed:',removed)
