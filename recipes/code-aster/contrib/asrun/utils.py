"""1.8.0 > 1.8.1 backward compatibility"""
#pylint: disable-msg=W0611

from warnings import warn
warn('moved to asrun.common.utils', DeprecationWarning, stacklevel=2)

from asrun.common.utils import (
    get_encoding,
    listsurcharge,
    less_than_version,
    version2tuple,
    tuple2version,
    get_list,
    getpara,
    get_absolute_path,
    get_absolute_dirname,
    default_install_value,
    sha1,
    find_command,
    search_enclosed,
    re_search,
)

from asrun.backward_compatibility import (
    read_rcfile,
    parse_config,
    get_timeout,
    add_param
)
