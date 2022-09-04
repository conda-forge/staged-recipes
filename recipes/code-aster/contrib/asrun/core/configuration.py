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
This module defines the unique Configuration object.
"""

import sys
import os
import os.path as osp
import logging

from asrun.common.utils import Singleton
from asrun.common.sysutils import local_host, on_windows, on_64bits, CommandLine

COMMENT = "# "
LINESEP = os.linesep
DEF = " : "


class Entry(object):
    """Definition of an entry in the Configuration"""

    def __init__(self, name, value, descr=""):
        """Initialization"""
        if not name:
            raise ValueError("invalid entry name: %s" % repr(name))
        self.name = name
        self._value = value
        self.descr = descr

    def write_to(self, dest):
        """Add representation to dest"""
        repr = [COMMENT + line for line in self.descr.split(LINESEP)]
        repr.append(self.name + DEF + str(self.value))
        repr.append('')
        dest.write(repr)

    def _get_value(self):
        """Return the value"""
        if isinstance(self._value, CommandLine):
            return self._value.get_cmdline()
        return self._value
    def _set_value(self, value):
        """Change value of the entry"""
        self._value = value
    value = property(_get_value, _set_value)


class EntryAlias(Entry):
    """Define an alias for an existing entry.
    Specially for deprecated or renamed entries"""

    def __init__(self, alias, entry):
        """Initialization"""
        self.aliasto = entry.name
        super(EntryAlias, self).__init__(alias, entry.value, entry.descr)

    def write_to(self, dest):
        """Do nothing"""


class SectionTitle(Entry):
    """Allow to group entries in sections"""

    def write_to(self, dest):
        """Add representation to dest"""
        repr = ['', '']
        repr.append(COMMENT + "[%s]" % self.value)
        if self.descr:
            repr.extend([COMMENT + line for line in self.descr.split(LINESEP)])
        dest.write(repr)


class Configuration(Singleton):
    """Definition of the configuration"""
    _singleton_id = 'asrun.configuration.Configuration'
    #XXX transitionnal implementation
    #       (code to change is marking with XXX)

    #XXX define properties to track deprecated fields
    def __init__(self):
        """Initialization - for attrs needed calculation"""
        self._entries = []
        self._idx = {}
        # static entries
        self._default_values()
        # computed entries
        self._context_values()

    def add_entry(self, entry):
        """Add an entry. Change an existing entry is only allowed
        if previous one was None"""
        prev = self.get_entry(entry.name)
        if prev is not None:
            # modify an existing entry
            #if prev.value is not None:
                #raise ValueError("changing an existing value is not allowed "
                    #"for key '%s'" % prev.name)
            prev.value = entry.value
        else:
            # new entry
            self._idx[entry.name] = len(self._entries)
            self._entries.append(entry)

    def get_entry(self, name):
        """Return entry by name"""
        idx = self._idx.get(name)
        if idx is None:
            return None
        return self._entries[idx]

    def get(self, entryname):
        """Return the value of an entry"""
        entry = self.get_entry(entryname)
        if entry is None:
            raise AttributeError("configuration has no entry '%s'" % entryname)
        return entry.value

    def __getitem__(self, entryname):
        """Return the value of an entry.
        Transitional function"""
        return self.get(entryname)

    def _default_values(self):
        """Fill default for constant entries."""
        from asrun.core.default_configuration import entries
        for name, value, descr in entries:
            if name == "Section":
                self.add_entry(SectionTitle(name + value, value, descr))
            else:
                self.add_entry(Entry(name, value, descr))

    def _context_values(self):
        """Determine values depending on the context"""
        # computational node
        self.add_entry(Entry("node", local_host))
        self.add_entry(EntryAlias("noeud", self.get_entry("node")))
        # platform
        if on_windows():
            if on_64bits():
                platform = "WIN64"
            else:
                platform = "WIN32"
        else:
            platform = "LINUX"
            if on_64bits():
                platform = "LINUX64"
        self.add_entry(Entry("platform", platform))
        self.add_entry(EntryAlias("plate-forme", self.get_entry("platform")))
        # editor
        #TODO add gedit, kate.../gnome-terminal, konsole + display
        editor = _test_alternatives(
            "EDITOR",
            [
                CommandLine("/usr/bin/editor"),
                CommandLine("/usr/bin/nedit"),
            ])
        self.add_entry(Entry("editor", editor))
        # terminal
        terminal = _test_alternatives(
            "TERM",
            [
                CommandLine("/usr/bin/x-terminal-emulator"),
                CommandLine("/usr/bin/xterm"),
                CommandLine("gnome-terminal", "--execute", "@E"),
            ])
        self.add_entry(Entry("terminal", terminal))

    def repr(self):
        """Represent the configuration"""
        bld = FileBuilder()
        for entry in self._entries:
            entry.write_to(bld)
        return bld.get_text()


class FileBuilder(object):
    """Write a config file"""

    def __init__(self):
        """Initialization"""
        self._lines = []

    def write(self, text):
        """Add text"""
        if type(text) not in (list, tuple):
            text = [text,]
        self._lines.extend(text)

    def get_text(self):
        """Return full text"""
        return LINESEP.join(self._lines)


def _test_alternatives(envvar=None, values=None):
    """Search for a program using an environment variable or several possible
    CommandLine objects.
    """
    res = os.environ.get(envvar)
    if res is None and values:
        for cmd in values:
            prg = cmd.get_cmd()
            if osp.isfile(prg) and os.access(prg, os.X_OK):
                #res = cmd.get_cmdline(raw=True) #XXX
                res = cmd
                break
    return res


# similar functions as in the sysutils module but work on Code_Aster platform
# instead of sys.platform
def plt_windows(platform):
    """Tell if it's running on a windows platform"""
    return platform in ("WIN32", "WIN64", "CYGWIN")

