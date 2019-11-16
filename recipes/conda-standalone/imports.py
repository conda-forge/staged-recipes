# These help pyinstaller find all the stuff it needs.  Add your packages to generate more specific imports.

import glob
import os
import site
import sys

packages = ['conda', 'conda-package-handling']
if sys.platform == "win32":
    packages.append('menuinst')
files = [f for package in packages
         for f in glob.glob(
                 os.path.join(os.getenv('SP_DIR', site.getsitepackages()[0]), package, "**/*.py"),
                 recursive=True)]

import importlib.util
modules = {}
for f in files:
    spec = importlib.util.spec_from_file_location(f, f)
    modules[f] = importlib.util.module_from_spec(spec)

print(modules.keys())

import conda_package_handling.cli
import conda_package_handling.conda_fmt
import conda_package_handling.validate
import conda_package_handling.__main__
import conda_package_handling.tarball
import conda_package_handling.api
import conda_package_handling._version
import conda_package_handling.interface
import conda_package_handling.__init__
import conda_package_handling.utils
import conda.core.solve
import conda.core.portability
import conda.core.path_actions
import conda.core.package_cache_data
import conda.core.package_cache
import conda.core.index
import conda.core.subdir_data
import conda.core.prefix_data
import conda.core.link
import conda.core.envs_manager
import conda.core.__init__
import conda.core.initialize
import conda.base.context
import conda.base.constants
import conda.base.exceptions
import conda.base.__init__
import conda.install
import conda.compat
import conda.__main__
import conda.api
import conda.exceptions
import conda.common.io
import conda.common.logic
import conda.common.decorators
import conda.common.path
import conda.common.constants
import conda.common.configuration
import conda.common.toposort
import conda.common.cuda
import conda.common.compat
import conda.common.pkg_formatsthon
import conda.common.pkg_formats.__init__
import conda.common.url
import conda.common.serialize
import conda.common.disk
import conda.common.__init__
import conda.common.signals
import conda.common._os.linux
import conda.common._os.unix
import conda.common._os.windows
import conda.common._os.__init__
import conda.activate
import conda.cli.main_package
import conda.cli.main_pip
import conda.cli.find_commands
import conda.cli.install
import conda.cli.main_remove
import conda.cli.main_install
import conda.cli.main_list
import conda.cli.main_config
import conda.cli.parsers
import conda.cli.common
import conda.cli.main_create
import conda.cli.main_search
import conda.cli.conda_argparse
import conda.cli.main_run
import conda.cli.main_help
import conda.cli.activate
import conda.cli.main_clean
import conda.cli.main
import conda.cli.python_api
import conda.cli.main_info
import conda.cli.__init__
import conda.cli.main_init
import conda.cli.main_update
import conda.resolve
import conda.exports
import conda._vendor.cpuinfo
import conda._vendor.frozendict
import conda._vendor.appdirs
import conda._vendor.auxlib.decorators
import conda._vendor.auxlib.path
import conda._vendor.auxlib.logz
import conda._vendor.auxlib.configuration
import conda._vendor.auxlib.packaging
import conda._vendor.auxlib.type_coercion
import conda._vendor.auxlib.compat
import conda._vendor.auxlib.deprecation
import conda._vendor.auxlib.collection
import conda._vendor.auxlib.entity
import conda._vendor.auxlib.exceptions
import conda._vendor.auxlib.crypt
import conda._vendor.auxlib._vendor.five
import conda._vendor.auxlib._vendor.__init__
import conda._vendor.auxlib._vendor.boltons.timeutils
import conda._vendor.auxlib._vendor.boltons.__init__
import conda._vendor.auxlib._vendor.six
import conda._vendor.auxlib.__init__
import conda._vendor.auxlib.factory
import conda._vendor.auxlib.ish
import conda._vendor.toolz.itertoolz
import conda._vendor.toolz.dicttoolz
import conda._vendor.toolz.compatibility
import conda._vendor.toolz.__init__
import conda._vendor.toolz.recipes
import conda._vendor.toolz.utils
import conda._vendor.urllib3.util.url
import conda._vendor.urllib3.util.__init__
import conda._vendor.urllib3.exceptions
import conda._vendor.urllib3.__init__
import conda._vendor.tqdm._utils
import conda._vendor.tqdm.__main__
import conda._vendor.tqdm._version
import conda._vendor.tqdm._main
import conda._vendor.tqdm._monitor
import conda._vendor.tqdm.__init__
import conda._vendor.tqdm._tqdm
import conda._vendor.distro
import conda._vendor.__init__
import conda._vendor.boltons.timeutils
import conda._vendor.boltons.setutils
import conda._vendor.boltons.__init__
import conda.__init__
import conda.models.dist
import conda.models.records
import conda.models.leased_path_entry
import conda.models.package_info
import conda.models.prefix_graph
import conda.models.version
import conda.models.match_spec
import conda.models.__init__
import conda.models.enums
import conda.models.channel
import conda.misc
import conda.utils
import conda.instructions
import conda.gateways.logging
import conda.gateways.anaconda_client
import conda.gateways.connection.session
import conda.gateways.connection.adapters.localfs
import conda.gateways.connection.adapters.ftp
import conda.gateways.connection.adapters.s3
import conda.gateways.connection.adapters.__init__
import conda.gateways.connection.download
import conda.gateways.connection.__init__
import conda.gateways.subprocess
import conda.gateways.__init__
import conda.gateways.disk.test
import conda.gateways.disk.update
import conda.gateways.disk.delete
import conda.gateways.disk.permissions
import conda.gateways.disk.create
import conda.gateways.disk.read
import conda.gateways.disk.link
import conda.gateways.disk.__init__
import conda.lock
import conda.plan
import conda.history

