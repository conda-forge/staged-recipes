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

"""Definition of AsterConfig class.
"""

import os
import os.path as osp
import re

from asrun.common.i18n import _
from asrun.mystring import split_endlines, ufmt
from asrun.common.utils import get_absolute_dirname

from asrun.backward_compatibility import bwc_deprecate_class

REPPY = 'Python'
DEFAULTS = {
    # name of source directories
    'SRCFOR'          : ['bibfor'],
    'SRCFERM'         : ['fermetur'],
    'SRCC'            : ['bibc'],
    'SRCPY'           : ['bibpyt'],
    'SRCCATA'         : ['catalo'],
    'SRCCAPY'         : ['catapy'],
    'SRCTEST'         : ['astest'],
    'SRCMAT'          : ['materiau'],
    'SRCHIST'         : ['histor'],
    # name of "binaries" (as results of a make)
    'MAKE'            : ['debug nodebug'],
    'BIN_NODBG'       : ['asteru.exe'],
    'BIN_DBG'         : ['asterd.exe'],
    'BINCMDE'         : ['commande'],
    'BINELE'          : ['elements'],
    'BINPICKLED'      : ['cata_ele.pickled'],
    'BINLIB_NODBG'    : ['lib/libaster.a'],
    'BINLIB_DBG'      : ['lib/libasterd.a'],
    'BINLIBF_NODBG'   : ['lib/libferm.a'],
    'BINLIBF_DBG'     : ['lib/libfermd.a'],
    'BINOBJ_NODBG'    : ['obj'],
    'BINOBJF_NODBG'   : ['obj_f'],
    'BINOBJ_DBG'      : ['dbg'],
    'BINOBJF_DBG'     : ['dbg_f'],
    'BINOBJ_MAIN'     : ['python.o'],
    # name of bibpyt in execution directory
    'REPPY'           : [REPPY],
    # modules to compile elements
    'MAKE_SURCH_OFFI' : [osp.join('Lecture_Cata_Ele', 'make_surch_offi.py')],
    'MAKE_CAPY_OFFI'  : [osp.join('Lecture_Cata_Ele', 'make_capy_offi.py')],
    # command line arguments for aster executable
    'REPOUT'          : [osp.join('$ASTER_ROOT', 'outils')],
    'REPMAT'          : [osp.join('$ASTER_VERSION_DIR', 'materiau')],
    'REPDEX'          : [osp.join('$ASTER_VERSION_DIR', 'datg')],
    'ARGPYT'          : [osp.join('Execution', 'E_SUPERV.py')],
    'ARGEXE'          : ['-eficas_path ' + REPPY],
}


class AsterConfig:
    """Class to read a configuration file of a Code_Aster version ('config.txt')
    and give easy access to the parameters.
    """
    def __init__(self, config_file, run=None, version_path=None):
        """config_file : filename of the 'config.txt' file to read
        run : AsterRun object (optional)
        version_path : directory of the version (if it is not the dirname of 'config_file').
        """
        # ----- initialisations
        self.config = {}
        self.filename = config_file
        self.dirn = version_path or get_absolute_dirname(config_file)
        self.verbose = False
        self.debug = False

        # ----- reference to AsterRun object which manages the execution
        self.run = run
        if run != None:
            self.verbose = run['verbose']
            self.debug = run['debug']

        # ----- set optional/defaults values (ALWAYS AS LIST !)
        self.config = DEFAULTS.copy()
        # ----- read config file
        if not osp.isfile(config_file):
            self._mess(ufmt(_('file not found : %s'), config_file), '<F>_FILE_NOT_FOUND')

        f = open(config_file, 'r')
        content = f.read()
        f.close()
        self.config.update(self._parse(content))

        if self.debug:
            print('<DBG> <init> AsterConfig :')
            print(self)

    def __repr__(self):
        """Pretty print configuration
        """
        fmt = ' %-10s = %s'
        txt = []
        txt.append(fmt % ('Filename', self.filename))
        sorted_keys = list(self.config.keys())
        sorted_keys.sort()
        for key in sorted_keys:
            txt.append(fmt % (key, self.config[key]))
        return os.linesep.join(txt)

    def __getitem__(self, key):
        """Return the value of parameter 'key', or '' if not exists
        (so never raise KeyError exception).
        """
        if key in self.config:
            return self.config[key]
        else:
            return ['']

    def keys(self):
        """Return the list of keys.
        """
        return list(self.config.keys())

    def get_filename(self):
        """Return the filename.
        """
        return self.filename

    def get_with_absolute_path(self, key, sep=' '):
        """For fields containing pathnames returns absolute path names.
        """
        l_res = []
        for val in self[key]:
            l_res.extend([osp.join(self.dirn, path) for path in val.split()])
        return l_res

    def get_defines(self):
        """Return the list of #define values store in the DEFS field.
        """
        defines = []
        for defs in self['DEFS']:
            defines.extend(re.split('[ ,]', defs))
        return defines

    def _mess(self, msg, cod='', store=False):
        """Just print a message
        """
        if hasattr(self.run, 'Mess'):
            self.run.Mess(msg, cod, store)
        else:
            print('%-18s %s' % (cod, msg))

    def _parse(self, content):
        """Extract fields of config from 'content'
        """
        os.environ['ASTER_VERSION_DIR'] = self.dirn
        cfg = {}
        self._content = content
        for l in split_endlines(self._content):
            if not re.search('^[ ]*#', l):
                try:
                    typ, nam, ver, val = l.split('|')
                    #print '========>', typ, '//', nam, '//', ver, '//', val
                    typ = re.sub('^[ ]*', '', re.sub('[ ]*$', '', typ)).strip()
                    val = re.sub('^[ ]*', '', re.sub('[ ]*$', '', val)).strip()
                    if val != '':
                        val = osp.expandvars(val)
                        if typ in cfg:
                            cfg[typ].append(val)
                        else:
                            cfg[typ] = [val]
                except ValueError:
                    pass
        return cfg

    def WriteConfigTo(self, fich):
        """Dump the content of config file into 'filename'.
        """
        try:
            with open(fich, 'w') as f:
                f.write(self._content)
        except IOError as msg:
            self._mess(ufmt(_('No write access to %s'), fich), '<F>_ERROR')

ASTER_CONFIG = bwc_deprecate_class('ASTER_CONFIG', AsterConfig)

def build_config_from_export(run, prof):
    """Build an AsterConfig object from the default config file or the one
    referenced in the profile."""
    from asrun.common_func  import get_tmpname
    version_path = prof.get_version_path()
    lconf = prof.Get('D', typ='conf')
    if not lconf:
        ficconf = os.path.join(version_path, 'config.txt')
    else:
        ficconf = lconf[0]['path']
        if run.IsRemote(ficconf):
            ficconf = get_tmpname(run, run['tmp_user'], basename='config.txt')
            run.ToDelete(ficconf)
            kret = run.Copy(ficconf, lconf[0]['path'])
        else:
            ficconf = run.PathOnly(ficconf)
    return AsterConfig(ficconf, run, version_path)

def build_config_of_version(run, label, filename=None, error=True):
    """Build an AsterConfig object of the version named 'label'."""
    filename = filename or 'config.txt'
    version_path = run.get_version_path(label)
    ficconf = os.path.join(version_path, filename)
    if not osp.exists(ficconf):
        if not error:
            return None
        run.Mess(ufmt(_('file not found : %s'), ficconf), '<F>_FILE_NOT_FOUND')
    return AsterConfig(ficconf, run, version_path)
