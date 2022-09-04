# -*- coding: utf-8 -*-
#pylint: disable-msg=E0611

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
Some utilities for asrun using only standard Python modules.
"""

import sys
import os
import os.path as osp
import re
import stat
import locale
import time
from functools import partial
from warnings import warn
from hashlib import sha1

from .sysutils import safe_pathname


YES_VALUES = ['yes', 'oui', 'y', 'o']
YES_VALUES.extend([v.upper() for v in YES_VALUES])
NO_VALUES  = ['no', 'non', 'n']
NO_VALUES.extend([v.upper() for v in NO_VALUES])
YES = YES_VALUES[0]
NO  = NO_VALUES[0]


class Singleton(object):
    """Singleton implementation in python."""
    # add _singleton_id attribute to the class to be independant of import path used
    __inst = {}
    def __new__(cls, *args, **kargs):
        cls_id = getattr(cls, '_singleton_id', cls)
        if Singleton.__inst.get(cls_id) is None:
            Singleton.__inst[cls_id] = object.__new__(cls)
        return Singleton.__inst[cls_id]


class Enum(object):
    """
    This class emulates a C-like enum for python. It is initialized with a list
    of strings to be used as the enum symbolic keys. The enum values are automatically
    generated as sequencing integer starting at 0.
    """
    def __init__(self, *keys):
        """Constructor"""
        self._dict_keys = {}
        for inum, key in enumerate(keys):
            setattr(self, key, 2**inum)
            self._dict_keys[2**inum] = key

    def exists(self, value):
        """Tell if value is in the enumeration"""
        return self.get_id(value) is not None

    def get_id(self, value):
        """Return the key associated to the given value"""
        return self._dict_keys.get(value, None)


def _datefmt():
    """Localized date format"""
    if get_language() == "fr":
        return "%d/%m/%Y"
    else:
        return "%m/%d/%Y"

def _timefmt():
    """Localized time format"""
    if get_language() == "fr":
        return "%H:%M:%S"
    else:
        return "%I:%M:%S"

def now(datefmt=None, timefmt=None, sep=" "):
    if datefmt is None:
        datefmt = _datefmt()
    if timefmt is None:
        timefmt = _timefmt()
    fmt = ""
    if datefmt:
        fmt = datefmt
    if timefmt:
        if datefmt:
            fmt += sep
        fmt += timefmt
    return time.strftime(fmt)

def hms2s(vtime):
    """Convert a time given in the format 'H:M:S' in seconds.
    Raise ValueError if fails."""
    secs = 0
    stps = vtime.split(':')
    m = 1
    while len(stps) > 0:
        secs += int(stps.pop()) * m
        m = m * 60
    if len(stps) > 3:
        raise ValueError("invalid time value : '%s'" % vtime)
    return secs

def dhms2s(vtime, sep='-'):
    """Convert a time given in the format 'D-H:M:S' in seconds."""
    if type(vtime) in (list, tuple):
        return sum([dhms2s(vt) for vt in vtime])
    secs = 0
    stps = vtime.split(sep)
    secs = hms2s(stps.pop())
    if len(stps) > 0:
        secs += int(stps[0]) * 86400
    return secs

_encoding = None
def get_encoding():
    """Return local encoding
    """
    global _encoding
    if _encoding is None:
        try:
            _encoding = locale.getpreferredencoding() or 'ascii'
        except locale.Error:
            _encoding = 'ascii'
    return _encoding


def get_language():
    """Return default language (2 letters)"""
    lang = locale.getdefaultlocale()[0]
    if type(lang) is str:
        lang = lang.split('_')[0]
    else:
        lang = "en"
    return lang


_val_pid = 0
def get_unique_id(jobid, num=None):
    """Return an identifier (as a pid) based on `jobid`.
    Counter is incremented at each call.
    """
    global _val_pid
    if num is None:
        _val_pid += 1
        num = _val_pid
    assert type(num) in (int, int), 'get_unique_pid: integer argument required!'
    return '%04d-%s' % (num, jobid)


def _listsurcharge_u2mess(fsurch, lf):
    """Write the fortran subroutine "surchg.f".
        fsurch : subroutine filename
        lf     : list of modified files
    """
    header = """
      SUBROUTINE SURCHG(IFM)
      INTEGER IFM
      CHARACTER*80  VALK(%(nbfile)s)
      IFM = 1"""
    fmt_line = "      VALK(%(indice)d) = '%(subroutine)s%(separ)s'"
    fmt_call = "      CALL U2MESK('A','SUPERVIS_40',%(nbfile)s,VALK)"
    footer = "      END"
    cont = []
    l_file = [os.path.basename(f) for f in lf]
    l_file.sort()
    nbfile = len(l_file)
    cont.append(header % { 'nbfile' : max(1, nbfile) })
    npl = 6
    for i, filename in enumerate(l_file):
        sep = ', '
        if i + 1 == len(l_file):
            sep = ''
        cont.append(fmt_line % { 'indice' : i + 1, 'subroutine' : filename, 'separ' : sep })

    cont.append(fmt_call % { 'nbfile' : nbfile })
    cont.append(footer)

    with open(fsurch, 'w') as f:
        f.write(os.linesep.join(cont))
    #print os.linesep.join(cont)


def _listsurcharge_utmess(fsurch, lf):
    """Write the fortran subroutine "surchg.f".
        fsurch : subroutine filename
        lf     : list of modified files
    """
    cont = ["""      SUBROUTINE SURCHG(IFM)
      INTEGER IFM
      CALL UTMESS('A', 'SURCHG', 'VERSION SURCHARGEE PAR :')"""]
    templ = "      WRITE(IFM,'(3X,A)') '"
    sep = ', '
    lmax = 72
    len0 = len(templ)
    files = [os.path.basename(f) for f in lf]
    files.sort()
    while len(files)>0:
        lig = []
        clen = len0-len(sep)
        while len(files)>0 and clen+len(files[0])+len(sep) <= lmax-1:
            clen = clen+len(files[0])+len(sep)
            lig.append("%s" % files.pop(0))
        cont.append(templ + sep.join(lig) + "'")
        # si on n'a rien pu ajouter, il faut tronquer
        if clen == len0-len(sep):
            files[0] = files[0][:lmax-1-clen-len(sep)]
    cont.extend(['      END', ''])
    f = open(fsurch, 'w')
    f.write(os.linesep.join(cont))
    f.close()


def listsurcharge(version, fsurch, lf):
    """Aiguillage pour les versions avant U2MESS ( < 8.3.14)
    Exemple : listsurcharge((9,0,5), '/tmp/surchg.f', ['rout01.f', 'rout02.f'])
    """
    version = version2tuple(version)
    if version < (8, 3, 14):
        func = _listsurcharge_utmess
    else:
        func = _listsurcharge_u2mess
    func(fsurch, lf)


def less_than_version(vers1, vers2):
    return version2tuple(vers1) < version2tuple(vers2)


def version2tuple(vers_string, beta=True):
    """1.7.9alpha --> (1, 7, 9, 'alpha')
    'beta' should be set to True, if beta versions exist.
    If beta is True, 1.8 --> (1, 8, 0, 'final'),
    and (1, 8, 0) if beta is False.
    """
    tupl0 = vers_string.split('.')
    val = []
    for v in tupl0:
        m = re.search('(^[ 0-9]+)(.*)', v)
        if m:
            val.append(int(m.group(1)))
            if m.group(2):
                val.append(m.group(2).replace('-', '').replace('_', '').strip())
        else:
            val.append(v)
    val.extend([0]*(3-len(val)))
    if beta and type(val[-1]) in (int, int):
        val.append('final')
    return tuple(val)


def tuple2version(tup):
    """(1, 8, 0, 'final') => '1.8.0.final'
    """
    return '.'.join([str(i) for i in tup])


def get_list(ftest, unique=True):
    """Build list of the tests, ignore all after # or %  (characters comment).
    """
    iret = 0
    ltest = []
    try:
        with open(ftest, 'r') as f:
            line = f.read().splitlines()
    except (OSError, IOError):
        iret = 4
        return iret, ltest

    lfich = [t for t in [re.sub(' *[#%]+.*', '', l).strip() for l in line] if t != '']
    if unique:
        # delete twins (by keeping ordering)
        ltest = []
        for t in lfich:
            if not t in ltest:
                ltest.append(t)
    else:
        ltest = lfich

    return iret, ltest


list_para_test = ['mem_job', 'tps_job', 'mem_aster', 'memjeveux', 'memjeveux_stat',
                  'ncpus', 'mpi_nbnoeud', 'mpi_nbcpu', 'liste_test', 'testlist',
                  'memory_limit', 'time_limit']

def getpara(fpara, platform=None, others=[]):
    """Return a dict object by parsing the file 'fpara' written as :
    param_name1 value1 param_name2 value2...
    (parameters name should be in list_param).
    Be careful : tps_job is in seconds in fpara and in minutes in .export (LSF) !
    memjeveux in Mw, memjeveux_stat in MB...
    """
    from asrun.common.i18n import _
    list_param = list_para_test + others
    dtrans = {
        'nnoeud_mpi' : 'mpi_nbnoeud',
        'nproc_mpi' : 'mpi_nbcpu',
    }
    supported_param = list_param + list(dtrans.keys())
    iret, err = 0, ''
    dico = {}
    for k in list_param:
        dico[k] = '0'

    # ----- check that file exists
    if not os.path.exists(fpara):
        iret = 1
        err = _('file not found : %s') % fpara
        return iret, {}, err

    # ----- parsing
    f = open(fpara, 'r')
    for str0 in f:
        line = str0.split()
        while len(line) > 0:
            w = line.pop(0)
            if w in supported_param:
                dico[dtrans.get(w, w)] = line.pop(0)
    f.close()

    # ----- ncpus keep as string...
    # ----- convert time to int
    try:
        dico['tps_job'] = int(float(dico['tps_job']))
    except ValueError:
        iret = 1
        err = _('incorrect value for tps_job (%s) in %s') % (dico['tps_job'], fpara)
        return iret, {}, err

    # ----- delete 'Mo' in mem_job value
    try:
        dico['mem_job'] = int(float(dico['mem_job'].replace('Mo', '').replace('MB', '')))
    except ValueError:
        iret = 1
        err = _('incorrect value for mem_job (%s) in %s') % (dico['mem_job'], fpara)
        return iret, {}, err

    # ----- delete 'Mo' in mem_job value
    try:
        dico['memjeveux_stat'] = int(float(dico['memjeveux_stat']))
    except ValueError:
        iret = 1
        err = _('incorrect value for memjeveux_stat (%s) in %s') % (dico['memjeveux_stat'], fpara)
        return iret, {}, err

    # ----- convert mem_aster to int
    try:
        dico['mem_aster'] = int(float(dico['mem_aster']))
    except ValueError:
        iret = 1
        err = _('incorrect value for mem_aster (%s) in %s') % (dico['mem_aster'], fpara)
        return iret, {}, err
    if dico['mem_aster'] == 0:
        dico['mem_aster'] = 100

    if platform is not None:
        if re.search('64$', platform):
            facW = 8
        else:
            facW = 4
        dico['memjeveux'] = dico['mem_job'] / facW * dico['mem_aster'] / 100.

    # number of cpus, nodes must be >= 1
    for key in ('ncpus', 'mpi_nbnoeud', 'mpi_nbcpu'):
        val = dico[key]
        if val.isdigit() and int(val) > 1:
            pass
        else:
            dico[key] = '1'
    return iret, dico, err


def get_absolute_path(path):
    """Retourne le chemin absolu en suivant les liens éventuels.
    """
    if os.path.islink(path):
        path = os.path.realpath(path)
    res = os.path.normpath(os.path.abspath(path))
    return res


def get_absolute_dirname(path):
    """Retourne le chemin absolu en suivant les liens éventuels.
    """
    res = os.path.normpath(os.path.join(get_absolute_path(path), os.pardir))
    return res


def get_subdirs(list_in):
    """Retourne les éléments de `list_in` qui ne sont pas des sous-répertoires
    des autres.
    Exemple : ['/a', '/b/c/d', '/a/b/c', '/b/c'] ==> ['/a', '/b/c']
    """
    l_out = []
    l_in = list_in[:]
    l_in.sort()
    for din in l_in:
        keep = True
        for dou in l_out:
            if din.startswith(os.path.normpath(dou) + os.sep):
                keep = False
                break
        if keep:
            l_out.append(din)
    return l_out


def make_writable(filename):
    """Force a file to be writable by the current user"""
    # equivalent to chmod u+w
    os.chmod(filename, os.stat(filename).st_mode | stat.S_IWUSR)


def remove_empty_dirs(fromdir):
    """Removes all empty dirs.
    """
    for base, dirs, files in os.walk(fromdir, topdown=False):
        try:
            os.rmdir(base)
        except:
            pass

def renametree(src, dst):
    """Rename a entire tree 'src' to or into 'dst'."""
    if not osp.exists(dst):
        os.rename(src, dst)
    elif osp.isfile(dst) != osp.isfile(src):
        raise OSError("source and destination must be both files or directories")
    elif osp.isfile(src):
        # both are files
        os.rename(src, dst)
    else:
        # src and dst are directories
        names = os.listdir(src)
        for name in names:
            srcname = osp.join(src, name)
            dstname = osp.join(dst, name)
            renametree(srcname, dstname)
        os.rmdir(src)

def get_tmpname_base(dirname=None, basename=None, user=None, node=None, pid=None):
    """Return a name for a temporary directory (*not created*)
    of the form : 'dirname'/user@machine-'basename'.'pid'
    *Only* basename is not compulsory in this variant.
    """
    basename = basename or 'tmpname-%.6f' % time.time()
    if pid == "auto":
        pid = "pid-%s-%.6f" % (os.getpid(), time.time())
    root, ext = osp.splitext(basename)
    name = '%s-%s-' % (user, node) + root + '.' + str(pid) + ext
    name = safe_pathname(name)
    return osp.join(dirname, name)


def check_joker(filename, joker):
    """Returns if 'filename' verifies 'joker' : ("toto.comm", "com?") returns True
    """
    reg = re.compile(joker.replace(".", "\.").replace("?", ".").replace("*", ".*"))
    res = reg.search(osp.basename(filename)) is not None
    return res


def default_install_value(expression, default):
    """Evaluate 'expression' (similar to "value = xxxxx")
    and return 'value' or 'default'
    """
    value = default
    try:
        d = {}
        exec(expression, d)
        if type(d['value']) in (str, str) and \
           re.search('\?{1}([^\'\"|]+?)\?{1}', d['value']) is None:
            value = d['value']
    except:
        pass
    return value


# MIMEText has been moved after python2.4
# this raises pylint E0611 error
try:
    if sys.hexversion < 0x020500F0:
        from email.MIMEText import MIMEText
    else:
        from email.mime.text import MIMEText
except ImportError:
    MIMEText = None

MIMETextClass = MIMEText

def find_command(content, command):
    """Return the lowest index in content where command is found and
    the index of the end of the command.
    """
    pos, endpos = -1, -1
    re_start = re.compile('^ *%s *\(' % re.escape(command), re.M)
    mat_start = re_start.search(content)
    if mat_start is not None:
        pos = mat_start.start()
        endpos = search_enclosed(content, pos)
    return pos, endpos


def search_enclosed(string, start=0):
    """Search the closing parenthesis of the first opening one in string.
    """
    endpos = -1
    first_found = False
    closed = False
    count = 0
    for index, char in enumerate(string[start:]):
        if char == '(':
            count += 1
        if not first_found and count > 0:
            first_found = True
        if char == ')':
            count -= 1
        if first_found and count == 0:
            closed = True
            break
    if closed:
        endpos = start + index
    return endpos


def re_search(content, **kargs):
    """Search the regular expression `pattern` in content.
    If `string` is provided, it is escaped and `pattern` must contain "%s".
    """
    flag = re.MULTILINE | kargs.get('flag', re.MULTILINE)
    what = kargs.get('result', 'bool')
    pattern = kargs.get('pattern', '%s')

    if kargs.get('string'):
        pattern = pattern % re.escape(kargs['string'])

    expr = re.compile(pattern, flag)

    if what == 'bool':
        res = expr.search(content) != None
    elif what == 'number':
        res = len(expr.findall(content))
    elif what == 'value':
        res = expr.findall(content)
    else:
        res = None
    return res


def get_plugin(uri):
    """Load and return a python object (class, function...).
    Its `uri` looks like "mainpkg.subpkg.module.object", this means
    that "mainpkg.subpkg.module" is imported and "object" is
    the plugin object to return.
    """
    path = uri.split('.')
    modname = '.'.join(path[:-1])
    if len(modname) == 0:
        raise ImportError("invalid plugin name: %s" % uri)
    try:
        __import__(modname)
        mod = sys.modules[modname]
        plugin_object = getattr(mod, path[-1])
    except (ImportError, AttributeError) as err:
        raise ImportError("plugin not found: %s\n"
            "Check the plugin name in 'etc/codeaster/asrun' configuration file\n"
            "and it would be search in PYTHONPATH : %s" % (uri, sys.path))
    return plugin_object


def unique_basename(pathname):
    """Return a basename which takes all the pathname in account
    (so it should be unique)."""
    bname = sha1(pathname.encode()).hexdigest() + '.' + osp.basename(pathname)
    return bname

__reg_prefix__ = re.compile('^[a-f0-9]{%d}\.' % (sha1('a'.encode()).digest_size * 2), re.I)

def unique_basename_remove(bname):
    """Remove the prefix added by unique_basename."""
    return __reg_prefix__.sub('', bname)

def force_list(obj):
    """Return 'obj' as a list object."""
    if type(obj) not in (list, tuple):     # pas une liste
        obj = [obj,]
    return obj

def force_couple(obj):
    """Return 'obj' as a list of couples."""
    if type(obj) not in (list, tuple):     # pas une liste
        obj = [[obj, None],]
    elif type(obj[0]) in (list, tuple):    # liste de listes
        pass
    else:
        assert len(obj) == 2, 'not a couple : %s' % obj
        obj = [obj,]
    # verif
    for i, val in enumerate(obj):
        assert len(val) == 2, 'item %d is not a couple : %s' % (i, val)
    return obj