def plt_linux(platform):
    """Tell if it's running on a linux platform"""
    return not plt_windows(platform)

def plt_64bits(platform):
    """Tell if it's running on a 64 bits platform"""
    return platform.endswith("64")

def get_plt_exec_name(platform, script):
    """Change name of 'script' if it's necessary in the platform.
    """
    if plt_windows(platform) and not script.endswith(".bat"):
        script += ".bat"
    return script


# transitionnal, will be probably refactored
# why Magic ? ... I dont' know !
class Magic(Singleton):
    """Store some asrun objects to share them by several modules.
    """
    # stored in a container will make easier the refactoring
    _singleton_id = 'asrun.configuration.Magic'
    def __init__(self):
        self._run = None
        self._stdout = sys.stdout
        self._stderr = sys.stderr
        self._stdout_ini = self._stdout
        self._stderr_ini = self._stderr
        self._log = None

    def __get_run(self):
        return self._run
    def __set_run(self, value):
        self._run = value
    run = property(__get_run, __set_run)


    def get_stdout(self):
        return self._stdout

    def set_stdout(self, value):
        """Open file to redefine stdout"""
        if type(value) not in (str, str):
            return
        try:
            self._stdout = open(value, 'a')
        except IOError:
            pass

    def restore_stdout(self):
        self._stdout = self._stdout_ini

    def get_stderr(self):
        return self._stderr

    def set_stderr(self, value):
        """Open file to redefine stderr"""
        if type(value) not in (str, str):
            return
        try:
            self._stderr = open(value, 'a')
        except IOError:
            pass

    def restore_stderr(self):
        self._stderr = self._stderr_ini

    @property
    def log(self):
        if self._log is None:
            import warnings
            warnings.warn('logger object has not been initialized', RuntimeWarning, stacklevel=3)
            dbg = self.run is not None and self.run['debug']
            self.init_logger(debug=dbg)
        return self._log

    @log.setter
    def log(self, value):
        self._log = value

    def init_logger(self, filename=None, debug=False):
        """Define a logger.

        Arguments:
            filename (str or object): May be a filename or a stream object
                (that suports `write` and `flush` methods.).
        """
        opts = {
            'format': "%(asctime)s %(levelname)-8s %(message)s",
            'datefmt': '%H:%M:%S',
            'level': logging.DEBUG if debug else logging.INFO,
        }
        self.log = logging.getLogger("asrun")
        if type(filename) in (str, str):
            opts['filename'] = filename
        if hasattr(filename, 'write'):
            opts['stream'] = filename
        logging.basicConfig(**opts)


if __name__ == "__main__":
    cfg = Configuration()
