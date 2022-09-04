# -*- coding: utf-8 -*-

# ==============================================================================
# COPYRIGHT (C) 1991 - 2015  EDF R&D                  WWW.CODE-ASTER.ORG
# THIS PROGRAM IS FREE SOFTWARE; YOU CAN REDISTRIBUTE IT AND/OR MODIFY
# IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS PUBLISHED BY
# THE FREE SOFTWARE FOUNDATION; EITHER VERSION 2 OF THE LICENSE, OR
# (AT YOUR OPTION) ANY LATER VERSION.
#
# THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT
# WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF
# MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU
# GENERAL PUBLIC LICENSE FOR MORE DETAILS.
#
# YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE
# ALONG WITH THIS PROGRAM; IF NOT, WRITE TO EDF R&D CODE_ASTER,
#    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
# ==============================================================================

"""
This module defines helper functions for system functionnalities.
"""
# should only use standard Python modules

import sys
import os
import os.path as osp
import re
import platform
import getpass


PASSWD_SEP = ":"
HOST_SEP = "@"
PATH_SEP = ":"

# store local user (will be the default for remote machines)
local_full_host = None   # temporary and incomplete initialization


def short_hostname(host):
    """Return the short name of a host (without domain name).
    Used to know if two hosts are the same."""
    if host.replace('.', '').isdigit():
        # this is an ip address
        return host
    return host.split('.')[0]


def get_hostname(host):
    """Return hostname of the machine 'host' or current machine if None.
    """
    from socket import gethostbyaddr
    if host == None:
        host = local_full_host
    try:
        fqn, alias, ip = gethostbyaddr(host)
    except:
        fqn, alias, ip = host, [], None
    if fqn.find('localhost') > -1:
        alias = [a for a in alias if a.find('localhost')<0]
        if len(alias)>0:
            fqn = alias[0]
        for a in alias:
            if a.find('.')>-1:
                fqn = a
                break
    return fqn

def safe_pathname(path):
    """Return a *safe* pathname, without non-alphanumeric characters."""
    expr = re.compile('[^a-zA-Z0-9_\-\+]+')
    path = expr.sub('_', path)
    return path

local_user      = getpass.getuser()
local_user_path = safe_pathname(getpass.getuser())
local_full_host = get_hostname(platform.uname()[1])
local_host      = short_hostname(local_full_host)
default_display = ':0.0'


def on_windows():
    """Tell if it's running on a windows platform"""
    return sys.platform in ("win32", "cygwin")

def on_mac():
    """Tell if it's running on a mac platform"""
    return sys.platform in ("darwin",)

def on_linux():
    """Tell if it's running on a linux platform"""
    return not on_windows()

def on_64bits():
    """Tell if it's running on a 64 bits platform"""
    return platform.architecture()[0].startswith("64")

def is_newer_mtime(mtime1, file2):
    """Return True if mtime1 is a newer time than file2's mtime."""
    # convenient when file1 can be changed in a loop
    return mtime1 > os.stat(file2).st_mtime

def is_newer(file1, file2):
    """Return True if file1 is newer than file2."""
    return os.stat(file1).st_mtime > os.stat(file2).st_mtime


def is_localhost(host, ignore_domain=True, user=""):
    """Return True if 'host' is the same machine as localhost.
    """
    if not is_localuser(user):
        return False
    if ignore_domain:
        host = short_hostname(host)
        refe = local_host
    else:
        refe = local_full_host
    return host in ("", "localhost", refe)


def is_localuser(user):
    """Return True if 'user' is local_user.
    """
    return user in ("", local_user)


def is_localdisplay(display, ignore_domain=True):
    """Return True if 'display' is on local host.
    """
    displ, number = display.strip().split(":")
    return is_localhost(displ, ignore_domain) and re.search('^0', number)


def get_display(default=None):
    """Return the value of DISPLAY to use to open window."""
    displ = os.environ.get('DISPLAY', default)
    if not displ or is_localdisplay(displ):
        return default_display
    return displ


def same_hosts(host1, host2):
    """Tell if host1 and host2 are the same host."""
    if (is_localhost(host1) and is_localhost(host2)) \
    or (short_hostname(host1) == short_hostname(host2)):
        return True
    return False

def get_home_directory(user=""):
    """Returns user home directory"""
    return osp.expanduser("~%s" % user)

def get_exec_name(script):
    """Change name of 'script' if it's necessary in the platform."""
    if on_windows() and not script.endswith(".bat"):
        script += ".bat"
    return script

def unexpandvars_string(text, vars=None):
    """Reverse of os.path.expandvars."""
    if vars is None:
        vars = ('ASTER_ETC', 'ASTER_ROOT', 'ASTER_VERSION_DIR', 'HOME')
    if type(text) not in (str, str):
        return text
    for var in vars:
        if not os.environ.get(var):
            continue
        text = text.replace(os.environ[var], "$%s" % var)
    return text

