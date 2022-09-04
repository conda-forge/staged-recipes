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
Definition of AsterProfil class.
"""

import os
import os.path as osp
import re
from warnings import warn
from math import ceil

from asrun.core import magic
from asrun.common.i18n import _
from asrun.common_func import same_hosts2, is_localhost2
from asrun.common.utils import Enum, hms2s, YES, YES_VALUES
from asrun.common.sysutils import FileName, local_user, local_full_host, on_64bits, \
                                  PASSWD_SEP, PATH_SEP, HOST_SEP
from asrun.mystring import convert_list, split_endlines, ufmt

from asrun.backward_compatibility import bwc_deprecate_class

MODES = Enum("INTERACTIF", "BATCH")

def _dbg(*args, **kwargs):
    """Wrapper to run.DBG"""
    if magic.run is None:
        return
    magic.run.DBG(*args, **kwargs)


class ExportEntry(FileName):
    """A FileName additionnal attributes."""
    primary_key = ('user', 'host', 'path', 'type')
    other_attrs = ('ul', 'compr', 'isrep')

    def __init__(self, pathname=None, **attrs):
        """Initialization."""
        super(ExportEntry, self).__init__(pathname)
        self.data = attrs.get('data', False)
        self.result = attrs.get('result', False)
        self.type = attrs.get('type', 'libr')
        self.ul = attrs.get('ul', 0)
        self.compr = attrs.get('compr', False)
        self.isrep = attrs.get('isrep', False)
        #TODO make them properties to easily check values at assignment

    def copy(self):
        """Return a new object with identical content."""
        new = ExportEntry(self.repr(),
                          data=self.data, result=self.result,
                          type=self.type, ul=self.ul,
                          compr=self.compr, isrep=self.isrep)
        return new

    def check(self, checker):
        """Check the entry."""
        if self.path.find('%') > -1:
            checker.append(ufmt("invalid filename: %s", self.path))
        return checker

    def relocate(self, serv, newdir, user, convert=None):
        """Relocate the file/directory located on `serv` as if they were
        locally in `newdir`. If `newdir` is None, just remove "user@host:"
        before files.
        `user` is used to connect to and check `serv` if provided."""
        def _defconv(path):
            return osp.basename(path)
        if convert is None:
            convert = _defconv
        if serv is None or same_hosts2(serv, self.host, user, self.user):
            self.host = ""
            self.user = ""
            if newdir is not None:
                # paths of type 'nom' must not be renamed
                if self.type == 'nom':
                    basn = _defconv(self.path)
                else:
                    basn = convert(self.path)
                _dbg(ufmt("relocate %s to %s", self._path, osp.join(newdir, basn)),
                    stack_id=2)
                self.set_pathname(osp.join(newdir, basn))

    def repr(self):
        """Return the entry as string."""
        txt = ""
        if self.passwd:
            txt = PASSWD_SEP + self.passwd
        if self.user:
            txt = self.user + txt + HOST_SEP
        if self.host:
            txt += self.host + PATH_SEP
        txt += self.get_path_text()
        return txt

    def __repr__(self):
        """Simple representation"""
        txt = ""
        if self.isrep:
            txt += 'R '
        else:
            txt += 'F '
        txt += self.type + ' ' + self.repr() + ' '
        if self.data:
            txt += 'D'
        if self.result:
            txt += 'R'
        if self.compr:
            txt += 'C'
        txt += ' ' +  str(self.ul)
        return txt

    def get_path_text(self):
        """Return the path as it is saved."""
        return self._path or ''

    def __get_path(self):
        """private get method"""
        if is_localhost2(self.host):
            return osp.expandvars(self._path)
        else:
            return self._path
    def __set_path(self, value):
        """private set method"""
        self._path = value
    path = property(__get_path, __set_path)


class EntryCollection(object):
    """A collection of ExportEntry (list of files in an export)."""
    _build_after_types = ('exec', 'cmde', 'ele', 'btc')

    def __init__(self):
        """Initialization."""
        # entries are stored in an ordered list.
        self._entries = []

    def index(self, entry):
        """Return the index of an entry in the collection (-1 if not
        found)."""
        ind = -1
        for i, elt in enumerate(self._entries):
            same = True
            for k in ExportEntry.primary_key:
                same = same and getattr(elt, k) == getattr(entry, k)
            if same:
                ind = i
                break
        return ind

    def add(self, entry, stacklevel=2):
        """Add an entry into the collection."""
        index = self.index(entry)
        if index < 0:
            self._entries.append(entry)
        else:
            existing = self._entries[index]
            existing.data = existing.data or entry.data
            existing.result = existing.result or entry.result
            # these attributes should not change
            for attr in ExportEntry.other_attrs:
                if getattr(existing, attr) != getattr(entry, attr):
                    warn(ufmt("entry '%s' already exists and " \
                         "attribute '%s' differs from existing (previous '%s', new '%s').",
                         entry.path, attr, getattr(existing, attr), getattr(entry, attr)),
                         RuntimeWarning, stacklevel=stacklevel)

    def remove(self, entry):
        """Remove an entry from the collection."""
        index = self.index(entry)
        if index < 0:
            warn(ufmt("entry '%s' (type '%s') not found in collection", entry.path, entry.type),
                 RuntimeWarning, stacklevel=2)
        else:
            self._entries.pop(index)

    def update(self, enum):
        """Extend the collection by adding each item of enum."""
        for elt in enum:
            self.add(elt)

    def get_data(self):
        """Return a new collection restricted to datas."""
        datas = EntryCollection()
        datas.update([entry for entry in self if entry.data and \
                      not (entry.type in self._build_after_types \
                           and entry.result)])
        return datas

    def get_result(self):
        """Return a new collection restricted to results."""
        results = EntryCollection()
        results.update([entry for entry in self if entry.result])
        return results

    def get_type(self, type, with_completion=False):
        """Return two collections : the collection of entries of given type
        and its completion if 'with_completion' is True."""
        cres = EntryCollection()
        cother = EntryCollection()
        for entry in self:
            if entry.type == type:
                cres.add(entry)
            else:
                cother.add(entry)
        if with_completion:
            cres = (cres, cother)
        return cres

    def get_on_serv(self, serv, user=''):
        """Return a new collection of entries located on `serv`."""
        new = EntryCollection()
        new.update([entry for entry in self \
                if same_hosts2(serv, entry.host, user, entry.user)])
        return new

    def topath(self):
        """Return all pathnames."""
        return [entry.path for entry in self]

    def check(self, checker):
        """Check each entry."""
        for entry in self:
            entry.check(checker)
        return checker

    def __iter__(self):
        """Iterator on entries."""
        return iter(self._entries)

    def __len__(self):
        """Return the number of entries."""
        return len(self._entries)

    def __getitem__(self, key):
        """Get an entry"""
        return self._entries[key]

    def __repr__(self):
        """Simple representation"""
        txt = ["EntryCollection <%s>, list of entries path :" % hex(id(self)), ]
        txt += [repr(entry) for entry in self]
        return os.linesep.join(txt)


#TODO on pourrait mettre dans ce module des validateurs de profil selon
#     l'utilisation : check_pour_get_results( il faut studyid + ...)
class AsterProfil:
    """Class to read and parse an exported ASTK profile.
    Attributes :
        _filename : absolute filename of the '.export' file
        _content  : content of the corresponding '.export' file
        param     : value of each parameters (type dict) (each param is a list)
        args      : arguments (type dict)
        data      : list of the files/directories which are datas
        resu      : list of the files/directories which are results
            (each of data/resu is a dict of : path, ul, compr, type, isrep)
    """
    def __init__(self, filename=None, run=None, auto_param=True):
        """filename : filename of the '.export' file to read
        run   : AsterRun object (optional)
        auto_param: automatically ensure consistency of memory/time parameters,
            should be used with False only for specific usage (aslint for example).
        """
        # initialisations
        self.collection = EntryCollection()   #XXX should replace data and resu attributes
        self.param = {}
        self.args = {}
        self.data = []
        self.resu = []
        self.agla = []
        self._filename = None
        self.set_filename(filename)
        self.verbose = False
        self.debug = False
        self._content = None
        self._auto_param = auto_param
        # ----- reference to AsterRun object which manages the execution
        self.run = run
        if run != None:
            self.verbose = run['verbose']
            self.debug   = run['debug']
        if filename != None:
            # check if file exists
            if not osp.isfile(filename):
                self._mess(ufmt(_('file not found : %s'), filename), '<A>_ALARM')
            else:
                # read the file
                f = open(filename, 'r')
                content = f.read()
                f.close()
                self.parse(content)

        if self.debug:
            print('<DBG> <init> AsterProfil :')
            print(self)

    def __repr__(self):
        """Pretty print content of the profile
        """
        fmt = '%-20s = %s'
        txt = []
        txt.append(fmt % ('AsterProfil object', hex(id(self)) ))
        txt.append(fmt % ('.filename', self._filename))
        txt.append(self.get_content())
        return os.linesep.join(convert_list(txt))

    def __getitem__(self, key):
        """Return the value of parameter 'key', or '' if not exists
        (so never raise KeyError exception).
        """
        if key in self.param:
            return self.param[key]
        else:
            return [""]

    def has_param(self, key):
        """Tell if `key` is a known parameter"""
        return key in self.param

    def get_version_path(self):
        """Return the path of the version used.
        """
        label = self['version'][0]
        if label == "":
            path = ""
        elif not self.run:
            path = label
        else:
            path = self.run.get_version_path(label)
        return path


    def Get(self, DR, typ):
        """Return the list of datas (DR='D') or results (DR='R') or both (DR='DR')
        of the type 'typ'
        """
        lr = []
        if   DR == 'D':
            what = self.data
        elif DR == 'R':
            what = self.resu
        else:
            what = self.data + self.resu
        for entry in what:
            if entry['type'] == typ:
                lr.append(entry)
        return lr

    def get_base(self, DR):
        """If there is a base or bhdf in profile in datas/results, return
        the type and if it's compressed or not.
        """
        type_base, compress = None, None
        base = self.Get(DR, typ='base')
        if base:
            type_base = 'base'
            compress  = base[0]['compr']
        else:
            base = self.Get(DR, typ='bhdf')
            if base:
                type_base = 'bhdf'
                compress  = base[0]['compr']
        return type_base, compress

    def get_jobname(self):
        """Return job name."""
        return self["nomjob"][0]

    def get_platform(self):
        """Return the platform (LINUX, LINUX64, TRU64, WIN32...)."""
        return self['platform'][0] or self['plate-forme'][0]

    def Set(self, DR, dico):
        """Add an entry defined in `dico` in .data/.resu.
        """
        if   DR == 'D':
            l_what = [self.data]
        elif DR == 'R':
            l_what = [self.resu]
        else:
            l_what = [self.data, self.resu]
        l_k = ('type', 'isrep', 'path', 'ul', 'compr')
        for k in l_k:
            if k not in dico:
                self._mess(_("key '%s' missing") % k, '<F>_PROGRAM_ERROR')
        dico['ul'] = int(dico['ul'])
        for what in l_what:
            what.append(dico)
        # update content
        self.update_content()
        self._for_new_files()

    def Del(self, DR, typ):
        """Delete entries of type 'typ' in .data/.resu.
        """
        lobj = []
        if DR.find('D') > -1:
            for entry in self.data:
                if entry['type'] != typ:
                    lobj.append(entry)
            self.data = lobj
        lobj = []
        if DR.find('R') > -1:
            for entry in self.resu:
                if entry['type'] != typ:
                    lobj.append(entry)
            self.resu = lobj
        self._for_new_files()

    def __setitem__(self, p, v):
        """Add the parameter 'p' with the value 'v'
        """
        if self.debug and p in self.param:
            print('<DBG> (AS_PROFIL.setitem) force param['+p+'] = ', v)
        if type(v) not in (list, tuple):
            v = [v,]
        self.param[p] = v

    def __delitem__(self, p):
        """Delete the parameter 'p'
        """
        if p in self.param:
            del self.param[p]

    def _mess(self, msg, cod='', store=False):
        """Just print a message
        """
        if hasattr(self.run, 'Mess'):
            self.run.Mess(msg, cod, store)
        else:
            print('%-18s %s' % (cod, msg))

    def parse(self, content):
        """Extract fields of config from 'content'
        """
        for l in split_endlines(content):
            if not re.search('^[ ]*#', l):
                spl = l.split()
                typ = ''
                if len(spl) > 0:
                    typ = spl[0]
                    if typ not in ('A', 'P', 'F', 'R', 'N'):
                        self._mess(_('unexpected type : %s (filename: %s)') \
                            % (typ, self._filename), '<A>_ALARM')
                else:
                    continue
                if len(spl) >= 3:
                    if typ == 'P':
                        if self._check_deprecated_params(*spl[1:]) != 0:
                            continue
                        value = ' '.join(spl[2:])
                        if spl[1] in self.param:
                            self.param[spl[1]].append(value)
                        else:
                            self.param[spl[1]] = [value,]
                    elif typ == 'A':
                        value = ' '.join(spl[2:])
                        self.args[spl[1]] = value
                    elif typ == 'F' or typ == 'R':
                        if len(spl) >= 5:
                            dico = {
                                'type'  : spl[1],
                                'path'  : spl[2],
                                'isrep' : typ == 'R',
                                'ul'    : int(spl[4]),
                                'compr' : spl[3].find('C') > -1,
                            }
                            if spl[3].find('D')>-1:
                                self.data.append(dico)
                            if spl[3].find('R')>-1:
                                self.resu.append(dico)
                        else:
                            self._mess(_('fields missing on line : %s') % l, '<A>_ALARM')
                    elif typ == 'N':
                        # just store agla fields
                        self.agla.append(spl)
                elif len(spl) >= 2:
                    typ = spl[0]
                    if typ == 'A':
                        self.args[spl[1]] = ''
        # update content
        self.update_content()
        self._for_new_files()

    def copy(self):
        """Return a copy of the profile
        """
        newp = self.__class__(None, self.run)
        for attr in ('_filename', '_content'):
            setattr(newp, attr, getattr(self, attr))
        for attr in ('args', 'param'):
            setattr(newp, attr, getattr(self, attr).copy())
        for attr in ('data', 'resu'):
            for dico in getattr(self, attr):
                getattr(newp, attr).append(dico.copy())
        for val in self.agla:
            newp.agla.append(val[:])
        newp._for_new_files()
        return newp

    def update(self, other):
        """Update the profile using values from 'other' :
                - replace params and args
                - add datas and results
        """
        new_param = other.param.copy()
        for key in new_param:
            if new_param[key][0] in (None, ''):
                del new_param[key]
        self.param.update(new_param)
        self.args.update(other.args)
        self.data.extend(other.data)
        self.resu.extend(other.resu)
        self.agla.extend(other.agla)
        self._for_new_files()

    def update_content(self):
        """Fill 'content' attribute."""
        # set all memory and time values
        if self._auto_param:
            self.set_param_limits()
        txt = []
        for p, dico in ('P', self.param), ('A', self.args):
            sorted_keys = list(dico.keys())
            sorted_keys.sort()
            for key in sorted_keys:
                l_val = dico[key]
                if type(l_val) not in (list, tuple):
                    l_val = [l_val,]
                for v in l_val:
                    txt.append(' '.join([p, key, str(v)]))
        for dr, l_val in ('D', self.data), ('R', self.resu):
            for d in l_val:
                c = ' '
                if d['compr']:
                    c = 'C'
                fr = 'F'
                if d['isrep']:
                    fr = 'R'
                txt.append(' '.join([fr, d['type'], d['path'], dr+c, str(d['ul'])]))
        for val in self.agla:
            txt.append(' '.join(val))
        txt.append('')
        self._content = os.linesep.join(convert_list(txt))

    def get_filename(self):
        """Return filename of profile.
        """
        return self._filename

    def set_filename(self, filename):
        """Change filename of profile.
        """
        self._filename = filename

    def get_content(self):
        """Return the content of the profile.
        """
        self.update_content()
        return self._content

    def known_entries(self, fromlist):
        """Only keep from 'fromlist' entries present in this profile."""
        newc = EntryCollection()
        if fromlist is None:
            fromlist = self.collection
        for entry in fromlist:
            # ignore entries not in current collection
            if self.collection.index(entry) >= 0:
                newc.add(entry)
        return newc

    def get_collection(self):
        """Return the EntryCollection."""
        return self.collection

    def get_on_serv(self, serv, user=''):
        """Return the collection of files located on `serv`."""
        return self.collection.get_on_serv(serv, user)

    def get_data(self):
        """Return the collection of datas."""
        return self.collection.get_data()

    def get_result(self):
        """Return the collection of results."""
        return self.collection.get_result()

    def get_type(self, type, with_completion=False):
        """Return the collection of entries of type `type`."""
        return self.collection.get_type(type, with_completion)

    def add(self, entry):
        """Add an entry to the collection."""
        self.collection.add(entry)
        self._compatibility()

    def add_entry(self, pathname, **kwargs):
        """Shortcut to `add(ExportEntry(...))`."""
        return self.add(ExportEntry(pathname, **kwargs))

    def remove(self, entry):
        """Remove an entry from the collection."""
        self.collection.remove(entry)
        self._compatibility()

    def check(self, error=True):
        """Check the profile"""
        #TODO check parameters, checker object...
        checker = []
        self.collection.check(checker)
        if error:
            for msg in checker:
                self._mess(msg, '<E>_ERROR')
            if checker:
                self._mess(_("Invalid profile content."), '<F>_ERROR')
        return checker


    def WriteExportTo(self, fich, dbg=False):
        """Write the export file represents this profile.
        """
        self.set_filename(self._filename or fich)
        self.update_content()
        if self.debug or dbg:
            print('<DBG> <-- content of "%s"' % fich)
            print(self._content)
            print('<DBG> end of file -->')
        try:
            with open(fich, 'w') as f:
                f.write(self._content)
        except IOError:
            self._mess(ufmt(_('No write access to %s'), fich), '<F>_ERROR')
        except Exception:
            self._mess(ufmt(_('Can not write export file : %s'), fich), '<F>_ERROR')

    def add_param_from_dict(self, dpara):
        """Add parameters and arguments to a profile.
        """
        self.args['tpmax']          = dpara['tps_job']
        self.args['memjeveux']      = dpara['memjeveux']
        if dpara['memjeveux_stat'] != 0:
            self.args['memjeveux_stat'] = dpara['memjeveux_stat']
        new_para = {}
        for key, val in list(dpara.items()):
            if key in self.args:
                continue
            if key == 'tps_job':
                key = 'tpsjob'
                val = ceil(val / 60.)
            elif key == 'mem_job':
                key = 'memjob'
                val = val * 1024
            if val != 0:
                new_para[key] = [val,]
        self.param.update(new_para)

    def add_default_parameters(self):
        """Add default values in parameters to make the profile immediately runnable.
        """
        if self.run:
            self['version'] = self.run['aster_vers']
            self['origine'] = 'ASTK %s' % self.run.__version__
            # XXX may be undefined!
            self.set_param_time(hms2s(self.run['interactif_tpsmax']))
            self.set_param_memory(self.run['interactif_memmax'])
        else:
            self.set_param_time(3600*24)
            self.set_param_memory(2000)  # < 2 GB for 32 bits platforms

        # add default values
        self['actions'] = "make_etude"
        self['consbtc'] = YES
        self['soumbtc'] = YES
        self['mem_aster'] = 100
        self['mpi_nbcpu'] = 1
        self['mpi_nbnoeud'] = 1

        self.set_running_mode(MODES.INTERACTIF)

    def set_param_time(self, tsec):
        """Set time parameter in seconds."""
        tsec = float(tsec)
        self['time_limit'] = tsec
        self['tpsjob'] = max(int(1.0 * tsec / 60) + 1, 1)
        self.args['tpmax'] = tsec
        _dbg('P time_limit: %s    P tpsjob: %s    A tpmax: %s' \
                      % (self['time_limit'][0], self['tpsjob'][0],
                         self.args['tpmax']))

    def set_param_memory(self, memory):
        """Set memory parameter in MB."""
        if on_64bits():
            facW = 8
        else:
            facW = 4
        memory = float(memory)
        self['memory_limit'] = memory
        self['memjob'] = int(memory * 1024)
        ratio = (float(self['mem_aster'][0] or 100.)) / 100.
        self.args['memjeveux'] = 1.0 * memory / facW * ratio
        _dbg('P memory_limit: %s    P memjob: %s    A memjeveux: %s' \
                      % (self['memory_limit'][0], self['memjob'][0],
                         self.args['memjeveux']))

    def set_param_limits(self):
        """Set memory and time limits"""
        if not self.has_param('memory_limit') and self.has_param('memjob'):
            self['memory_limit'] = float(self['memjob'][0] or 0) / 1024
        if self.has_param('memory_limit'):
            self.set_param_memory(self['memory_limit'][0])
        if not self.has_param('time_limit') and self.has_param('tpsjob'):
            self['time_limit'] = float(self['tpsjob'][0] or 0) * 60
        if self.has_param('time_limit'):
            self.set_param_time(self['time_limit'][0])

    def from_remote_server(self, ignore_types=None):
        """Change local pathnames to be visible from a remote server.
        Do not change files/dirs of ignore_types."""
        for entry in self.collection:
            if entry.is_local():
                entry.user = local_user
                entry.host = local_full_host
        self._compatibility()

    def relocate(self, serv, newdir=None, user='', convert=None, fromlist=None):
        """Relocate the entries from 'fromlist' or all entries
        if 'fromlist' is None."""
        fromlist = self.known_entries(fromlist)
        for entry in fromlist:
            entry.relocate(serv, newdir, user, convert)
        self._compatibility()

    def absolutize_filename(self, export):
        """Change relative filenames to their absolute name relative to
        the dirname of `export`."""
        dirname = osp.dirname(export)
        for entry in self.collection:
            entry.path = osp.join(dirname, entry.path)
        self._compatibility()

    def set_running_mode(self, mode):
        """Set the running mode"""
        # string assignment is used by the Aster & OM Salomé modules
        if type(mode) is str:
            mode = getattr(MODES, mode.upper(), -1)
        if not MODES.exists(mode):
            raise ValueError("not a valid mode : %s" % mode)
        mode = MODES.get_id(mode).lower()
        if self.run and self.run.get(mode) not in YES_VALUES:
            mode = "interactif"
        self["mode"] = mode

    def get_timeout(self):
        """Return timeout value from profile.
        """
        val = self['tpsjob'][0]
        try:
            timeout = int(float(val) * 60)
        except Exception as msg:
            raise Exception("%s\nException : %s" % (val, msg))
        return timeout

    def _check_deprecated_params(self, key, *values):
        """Check and warn about deprecated entries."""
        if key == 'xterm':
            warn("'xterm' parameter is deprecated in .export. "
                 "'terminal' value is taken from the configuration and used instead.",
                 DeprecationWarning, stacklevel=3)
            return 1
        if key == 'flashdir':
            warn("'flashdir' parameter is deprecated in .export. "
                 "It should be now given as a directory entry of type 'flash'.",
                 DeprecationWarning, stacklevel=3)
            dico = {
                'type'  : 'flash',
                'path'  : values[0],
                'isrep' : True,
                'ul'    : 0,
                'compr' : False,
            }
            self.resu.append(dico)
            return 1
        return 0

    # transitionnal functions during refactoring : data/resu will be removed
    def _for_new_files(self):
        """Fill .collection from .data/.resu.
        Must be called by any function modifying .data/.resu attrs."""
        self.collection = EntryCollection()
        for dico in self.data:
            self.collection.add(ExportEntry(dico['path'], data=True, **dico),
                                stacklevel=3)
        for dico in self.resu:
            self.collection.add(ExportEntry(dico['path'], result=True, **dico),
                                stacklevel=3)

    def _compatibility(self):
        """Fill .data/.resu from .collection.
        Must be called by any function modifying the new _files attribute."""
        self.data = []
        self.resu = []
        for entry in self.collection:
            dico = {
                'path' : entry.repr(),
                'type' : entry.type,
                'ul' : entry.ul,
                'isrep' : entry.isrep,
                'compr' : entry.compr,
            }
            if entry.data:
                self.data.append(dico)
            if entry.result:
                self.resu.append(dico)

ASTER_PROFIL = bwc_deprecate_class('ASTER_PROFIL', AsterProfil)