def unexpandvars_list(enum, vars=None):
    """Unexpand all values of ``enum``."""
    new = []
    for val in enum:
        new.append(unexpandvars(val, vars))
    return new

def unexpandvars_tuple(enum, vars=None):
    """Unexpand all values of ``enum``."""
    return tuple(unexpandvars_list(enum, vars))

def unexpandvars_dict(dico, vars=None):
    """Unexpand all values of ``dico``."""
    new = {}
    for key, val in list(dico.items()):
        new[key] = unexpandvars(val, vars)
    return new

def unexpandvars(obj, vars=None):
    """Unexpand the value of ``obj`` according to its type."""
    dfunc = {
        list : unexpandvars_list,
        tuple : unexpandvars_tuple,
        dict : unexpandvars_dict,
    }
    return dfunc.get(type(obj), unexpandvars_string)(obj, vars)


class FileName(object):
    """Helper to manipulate remote pathnames."""

    def __init__(self, pathname=None):
        self._user = ''
        self._passwd = ''
        self._host = ''
        self._path = ''
        if pathname:
            self.set_pathname(pathname)


    def set_pathname(self, pathname):
        """Set the full path name, using format '[[user[:passwd]@]host:]path'"""
        self.__parse(pathname)


    def __parse(self, pathname):
        """Read file name 'pathname' given in format [[user[:passwd]@]host:]path
        and fill properties = user, passwd, mach, path
        """
        # windows : only work on local files
        if not on_linux():
            self.path = pathname
            return
        # posix
        if type(pathname) not in (str, str):
            raise TypeError
        mat = re.search('(.*):(.*)@(.*):(.*)', pathname)
        n = 4
        if mat == None:
            mat = re.search('(.*)@(.*):(.*)', pathname)
            n = 3
            if mat == None:
                mat = re.search('(.*):(.*)', pathname)
                n = 2
                if mat == None:
                    self.path = pathname
                    n = 1
        if n >= 2:
            g = list(mat.groups())
            self.path = g.pop()
            self.host = g.pop()
        if n >= 3:
            self.user = g.pop()
        if n >= 4:
            self.passwd = self.user
            self.user = g.pop()
        if self.host != '' and self.user == '':
            self.user = local_user
        self.__check()


    def __check(self):
        """Check for unauthorized values"""
        assert self.passwd == '' or self.user != ''
        assert self.user == '' or self.host != ''


    def repr(self):
        """Return FileName as string."""
        #self.__check()
        txt = ""
        if self.passwd:
            txt = PASSWD_SEP + self.passwd
        if self.user:
            txt = self.user + txt + HOST_SEP
        if self.host:
            txt += self.host + PATH_SEP
        txt += self.path
        return txt


    def asdict(self):
        """Transitionnal method : return a dict as filename2dict did."""
        return {
            "user" : self.user,
            "passwd" : self.passwd,
            "mach" : self.host,
            "name" : self.path,
        }


    def is_local(self):
        """Return True if the filename is on the local host."""
        return is_localhost(self.host) and is_localuser(self.user)

    def is_remote(self):
        """Return True if the filename is on a remote server."""
        return not self.is_local()

    # definition of properties
    def __get_user(self):
        """private get method"""
        return self._user
    def __set_user(self, value):
        """private set method"""
        self._user = value
    user = property(__get_user, __set_user)

    def __get_passwd(self):
        """private get method"""
        return self._passwd
    def __set_passwd(self, value):
        """private set method"""
        self._passwd = value
    passwd = property(__get_passwd, __set_passwd)

    def __get_host(self):
        """private get method"""
        return self._host
    def __set_host(self, value):
        """private set method"""
        self._host = value
    host = property(__get_host, __set_host)

    def __get_path(self):
        """private get method"""
        return self._path
    def __set_path(self, value):
        """private set method"""
        self._path = value
    path = property(__get_path, __set_path)


class CommandLine(object):
    """This represents a command line with its arguments and gives
    convenient functions to manipulate it.
    """

    def __init__(self, cmd, *args):
        """Initialize the command and its arguments"""
        self._cmd = cmd
        self._args = args

    def get_cmd(self):
        """Return the executable name"""
        return self._cmd

    def get_args(self):
        """Return the arguments (as a tuple)"""
        return self._args

    def __default_magic(self):
        """Define default replacements. Should be called just at the lastest time."""
        # should not be used yet
        dic = { "@D" : get_display() }
        return dic

    #TODO add a method which returns a list (to use with Popen)
    def get_cmdline(self, magic=None, raw=False):
        """Return a full command line as string. magic allows string replacement."""
        dmag = {}
        if not raw:
            dmag.update(self.__default_magic())
            dmag.update(magic or {})
        cmdline = (self._cmd + ' ' + ' '.join(self._args)).strip()
        for old, new in list(dmag.items()):
            cmdline = cmdline.replace(old, new)
        return cmdline
