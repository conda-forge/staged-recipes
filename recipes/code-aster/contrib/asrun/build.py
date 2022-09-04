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

"""AsterBuild class.
"""


import os
import os.path as osp
import sys
import re
import copy
import time
from glob import glob
from zipfile import ZipFile
from warnings import warn

from asrun.core         import magic
from asrun.common.i18n  import _
from asrun.mystring     import ufmt, to_unicode
from asrun.thread       import Task, TaskAbort, Dispatcher
from asrun.runner       import Runner
from asrun.common_func  import get_tmpname
from asrun.common.utils import re_search, YES_VALUES, unique_basename_remove
from asrun.common.utils import make_writable
from asrun.common.sysutils import is_newer, is_newer_mtime
from asrun.system       import split_path

from asrun.backward_compatibility import bwc_deprecate_class

fmt_catapy = 'cata%s.py%s'
fcapy  = fmt_catapy % ('', '')
fcapy_ = fmt_catapy % ('', '*')

repcatapy = ('entete', 'commun', 'commande')
repcatalo = ('compelem', 'typelem', 'options')


class CompilTask(Task):
    """Compilation task.
    """
    # declare attrs
    run = fmsg = dep_h = None
    force = verbose = debug = False
    nbnook = nskip = 0
    cmd = ""
    def _mess(self, msg, cod='', store=False):
        """pass"""

    def execute(self, f, **kwargs):
        """Function called for each item of the stack.
        Warning : 'execute' should not modify attributes.
        """
        if self.nbnook >= 3:
            raise TaskAbort(_('Maximum number of errors reached : %d') % self.nbnook)
        jret  = 2
        skip  = not self.force
        out   = ''
        lenmax = 50
        tail = f
        if len(f) > lenmax + 3:
            tail = '...' + f[len(f) - lenmax:]
        obj = osp.splitext(osp.basename(f))[0]+'.o'
        # ----- skip file if .o more recent than source file
        too_old = True
        if osp.exists(obj):
            too_old = False
            dep_src = [f,]
            for inc in get_include(f):
                deps = self.dep_h.get(inc, [])
                dep_src.extend(deps)
            for ref in dep_src:
                too_old = not is_newer(obj, ref)
                if too_old:
                    break
        if too_old:
            skip = False
        if not skip:
            jret, out = self.run.Shell(self.cmd + ' ' + f)
        return jret, skip, out, f, tail

    def result(self, jret, skip, out, f, tail, **kwargs):
        """Function called after each task to treat results of execute.
        Arguments are 'execute' results + keywords args.
        'result' is called thread-safely, so can store results in attributes.
        """
        if skip:
            self.nskip += 1
            if self.verbose or self.debug:
                self.run.VerbStart(ufmt(_('compiling %s'), tail), verbose=True)
                self.run.VerbIgnore(verbose=True)
        else:
            self.run.VerbStart(ufmt(_('compiling %s'), tail), verbose=True)
            if self.verbose:
                print()
            # ----- avoid to duplicate output
            if not self.verbose:
                if jret == 0 and out.strip() != '' \
                and self.run.get('print_compiler_output', "") in YES_VALUES:
                    print()
                    print(out)
                    self.run.VerbStart(ufmt(_('compiling %s'), tail), verbose=True)
                self.run.VerbEnd(jret, output=out, verbose=True)
            if jret != 0:
                print(out, file=self.fmsg)
                self._mess(ufmt(_('error during compiling %s (see %s)'), f,
                                osp.abspath(self.fmsg.name)),
                        '<E>_COMPIL_ERROR', store=True)
                self.nbnook += 1
            self.codret = max(self.codret, jret)


class AsterBuild_Classic:
    """This class provides functions to build a version of Code_Aster.
    """
    attr = ()

    def __init__(self, run, conf):
        """run   : AsterRun object
        conf : AsterConfig object
        """
        # initialisations
        self.verbose = False
        self.debug = False
        # ----- reference to AsterRun object which manages the execution
        self.run = run
        if run != None and run.__class__.__name__ == 'AsterRun':
            self.verbose = run['verbose']
            self.debug = run['debug']
        # ----- Check if 'conf' is a valid AsterConfig object
        self.conf = conf
        if conf == None or conf.__class__.__name__ != 'AsterConfig':
            self._mess(_('no configuration object provided !'), '<F>_ERROR')
        else:
            # ----- check that AsterConfig fields are correct (not nul !)
            pass
        # ----- Initialize Runner object
        self.runner = Runner(self.conf.get_defines())
        self.runner.set_cpuinfo(1, 1)

    def _mess(self, msg, cod='', store=False):
        """Just print a message
        """
        if hasattr(self.run, 'Mess'):
            self.run.Mess(msg, cod, store)
        else:
            print('%-18s %s' % (cod, msg))

    def support(self, feature):
        """Tell if the feature is supported"""
        return feature in self.attr

    def addFeature(self, feature):
        """Add a supported feature"""
        self.attr = tuple( set(self.attr).union([feature]) )

    def Compil(self, typ, rep, repobj, dbg, rep_trav='',
              error_if_empty=False, numthread=1, dep_h=None):
        """Compile 'rep/*.suffix' files and put '.o' files in 'repobj'
            dbg : debug or nodebug
            (rep can also be a file)
        rep can be remote.
        """
        prev = os.getcwd()
        self.run.DBG('type : %s' % typ, 'rep : %s' % rep, 'repobj : %s' % repobj)

        # ----- how many threads ?
        if numthread == 'auto':
            numthread = self.run.GetCpuInfo('numthread')

        # ----- modified or added includes
        if self.run.IsRemote(rep):
            opt_incl = '-I.'
        elif self.run.IsDir(rep):
            opt_incl = '-I%s' % rep
        else:
            opt_incl = ''

        # ----- get command line from conf object
        defines = []
        for defs in self.conf['DEFS']:
            defines.extend(re.split('[ ,]', defs))
        add_defines = ' '.join(['-D%s' % define for define in defines if define != ''])
        self.run.DBG('Add defines : %s' % add_defines)
        if typ == 'C':
            l_mask = ['*.c']
            if self.conf['CC'][0] == '':
                self._mess(_("C compiler not defined in 'config.txt' (CC)"), \
                        '<F>_CMD_NOT_FOUND')
            cmd = self.conf['CC'][:]
            if dbg == 'debug':
                cmd.extend(self.conf['OPTC_D'])
            else:
                cmd.extend(self.conf['OPTC_O'])
            cmd.append(add_defines)
            cmd.append(opt_incl)
            cmd.extend(self.conf['INCL'])
        elif typ == 'F':
            l_mask = ['*.f']
            if self.conf['F77'][0] == '':
                self._mess(_("Fortran 77 compiler not defined in 'config.txt' (F77)"), \
                        '<F>_CMD_NOT_FOUND')
            cmd = self.conf['F77'][:]
            if dbg == 'debug':
                cmd.extend(self.conf['OPTF_D'])
            else:
                cmd.extend(self.conf['OPTF_O'])
            cmd.append(add_defines)
            cmd.append(opt_incl)
            cmd.extend(self.conf['INCLF'])
        elif typ == 'F90':
            l_mask = ['*.f', '*.F']
            if self.conf['F90'][0] == '':
                self._mess(_("Fortran 90 compiler not defined in 'config.txt' (F90)"), \
                        '<F>_CMD_NOT_FOUND')
            cmd = self.conf['F90'][:]
            if dbg == 'debug':
                cmd.extend(self.conf['OPTF90_D'])
            else:
                cmd.extend(self.conf['OPTF90_O'])
            cmd.append(add_defines)
            cmd.append(opt_incl)
            cmd.extend(self.conf['INCLF90'])
        else:
            self._mess(ufmt(_('unknown type : %s'), typ), '<F>_PROGRAM_ERROR')
        cmd = ' '.join(cmd)

        # ----- if force is True, don't use ctime to skip a file
        force = self.run['force']

        # ----- copy source files if remote
        if self.run.IsRemote(rep):
            if rep_trav == '':
                self._mess(_('rep_trav must be defined'), '<F>_PROGRAM_ERROR')
            obj = osp.join(rep_trav, '__tmp__'+osp.basename(rep))
            iret = self.run.MkDir(obj)
            if self.run.IsDir(rep):
                src = [osp.join(rep, mask) for mask in l_mask + ['*.h']]
            else:
                src = [rep,]
            iret = self.run.Copy(obj, niverr='SILENT', *src)
            rep = obj
        else:
            rep = self.run.PathOnly(rep)

        # ----- check that directories exist
        if not osp.isdir(repobj):
            iret = self.run.MkDir(repobj, verbose=True)

        # ----- work in repobj
        os.chdir(repobj)

        # ----- log file
        msg = osp.basename(rep)+'.msg'
        if osp.exists(msg):
            os.remove(msg)
        fmsg = open(msg, 'w')
        fmsg.write(os.linesep + \
                 'Messages de compilation' + os.linesep + \
                 '=======================' + os.linesep)

        # ----- list of source files
        files = []
        if self.run.IsDir(rep):
            for suffix in l_mask:
                files.extend(glob(osp.join(rep, suffix)))
        elif osp.splitext(rep)[-1] != '.h':
            files.append(rep)
        if len(files) == 0:
            iret = 0
            niverr = ''
            if error_if_empty:
                iret = 2
                niverr = '<A>_NO_SOURCE_FILE'
            self._mess(ufmt(_('no source file in %s'), rep), niverr)
            return iret, []

        # ----- Compile all files in parallel using a Dispatcher object
        task = CompilTask(cmd=cmd, run=self.run, force=force,       # IN
                                verbose=self.verbose, debug=self.debug,   # IN
                                _mess=self._mess, fmsg=fmsg,              # IN
                                dep_h=dep_h,                              # IN
                                codret=0, nskip=0, nbnook=0)              # OUT
        compilation = Dispatcher(files, task, numthread)
        self.run.DBG(compilation.report())

        self._mess(ufmt(_('%4d files compiled from %s'), len(files), rep))
        if task.nskip > 0:
            self._mess(_('%4d files skipped (object more recent than source)') \
                % task.nskip)

        fmsg.close()
        os.chdir(prev)
        return task.codret, files

    def CompilAster(self, REPREF, repdest='', dbg='nodebug', ignore_ferm=False,
                   numthread='auto'):
        """Compile all Aster source files, put '.o' files in 'repdest'/DIR
        and DIR_f with DIR=obj or dbg depends on 'dbg'
        (DIR for "real" source files and DIR_f for fermetur).
        """
        self._mess(_('Compilation of source files'), 'TITLE')
        dest_o = {  'nodebug' : self.conf['BINOBJ_NODBG'][0],
                        'debug'   : self.conf['BINOBJ_DBG'][0]    }
        dest_f_o = {'nodebug' : self.conf['BINOBJF_NODBG'][0],
                        'debug'   : self.conf['BINOBJF_DBG'][0]   }

        # ----- define type and destination of '*.o' files for each directory
        if repdest == '':
            repdest = REPREF
        dest = osp.join(repdest, dest_o[dbg])
        dest_f = osp.join(repdest, dest_f_o[dbg])
        para = {
            self.conf['SRCC'][0]     : ['C', dest],
            self.conf['SRCFOR'][0]   : ['F', dest],
            self.conf['SRCF90'][0]   : ['F90', dest],
        }
        if not ignore_ferm:
            para[self.conf['SRCFERM'][0]] = ['F', dest_f]
        lmods = [d for d in list(para.keys()) if d != '']
        lfull = [osp.join(REPREF, rep) for rep in lmods]

        # ----- check that directories exist
        for obj in lfull:
            if not osp.exists(obj):
                self._mess(ufmt(_('directory does not exist : %s'), obj),
                        '<E>_FILE_NOT_FOUND')
        self.run.CheckOK()

        # ----- nobuild list
        nobuild = []
        for d in self.conf['NOBUILD']:
            nobuild.extend([osp.join(REPREF, d) for d in d.split()])
        # bibf90 dirs automatically added if there is no F90 compiler
        if self.conf['F90'][0] == '' and self.conf['SRCF90'][0] != '':
            nobuild.extend([d for d in \
                glob(osp.join(REPREF, self.conf['SRCF90'][0], '*'))
                if not d in nobuild])
            self._mess(ufmt(_("There is no Fortran 90 compiler in 'config.txt'. " \
                            "All source files from '%s' were ignored."),
                            self.conf['SRCF90'][0]),
                      '<A>_IGNORE_F90', store=True)
        if len(nobuild)>0:
            self._mess(_('These directories will not be built :'))
            for d in nobuild:
                print(' '*10+'>>> %s' % d)

        # ----- compilation
        dep_h = build_include_depend(*lfull)
        iret = 0
        for module in lmods:
            if module != self.conf['SRCFERM'][0]:
                # ----- glob subdirectories
                lrep = glob(osp.join(REPREF, module, '*'))
            else:
                lrep = (osp.join(REPREF, module), )
            for rep in lrep:
                if osp.isdir(rep):
                    tail = '...'+re.sub('^'+REPREF, '', rep)
                    print()
                    jret = 0
                    if not rep in nobuild:
                        self._mess(ufmt(_('Compilation from %s directory'), tail))
                        jret, bid = self.Compil(para[module][0], rep, para[module][1],
                                                dbg, numthread=numthread, dep_h=dep_h)
                    else:
                        self.run.VerbStart(ufmt(_('Directory %s is in NOBUILD list'), tail),
                                           verbose=True)
                        self.run.VerbIgnore(verbose=True)
                    iret = max(iret, jret)

        return iret

    def Archive(self, repobj, lib, force=False):
        """Archive all .o files from 'repobj' into 'lib'
        All args must be local.
        """
        self._mess(_('Archive object files'), 'TITLE')
        prev = os.getcwd()
        # ----- get command line from conf object
        cmd0 = [self.conf['LIB'][0]+' '+lib]

        # ----- check that directories exist
        if not osp.isdir(repobj):
            self._mess(ufmt(_('directory does not exist : %s'), repobj), '<E>_FILE_NOT_FOUND')
        rep = osp.dirname(lib)
        if not osp.isdir(rep):
            iret = self.run.MkDir(rep, verbose=True)
        self.run.CheckOK()

        # ----- if force is True, don't use ctime to skip a file
        force = force or self.run['force']
        if osp.exists(lib):
            mtlib = os.stat(lib).st_mtime
        else:
            mtlib = 0
            force = True

        # ----- work in repobj
        os.chdir(repobj)

        # ----- list of source files
        files = glob('*.o')
        ntot = len(files)
        if ntot == 0:
            self._mess(ufmt(_('no object file in %s'), rep))
            return 0

        # ----- sleep 1 s to be sure than last .o will be older than lib !
        time.sleep(1)

        # ----- use MaxCmdLen to limit command length
        iret = 0
        nskip = 0
        while len(files) > 0:
            cmd = copy.copy(cmd0)
            clen = len(cmd[0])+1
            nadd = 0
            while len(files) > 0 and clen+len(files[0]) < self.run.system.MaxCmdLen-15:
                if not force and is_newer_mtime(mtlib, files[0]):
                    nskip += 1
                    bid = files.pop(0)
                else:
                    clen = clen+len(files[0])+1
                    cmd.append(files.pop(0))
                    nadd += 1
            self.run.VerbStart(_('%4d / %4d objects added to archive...') % \
                    (nadd, ntot), verbose=True)
            if nadd > 0:
                if self.verbose:
                    print()
                jret, out = self.run.Shell(' '.join(cmd))
                # ----- avoid to duplicate output
                if not self.verbose:
                    self.run.VerbEnd(jret, output=out, verbose=True)
                if jret != 0:
                    self._mess(_('error during archiving'), '<E>_ARCHIVE_ERROR')
                iret = max(iret, jret)
            else:
                self.run.VerbIgnore(verbose=True)

        self._mess(_('%4d files archived') % ntot)
        if nskip > 0:
            self._mess(_('%4d files skipped (objects older than library)') \
                % nskip)
        os.chdir(prev)
        return iret

    def Link(self, exe, lobj, libaster, libferm, reptrav):
        """Link a number of object and archive files into an executable.
            exe      : name of the executable to build
            lobj     : list of object files
            libaster : Code_Aster main library
            libferm  : Code_Aster fermetur library
            reptrav  : working directory
        If "python.o" is not in 'lobj' it will be extracted from 'libaster'.
        Other libs are given by AsterConfig object.
        None argument must not be remote !
        """
        self._mess(_('Build Code_Aster executable'), 'TITLE')
        prev = os.getcwd()
        # ----- check that directories exist
        for obj in lobj+[libaster, libferm]:
            if not osp.exists(obj):
                self._mess(ufmt(_('file not found : %s'), obj), '<E>_FILE_NOT_FOUND')
        rep = osp.dirname(exe)
        if not osp.isdir(rep):
            iret = self.run.MkDir(rep, verbose=True)
        self.run.CheckOK()

        # ----- if force is True, don't use ctime to skip a file
        force = self.run['force']
        if not osp.exists(exe):
            force = True
        else:
            for f in lobj + [libaster, libferm]:
                if not is_newer(exe, f):
                    force = True
                    self.run.DBG('%s more recent than %s' % (f, exe))
                    break

        # ----- work in reptrav
        os.chdir(reptrav)

        # ----- python.o in lobj ?
        mainobj = self.conf['BINOBJ_MAIN'][0]
        if mainobj not in [osp.basename(o) for o in lobj] and force:
            # get 'ar' command without arguments, if it's not 'ar' &$#@!
            cmd = [self.conf['LIB'][0].split()[0]]
            cmd.extend(['-xv', libaster, mainobj])
            cmd = ' '.join(cmd)
            self.run.VerbStart(ufmt(_('extracting %s from %s...'), repr(mainobj),
                                    osp.basename(libaster)), verbose=True)
            if self.verbose:
                print()
            iret, out = self.run.Shell(cmd)
            # ----- avoid to duplicate output
            if not self.verbose:
                self.run.VerbEnd(iret, output=out, verbose=True)
            if iret != 0:
                self._mess(ufmt(_('error during extracting %s'), repr(mainobj)),
                        '<F>_LIBRARY_ERROR')
            lobj.insert(0, mainobj)
        else:
            lobj = [o for o in lobj if osp.basename(o) == mainobj] +\
                [o for o in lobj if osp.basename(o) != mainobj]

        # ----- get command line from conf object and args
        cmd = copy.copy(self.conf['LINK'])
        cmd.extend(self.conf['OPTL'])
        cmd.append('-o')
        cmd.append(exe)
        cmd.extend(lobj)
        cmd.append(libaster)
        cmd.extend(self.conf['BIBL'])
        cmd.append(libferm)
        cmd = ' '.join(cmd)

        # ----- run ld or skip this stage
        iret = 0
        tail = osp.join('...', osp.basename(rep), osp.basename(exe))
        self.run.VerbStart(ufmt(_('creating %s...'), tail), verbose=True)
        if force:
            if self.verbose:
                print()
            iret, out = self.run.Shell(cmd)
            self.run.DBG(out, all=True)
            # ----- avoid to duplicate output
            if not self.verbose:
                self.run.VerbEnd(iret, output=out, verbose=True)
            if iret != 0:
                self._mess(_('error during linking'), '<E>_LINK_ERROR')
        else:
            self.run.VerbIgnore(verbose=True)
            self._mess(_('executable more recent than objects and libs ' \
                    'in arguments'))

        os.chdir(prev)
        return iret

    def PrepEnv(self, REPREF, repdest, dbg='nodebug', lang='', **kargs):
        """Prepare 'repdest' with Code_Aster environment from REPREF and
        given arguments in kargs[k] (k in 'exe', 'cmde', 'ele', 'py', 'unigest').
        Note : - REPREF/elements and kargs['ele'] don't exist when building
            elements for the first time.
             - only PYSUPPR entries from 'unigest' are considered here.
        All elements of kargs can be remote.
        """
        reptrav = osp.join(repdest, self.conf['REPPY'][0], '__tmp__')
        prev = os.getcwd()
        # ----- check that files and directories in kargs exist
        self._check_file_args(list(kargs.values()))
        if not osp.isdir(repdest):
            iret = self.run.MkDir(repdest, verbose=True)
        self.run.CheckOK()

        # ----- language
        if lang in ('', 'fr'):
            lang = 'fr'
            suff = ''
        else:
            suff = '_' + lang
        mask_catapy = fmt_catapy % (suff, '*')
        mask_catapy_all = fmt_catapy % ('*', '*')

        # ----- copy REPREF/aster?.exe or kargs['exe']
        iret = 0
        if 'exe' in kargs:
            src = kargs['exe']
        else:
            if dbg == 'debug':
                src = osp.join(REPREF, self.conf['BIN_DBG'][0])
            else:
                src = osp.join(REPREF, self.conf['BIN_NODBG'][0])
        # do not make symlinks if we only prepare the environment because
        # the copy of remote files will be deleted from proxy_dir before the
        # manual execution.
        use_symlink = not kargs.get('only_env', False) and self.run['symlink']
        dest = repdest
        if src != osp.join(repdest, osp.basename(src)):
            if use_symlink and not self.run.IsRemote(src):
                src = self.run.PathOnly(src)
                lien = osp.join(repdest, osp.basename(src))
                iret = self.run.Symlink(src, lien, verbose=True)
            else:
                iret = self.run.Copy(dest, src, verbose=True)
        else:
            self.run.VerbStart(ufmt(_('copying %s...'), src), verbose=True)
            self.run.VerbIgnore(verbose=True)

        # ----- copy REPREF/bibpyt
        self.run.MkDir(osp.join(repdest, self.conf['REPPY'][0], 'Cata'))
        iret = 0
        src  = osp.join(REPREF, self.conf['SRCPY'][0], '*')
        dest = osp.join(repdest, self.conf['REPPY'][0])
        iret = self.run.Copy(dest, src)

        # if 'py' is in kargs
        if 'py' in kargs:
            self._mess(_("copy user's python source files"))
            # ----- python source given by user
            lobj = kargs['py']
            if not type(lobj) in (list, tuple):
                lobj = [lobj, ]
            for occ in lobj:
                obj = occ
                if self.run.IsRemote(occ):
                    obj = reptrav
                    iret = self.run.MkDir(obj)
                    iret = self.run.Copy(obj, occ, verbose=True)
                files = self.run.FindPattern(obj, '*.py', maxdepth=10)

                for f in files:
                    mod, rep = self.GetCModif('py', f)
                    reppydest = osp.join(repdest, self.conf['REPPY'][0], rep)
                    if not self.run.Exists(reppydest):
                        self.run.MkDir(reppydest)
                        self._mess(ufmt(_("unknown package '%s' in %s"),
                            rep, osp.join(REPREF, self.conf['SRCPY'][0])), '<A>_ALARM')
                    dest = osp.join(reppydest, mod+'.py')
                    iret = self.run.Copy(dest, f, verbose=True)

        # ----- apply PYSUPPR directives from unigest
        if 'unigest' in kargs:
            for f in kargs['unigest']['py']:
                self.run.Delete(osp.join(repdest, \
                        re.sub('^'+self.conf['SRCPY'][0], self.conf['REPPY'][0], f)),
                        verbose=True)

        # ----- copy REPREF/commande or kargs['cmde']
        iret = 0
        if 'cmde' in kargs:
            src = kargs['cmde']
        else:
            src = osp.join(REPREF, self.conf['BINCMDE'][0])
        dest = osp.join(repdest, self.conf['REPPY'][0], 'Cata')
        if use_symlink and not self.run.IsRemote(src):
            src = self.run.PathOnly(src)
            # checks catalogue exists
            l_capy = glob(osp.join(src, mask_catapy))
            if len(l_capy) == 0 and lang != '':
                self._mess(ufmt(_("no catalogue found for language '%s', " \
                         "use standard (fr) one..."), lang))
                mask_catapy = fmt_catapy % ('', '*')
                l_capy = glob(osp.join(src, mask_catapy))
            if len(l_capy) == 0:
                self._mess(ufmt(_('no catalogue found : %s'), osp.join(src, mask_catapy)),
                        '<F>_FILE_NOT_FOUND')
            # add symlink
            for f in l_capy:
                root = osp.splitext(fcapy)[0]
                ext  = osp.splitext(f)[-1]
                lien = osp.join(dest, root + ext)
                iret = self.run.Symlink(f, lien, verbose=True)
        else:
            iret = self.run.Copy(dest, osp.join(src, mask_catapy_all), verbose=True)
            # checks catalogue exists
            l_capy = glob(osp.join(dest, mask_catapy))
            if len(l_capy) == 0 and lang != '':
                self._mess(ufmt(_("no catalogue found for language '%s', " \
                         "use standard (fr) one..."), lang))
                mask_catapy = fmt_catapy % ('', '*')
                l_capy = glob(osp.join(dest, mask_catapy))
            for f in l_capy:
                root = osp.splitext(fcapy)[0]
                ext  = osp.splitext(f)[-1]
                self.run.Rename(f, osp.join(dest, root + ext))

        # ----- copy REPREF/elements or kargs['ele']
        iret = 0
        if 'ele' in kargs:
            src = kargs['ele']
        else:
            src = osp.join(REPREF, self.conf['BINELE'][0])
        if self.run.Exists(src) and src != osp.join(repdest, 'elem.1'):
            # symlink not allowed for elem.1 (rw)
            iret = self.run.Copy(osp.join(repdest, 'elem.1'), src, verbose=True)
        else:
            self.run.VerbStart(ufmt(_('copying %s...'), src), verbose=True)
            self.run.VerbIgnore(verbose=True)

        # ----- result directories
        os.chdir(repdest)
        self.run.MkDir('REPE_OUT')

        os.chdir(prev)
        self.run.Delete(reptrav)
        return iret

    def CompilCapy(self, REPREF, reptrav, exe='', cmde='', i18n=False, **kargs):
        """Compile commands catalogue from REPREF/commande using 'exe'
        and puts result in 'cmde'. kargs can contain :
            capy    : list of user's capy files
            unigest : GetUnigest dict with "CATSUPPR catapy module" entries
        All args can be remote.
        If `i18n` is True, translates cata.py.
        """
        self._mess(_('Compilation of commands catalogue'), 'TITLE')
        prev = os.getcwd()
        if exe == '':
            exe = osp.join(REPREF, self.conf['BIN_NODBG'][0])
            if not self.run.Exists(exe):
                exe = osp.join(REPREF, self.conf['BIN_DBG'][0])
        if cmde == '':
            cmde = osp.join(REPREF, self.conf['BINCMDE'][0])
        # ----- check that files and directories in kargs exist
        self._check_file_args(list(kargs.values()))
        if not osp.isdir(cmde):
            iret = self.run.MkDir(cmde, verbose=True)
        if not osp.isdir(reptrav):
            iret = self.run.MkDir(reptrav, verbose=True)
        self.run.CheckOK()

        # ----- work in reptrav
        reptrav = self.runner.set_rep_trav(reptrav)
        os.chdir(reptrav)

        # ----- if force is True, don't use ctime to skip a file
        force = self.run['force']

        # ----- copy capy from REPREF
        bascpy = osp.basename(self.conf['SRCCAPY'][0])
        if osp.exists(bascpy):
            self.run.Delete(bascpy)
        iret = self.run.Copy(bascpy,
                osp.join(REPREF, self.conf['SRCCAPY'][0]), verbose=True)

        # if 'capy' is in kargs
        if 'capy' in kargs:
            force = True
            self._mess(_("copy user's catalogues"))
            # ----- catapy given by user
            lobj = kargs['capy']
            if not type(lobj) in (list, tuple):
                lobj = [lobj, ]
            for occ in lobj:
                obj = occ
                if self.run.IsRemote(occ):
                    obj = osp.join(bascpy,
                                  '__tmp__'+osp.basename(occ))
                    iret = self.run.MkDir(obj)
                    if self.run.IsDir(occ):
                        src = osp.join(occ, '*.capy')
                    else:
                        src = occ
                    iret = self.run.Copy(obj, src)
                    files = glob(osp.join(obj, '*.capy'))
                else:
                    occ = self.run.PathOnly(occ)
                    if self.run.IsDir(occ):
                        files = glob(osp.join(occ, '*.capy'))
                    else:
                        files = [occ, ]
                for f in files:
                    mod, rep = self.GetCModif('capy', f)
                    # because filename is important, remove sha1 digest
                    mod = unique_basename_remove(mod)
                    dest = osp.join(bascpy, rep, mod + '.capy')
                    iret = self.run.Copy(dest, f, verbose=True)
                    if not rep in repcatapy:
                        self._mess(ufmt(_('unknown module name : %s'), rep), '<A>_ALARM')

        # ----- apply CATSUPPR directives from unigest
        if 'unigest' in kargs:
            force = True
            for f in kargs['unigest']['capy']:
                self.run.Delete(osp.join(reptrav, f), verbose=True)

        # ----- build cata.py
        if osp.exists(fcapy):
            self.run.Delete(fcapy)

        # ----- test if compilation can be skipped
        if force or not osp.exists(osp.join(cmde, fcapy)):
            force = True
        else:
            ltest = glob(osp.join(bascpy, '*', '*.capy'))
            for f in ltest:
                if not is_newer(osp.join(cmde, fcapy), f):
                    force = True
                    break

        if not force:
            self.run.VerbStart(_('compilation of commands'), verbose=True)
            self.run.VerbIgnore(verbose=True)
        else:
            fo = open(fcapy, 'w')
            for rep in repcatapy:
                lcapy = glob(osp.join(bascpy, rep, '*.capy'))
                lcapy.sort()
                for capy in lcapy:
                    fo2 = open(capy, 'r')
                    fo.write(fo2.read())
                    fo2.close()
            fo.close()

            # ----- compile cata.py
            dtmp = kargs.copy()
            dtmp['exe'] = exe
            dtmp['cmde'] = reptrav
            if 'py' in kargs:
                dtmp['py'] = kargs['py']
            self.PrepEnv(REPREF, reptrav, **dtmp)

            self.run.VerbStart(_('compilation of commands'), verbose=True)
            cmd_import = """
import sys
sys.path.insert(0, "%s")
iret = 0
try:
    from Cata import cata
    from Cata.cata import JdC
    cr = JdC.report()
    if not cr.estvide() :
        iret = 4
        print ">> Catalogue de commandes : DEBUT RAPPORT"
        print cr
        print ">> Catalogue de commandes : FIN RAPPORT"
except:
    iret = 4
    import traceback
    traceback.print_exc(file=sys.stdout)
sys.exit(iret)
""" % self.conf['REPPY'][0]
            cmd_import_file = osp.join(reptrav, 'cmd_import.py')
            with open(cmd_import_file, 'w') as f:
                f.write(cmd_import)

            if self.verbose:
                print()
            cmd = [osp.join('.', osp.basename(exe))]
            cmd.append(cmd_import_file)
            cmd_exec = self.runner.get_exec_command(' '.join(cmd),
                env=self.conf.get_with_absolute_path('ENV_SH'))
            iret, out = self.run.Shell(cmd_exec)
            # ----- avoid to duplicate output
            if not self.verbose:
                self.run.VerbEnd(iret, output=out, verbose=True)
            if iret != 0:
                self._mess(ufmt(_('error during compiling %s'), fcapy), '<E>_CATAPY_ERROR')
            else:
                kret = self.run.Copy(cmde,
                   osp.join(self.conf['REPPY'][0], 'Cata', fcapy_), verbose=True)
                self._mess(_('Commands catalogue successfully compiled'), 'OK')


            # --- translations...
            if i18n:
                pattern = '#:LANG:%s:LANG_END:'
                old     = pattern % '.*'
                exp     = re.compile(old, re.MULTILINE | re.DOTALL)
                for lang in [l for l in self.conf['I18N'] if not l in ('', 'fr')]:
                    self.run.VerbStart(ufmt(_('working for i18n (language %s)...'), lang),
                                       verbose=True)
                    print()
                    new  = pattern % (os.linesep + "lang = '%s'" % lang + os.linesep + '#')
                    cata_out  = fmt_catapy % ('_' + lang, '')
                    cata_out_ = fmt_catapy % ('_' + lang, '*')
                    tmpl_dict = get_tmpname(self.run, basename='template_dict_%s.py' % lang)
                    # fake aster module
                    with open(osp.join(self.conf['REPPY'][0], 'aster.py'), 'w') as f:
                        f.write("""
# fake aster module
""")
                    sys.path.insert(0, self.conf['REPPY'][0])
                    iret = 0
                    try:
                        from Cata.i18n_cata import i18n_make_cata_fich
                        txt_cata = i18n_make_cata_fich(fichier_dtrans=tmpl_dict, lang=lang)
                        txt_orig = []
                        fo = open(cata_out, 'w')
                        # prendre l'entete
                        for rep in repcatapy[:1]:
                            for capy in glob(osp.join(bascpy, rep, '*.capy')):
                                with open(capy, 'r') as f:
                                    txt0 = f.read()
                                txt2 = exp.sub(new, txt0)
                                fo.write(txt2)
                        # reprendre les imports
                        for rep in repcatapy[1:]:
                            for capy in glob(osp.join(bascpy, rep, '*.capy')):
                                fo.write(get_txt_capy(capy))
                                with open(capy, 'r') as f:
                                    txt_orig.append(f.read())
                        fo.write(os.linesep)
                        fo.write(txt_cata)
                        fo.write(os.linesep)
                        fo.write(os.linesep.join(txt_orig))
                        fo.close()
                    except:
                        iret = 4
                        import traceback
                        traceback.print_exc(file=magic.get_stdout())

                    # ----- avoid to duplicate output
                    if not self.verbose:
                        self.run.VerbEnd(iret, output=out, verbose=True)

                    if iret != 0:
                        self._mess(ufmt(_("error during building %s"), cata_out), '<E>_I18N_ERROR')
                    else:
                        kret = self.run.Copy(cmde, cata_out_, verbose=True)
                        self._mess(ufmt(_('Commands catalogue successfully translated ' \
                                           '(language %s)'), lang), 'OK')

        os.chdir(prev)
        if not kargs.get('keep_reptrav'):
            self.run.Delete(reptrav)
        return iret

    def CompilEle(self, REPREF, reptrav, ele='', **kargs):
        """Compile elements catalogue as 'ele' from cata_ele.pickled.
        kargs must contain arguments for a Code_Aster execution (i.e. for PrepEnv)
        and optionaly :
            cata    : a list of user's elements files
            unigest : GetUnigest dict with "CATSUPPR catalo module" entries
            pickled : use a different cata_ele.pickled (not in REPREF)
            (make_surch_offi needs unigest filename)
        All args can be remote.
        """
        self._mess(_('Compilation of elements catalogue'), 'TITLE')
        required = ('exe', 'cmde')
        if ele == '':
            ele = osp.join(REPREF, self.conf['BINELE'][0])
        pickled = kargs.get("pickled", osp.join(REPREF, self.conf['BINPICKLED'][0]))
        prev = os.getcwd()
        # ----- check for required arguments
        for a in required:
            if a not in kargs:
                self._mess('(CompilEle) '+_('argument %s is required') % a,
                        '<E>_PROGRAM_ERROR')

        # ----- check that files and directories in kargs exist
        self._check_file_args(list(kargs.values()))
        if not osp.isdir(reptrav):
            iret = self.run.MkDir(reptrav, verbose=True)
        self.run.CheckOK()

        # ----- work in repobj
        reptrav = self.runner.set_rep_trav(reptrav)
        os.chdir(reptrav)

        # ----- if force is True, don't use ctime to skip a file
        force = self.run['force']

        # 1. ----- if 'cata' is in kargs
        if 'cata' in kargs:
            force = True
            self._mess(_("copy user's catalogues"))
            fo = open('surch.cata', 'w')
            # ----- catapy given by user
            lobj = kargs['cata']
            if not type(lobj) in (list, tuple):
                lobj = [kargs['cata'], ]
            for occ in lobj:
                obj = occ
                if self.run.IsRemote(occ):
                    obj = osp.join(reptrav, '__tmp__'+osp.basename(occ))
                    iret = self.run.MkDir(obj)
                    if self.run.IsDir(occ):
                        src = osp.join(occ, '*.cata')
                    else:
                        src = occ
                    iret = self.run.Copy(obj, src)
                    files = glob(osp.join(obj, '*.cata'))
                else:
                    occ = self.run.PathOnly(occ)
                    if self.run.IsDir(occ):
                        files = glob(osp.join(occ, '*.cata'))
                    else:
                        files = [occ, ]
                for f in files:
                    fo2 = open(f, 'r')
                    self.run.VerbStart(ufmt(_('adding %s'), f), verbose=True)
                    fo.write(fo2.read())
                    self.run.VerbEnd(iret=0, output='', verbose=True)
                    fo2.close()
            fo.close()

        # 2. ----- compile elements with MAKE_SURCH_OFFI
        self.PrepEnv(REPREF, reptrav, **kargs)
        iret = 0
        cmd = [osp.join('.', osp.basename(kargs['exe']))]
        cmd.append(osp.join(self.conf['REPPY'][0], self.conf['MAKE_SURCH_OFFI'][0]))
        cmd.extend(self.conf['REPPY'])
        cmd.append('MAKE_SURCH')
        cmd.append('surch.cata')
        funig = 'unigest_bidon'
        if 'unigest' in kargs:
            force = True
            funig = kargs['unigest']['filename']
            if self.run.IsRemote(funig):
                funig = 'unigest'
                kret = self.run.Copy(funig, kargs['unigest']['filename'])
            else:
                funig = self.run.PathOnly(funig)
        cmd.append(funig)
        cmd.append(pickled)
        cmd.append('fort.4')
        self.run.VerbStart(ufmt(_('pre-compilation of elements with %s'),
                osp.basename(self.conf['MAKE_SURCH_OFFI'][0])), verbose=True)

        # 2.1. ----- test if compilation can be skipped
        if force or not osp.exists(ele):
            force = True
        else:
            ltest = [pickled, ]
            ltest.extend(glob(osp.join(self.conf['REPPY'][0], '*', '*.py')))
            for f in ltest:
                if not is_newer(ele, f):
                    force = True
                    self.run.DBG('%s more recent than %s' % (f, ele))
                    break

        if not force:
            self.run.VerbIgnore(verbose=True)
        else:
            if self.verbose:
                print()
            cmd_exec = self.runner.get_exec_command(' '.join(cmd),
                env=self.conf.get_with_absolute_path('ENV_SH'))
            jret, out = self.run.Shell(cmd_exec)
            # ----- avoid to duplicate output
            if not self.verbose:
                self.run.VerbEnd(jret, output=out, verbose=True)
            if jret != 0:
                self._mess(_('error during pre-compilation of elements'),
                        '<F>_CATAELE_ERROR')

        # 3. ----- build elem.1 with kargs['exe']
        cmd = [osp.join('.', osp.basename(kargs['exe']))]
        cmd.append(osp.join(self.conf['REPPY'][0], self.conf['ARGPYT'][0]))
        cmd.extend(self.conf['ARGEXE'])
        # <512 for 32 bits builds
        cmd.append('-commandes fort.1 -memjeveux 500 -tpmax 120')
        fo = open('fort.1', 'w')
        fo.write("""
# COMPILATION DU CATALOGUE D'ELEMENT
DEBUT ( CATALOGUE = _F( FICHIER = 'CATAELEM' , UNITE = 4 ))
MAJ_CATA ( ELEMENT = _F())
FIN()
""")
        fo.close()
        self.run.VerbStart(ufmt(_('compilation of elements with %s'), kargs['exe']), verbose=True)

        jret = 0
        if not force:
            self.run.VerbIgnore(verbose=True)
        else:
            if self.verbose:
                print()
            cmd_exec = self.runner.get_exec_command(' '.join(cmd),
                env=self.conf.get_with_absolute_path('ENV_SH'))
            jret, out = self.run.Shell(cmd_exec)
            # ----- diagnostic of Code_Aster execution
            diag = self.getDiag()[0]
            if self.run.GetGrav(diag) < self.run.GetGrav('<S>') \
             and osp.exists('elem.1'):
                pass
            else:
                jret = 4
            # ----- avoid to duplicate output
            if not self.verbose:
                self.run.VerbEnd(jret, output=out, verbose=True)
            if jret == 0:
                self._mess(_('Elements catalogue successfully compiled'), diag)
            else:
                self.run.DoNotDelete(reptrav)
                print(_(' To re-run compilation manually :'))
                print(' cd %s' % reptrav)
                print(' ', cmd_exec)
                self._mess(_('error during compilation of elements'),
                        '<F>_CATAELE_ERROR')

            # 4. ----- copy elements to 'ele'
            iret = self.run.Copy(ele, 'elem.1', verbose=True)

        os.chdir(prev)
        self.run.Delete(reptrav)
        return iret

    def MakePickled(self, REPREF, reptrav, repdest='', **kargs):
        """Make 'repdest'/cata_ele.pickled.
        kargs can contain :
            exe     : Code_Aster executable or Python interpreter (can be remote)
        """
        self._mess(_('Prepare cata_ele.pickled'), 'TITLE')
        if repdest == '':
            repdest = REPREF
        prev = os.getcwd()
        # ----- check if reptrav exists
        if not osp.isdir(reptrav):
            iret = self.run.MkDir(reptrav, verbose=True)

        # ----- work in repobj
        reptrav = self.runner.set_rep_trav(reptrav)
        os.chdir(reptrav)

        # ----- if force is True, don't use ctime to skip a file
        force = self.run['force']

        # ----- use REPREF/aster?.exe or kargs['exe']
        iret = 0
        if 'exe' in kargs:
            exe = kargs['exe']
            if self.run.IsRemote(exe):
                kret = self.run.Copy(reptrav, exe)
                exe = osp.join(reptrav, osp.basename(exe))
            else:
                exe = self.run.PathOnly(exe)
        else:
            exe = osp.join(REPREF, self.conf['BIN_NODBG'][0])
            if not self.run.Exists(exe):
                exe = osp.join(REPREF, self.conf['BIN_DBG'][0])

        # ----- call MAKE_CAPY_OFFI
        cmd = [exe, ]
        cmd.append(osp.join(REPREF, self.conf['SRCPY'][0], self.conf['MAKE_CAPY_OFFI'][0]))
        cmd.append(osp.join(REPREF, self.conf['SRCPY'][0]))
        cmd.append('TRAV_PICKLED')
        cmd.append(osp.join(REPREF, self.conf['SRCCATA'][0]))
        cata_pickled = osp.basename(self.conf['BINPICKLED'][0])
        cmd.append(cata_pickled)

        # ----- test if compilation can be skipped
        if not osp.exists(osp.join(repdest, self.conf['BINPICKLED'][0])):
            force = True
        else:
            ltest = glob(osp.join(REPREF, self.conf['SRCCATA'][0], '*', '*.cata'))
            ltest.extend(glob(osp.join(REPREF, self.conf['SRCPY'][0], '*', '*.py')))
            for f in ltest:
                if not is_newer(osp.join(repdest, self.conf['BINPICKLED'][0]), f):
                    force = True
                    break

        self.run.VerbStart(ufmt(_('build cata_ele.pickled with %s'),
                osp.basename(self.conf['MAKE_CAPY_OFFI'][0])), verbose=True)

        if not force:
            self.run.VerbIgnore(verbose=True)
        else:
            if self.verbose:
                print()
            cmd_exec = self.runner.get_exec_command(' '.join(cmd),
                env=self.conf.get_with_absolute_path('ENV_SH'))
            jret, out = self.run.Shell(cmd_exec)
            # ----- avoid to duplicate output
            if not self.verbose:
                self.run.VerbEnd(jret, output=out, verbose=True)
            if jret == 0 and osp.exists(cata_pickled):
                self._mess(_('cata_ele.pickled successfully created'), 'OK')
            else:
                self._mess(_('error during making cata_ele.pickled'),
                        '<F>_PICKLED_ERROR')

            # ----- copy cata_ele.pickled to 'repdest'
            iret = self.run.Copy(osp.join(repdest, self.conf['BINPICKLED'][0]),
                                        cata_pickled, verbose=True)

        os.chdir(prev)
        self.run.Delete(reptrav)
        return iret

    def GetUnigest(self, funig):
        """Build a dict of the file names by parsing unigest file 'funig' where
        the keys are 'f', 'f90', 'c', 'py', 'capy', 'cata', 'test' and 'fdepl'.
        funig can be remote.
        """
        dico = {}
        # ----- check that file exists
        if not self.run.Exists(funig):
            self._mess(ufmt(_('file not found : %s'), funig), '<A>_ALARM')
            return dico
        # ----- copy funig if it's a remote file
        if self.run.IsRemote(funig):
            name = '__tmp__.unigest'
            kret = self.run.Copy(name, funig)
        else:
            name = self.run.PathOnly(funig)

        dico = unigest2dict(name, self.conf)
        return dico

    def getDiag(self, err='fort.9', resu='fort.8', mess='fort.6',
                cas_test=False):
        """Return the diagnostic after a Code_Aster execution
        as a list : [diag, tcpu, tsys, ttotal, telapsed]
            err   : error file
            resu  : result file (None = ignored)
            mess  : messages file (None = ignored)
        """
        run = self.run
        diag, tcpu, tsys, ttot, telap = '<F>_ABNORMAL_ABORT', 0., 0., 0., 0.

        # 1. ----- parse error file
        diag2, stop = _diag_erre(err)
        run.DBG('Fichier : %s' % err, '_diag_erre : %s' % diag2)
        diag = diag2 or diag
        if stop:
            run.ASSERT(diag != None)
        else:
            # if .erre doesn't exist, do the same analysis with .resu
            if diag2 is None:
                diag2, stop = _diag_erre(resu)
                run.DBG('Fichier : %s' % resu, '_diag_erre : %s' % diag2)
                diag = diag2 or diag

            if stop:
                run.ASSERT(diag != None)
            else:
                # 2. ----- parse result and mess files
                diag, tcpu, tsys, ttot, telap = _diag_resu(resu, cas_test=cas_test)
                run.DBG('Fichier : %s' % resu, '_diag_resu : %s' % diag)
                diag2, stop2 = _diag_erre(mess, mess=True)
                run.DBG('Fichier : %s' % mess, '_diag_erre : %s' % diag2)
                if diag and diag2 and run.GetGrav(diag2) > run.GetGrav(diag):
                    diag = diag2
                # if resu doesn't exist, trying with .mess
                if diag is None or diag.startswith('<S>'):
                    diag = _diag_mess(mess) or 'NO_RESU_FILE'
                    run.DBG('Fichier : %s' % mess, '_diag_mess : %s' % diag)

        return diag, tcpu, tsys, ttot, telap

    def GetCModif(self, typ, fich):
        """Retourne, pour `typ` = 'capy'/'py', le nom du module et du package.
        `fich` est local.
        """
        para = {
            'capy'   : { 'comment' : '#&', 'nmin' : 3 },
            'py'     : { 'comment' : '#@', 'nmin' : 4 },
        }
        if typ not in list(para.keys()):
            self._mess(ufmt(_('invalid type : %s'), typ), '<F>_PROGRAM_ERROR')

        with open(fich, 'r') as f:
            lig = f.readline().split()
        if len(lig) < para[typ]['nmin'] or \
        (len(lig) > 0 and lig[0] != para[typ]['comment']):
            self._mess(ufmt(_("invalid first line of file : %s\n" \
                      "      Should start with '%s' and have at least %s fields"),
                            osp.basename(fich), para[typ]['comment'], para[typ]['nmin']),
                       '<F>_INVALID_FILE')

        if typ == 'py':
            mod = lig[2]
            rep = lig[3]
        elif typ == 'capy':
            mod = osp.splitext(osp.basename(fich))[0]
            rep = lig[2].lower()

        return mod, rep


    def _check_file_args(self, args):
        """Check that files and directories in arguments exist."""
        if type(args) not in (list, tuple):
            args = [args, ]
        for occ in args:
            obj = occ
            if not type(occ) in (list, tuple):
                obj = [occ,]
            for rep in obj:
                if type(rep) not in (str, str):
                    continue
                if not self.run.Exists(rep):
                    self._mess(ufmt(_('path does not exist : %s'), rep),
                        '<E>_FILE_NOT_FOUND')

class AsterBuild_CataZip(AsterBuild_Classic):

    def CompilCapy(self, REPREF, reptrav, exe='', cmde='', i18n=False, **kargs):
        """Also build the zipped catalogue."""
        kargs['keep_reptrav'] = True
        iret = AsterBuild_Classic.CompilCapy(self, REPREF, reptrav, exe, cmde, i18n, **kargs)
        if iret != 0:
            return iret
        prev = os.getcwd()
        reptrav = self.runner.set_rep_trav(reptrav)
        os.chdir(osp.join(reptrav, self.conf['REPPY'][0]))
        name = osp.join(osp.dirname(cmde), self.conf['BINCMDE_ZIP'][0])
        zip = ZipFile(name, 'w')
        for fname in ('__init__.py', 'cata.py', 'ops.py'):
            zip.write(osp.join('Cata', fname))
        zip.close()
        os.chdir(prev)
        self.run.Delete(reptrav)
        return iret

class AsterBuildInstalled(AsterBuild_Classic):
    """For a version installed by waf:
    - do not copy the executable,
    - do not copy bibpyt, Cata is already available in PYTHONPATH
    """
    attr = ('waf', )

    def PrepEnv(self, REPREF, repdest, dbg='nodebug', lang='', **kargs):
        """Prepare 'repdest' with Code_Aster environment from REPREF and
        given arguments in kargs[k] (k in 'exe', 'cmde', 'ele', 'py', 'unigest').
        Note : - REPREF/elements and kargs['ele'] don't exist when building
            elements for the first time.
        All elements of kargs can be remote.
        """
        prev = os.getcwd()
        if not osp.isdir(repdest):
            iret = self.run.MkDir(repdest, verbose=True)
        self.run.CheckOK()

        # ----- copy REPREF/elements or kargs['ele']
        iret = 0
        if 'ele' in kargs:
            src = kargs['ele']
        else:
            src = osp.join(REPREF, self.conf['BINELE'][0])
        if self.run.Exists(src) and src != osp.join(repdest, 'elem.1'):
            # symlink not allowed for elem.1 (rw)
            iret = self.run.Copy(osp.join(repdest, 'elem.1'), src, verbose=True)
            make_writable(osp.join(repdest, 'elem.1'))
        else:
            self.run.VerbStart(ufmt(_('copying %s...'), src), verbose=True)
            self.run.VerbIgnore(verbose=True)

        # ----- result directories
        os.chdir(repdest)
        self.run.MkDir('REPE_OUT')

        os.chdir(prev)
        return iret

class AsterBuildInstalledNoCopy(AsterBuild_Classic):
    """For a version installed by waf and with enhancements to directly use the
    installation directory with no copy.
    The elements catalog is found using the ASTER_ELEMENTSDIR environment
    variable, Cata is already available in PYTHONPATH.
    """
    attr = ('waf', 'nocopy')

    def PrepEnv(self, REPREF, repdest, dbg='nodebug', lang='', **kargs):
        """Prepare 'repdest' with Code_Aster environment from REPREF"""
        iret = 0
        prev = os.getcwd()
        if not osp.isdir(repdest):
            iret = self.run.MkDir(repdest, verbose=True)
        self.run.CheckOK()

        # ----- result directories
        os.chdir(repdest)
        self.run.MkDir('REPE_OUT')

        os.chdir(prev)
        return iret

class AsterBuildInstalledNoResu(AsterBuildInstalledNoCopy):
    """For a version installed by waf, with enhancements to directly use the
    installation directory with no copy.
    This version does not create '.resu' file.
    """
    attr = ('waf', 'nocopy', 'noresu')

    def getDiag(self, mess='fort.6', cas_test=False, **kwargs):
        """Return the diagnostic after a Code_Aster execution
        as a list : [diag, tcpu, tsys, ttotal, telapsed]
            mess  : messages file (None = ignored)
        """
        return AsterBuildInstalledNoCopy.getDiag(self, mess, mess, mess,
                                                 cas_test)

class AsterBuildInstalledNoSuperv(AsterBuildInstalledNoCopy):
    """For a version installed by waf, with enhancements to directly use the
    installation directory with no copy, and without the Python supervisor.
    """
    attr = ('waf', 'nocopy', 'nosuperv')


class AsterBuildInstalledNoSupervNoResu(AsterBuildInstalledNoResu):
    """For a version installed by waf, with enhancements to directly use the
    installation directory with no copy, and without the Python supervisor.
    This version does not create '.resu' file.
    """
    attr = ('waf', 'nocopy', 'noresu', 'nosuperv')


def AsterBuild(run, conf):
    """Return the relevant AsterBuild_xxx implementation depending on
    parameters of the AsterConfig object."""
    klass = AsterBuild_Classic
    if 'nosuperv' in conf['BUILD_TYPE'][0]:
        if 'noresu' in conf['BUILD_TYPE'][0]:
            klass = AsterBuildInstalledNoSupervNoResu
        else:
            klass = AsterBuildInstalledNoSuperv
    elif 'noresu' in conf['BUILD_TYPE'][0]:
        klass = AsterBuildInstalledNoResu
    elif 'nocopy' in conf['BUILD_TYPE'][0]:
        klass = AsterBuildInstalledNoCopy
    elif 'waf' in conf['BUILD_TYPE'][0]:
        klass = AsterBuildInstalled
    elif conf['BINCMDE_ZIP'][0] != '':
        klass = AsterBuild_CataZip
    builder = klass(run, conf)
    # add extras features (better than check the version)
    for feature in ('use_numthreads', 'orbinitref', 'container'):
        if feature in conf['BUILD_TYPE'][0]:
            builder.addFeature(feature)
    run.DBG("version supports: {0}".format(builder.attr))
    return builder


def get_txt_capy(capy):
    """On utilise le fait qu'il n'y a rien après la définition de l'OPER, PROC ou MACRO.
    """
    with open(capy, 'r') as f:
        txt = f.read()
    expr = re.compile('^[A-Za-z_0-9]+ *= *[OPERPROCMACROFORM]+ *\(.*',
                            re.MULTILINE | re.DOTALL)
    sans_op = expr.sub('', txt)
    keep = ['']
    for line in sans_op.splitlines():
        if not re.search('^ *#', line):
            keep.append(line)
    keep.append('')
    return os.linesep.join(keep)

_no_convergence_exceptions = (
    'NonConvergenceError', 'EchecComportementError', 'PilotageError',
)
_contact_exceptions = (
    'TraitementContactError', 'MatriceContactSinguliereError',
    'BoucleGeometrieError', 'BoucleFrottementError', 'BoucleContactError',
    'CollisionError', 'InterpenetrationError',
)

def _diag_erre(err, mess=False):
    """Diagnostic à partir du fichier '.erre'.
    Si le fichier n'existe pas, on retourne (None, False).
    Pour un fichier de message, 'ARRET NORMAL DANS FIN' est absent, donc on ne
    peut pas déterminer 'ok'.
    """
    run = magic.run
    diag = None
    stop = False
    if err is None or not os.access(err, os.R_OK):
        pass
    else:
        with open(err, 'rb') as f:
            txt = to_unicode(f.read())

        n_debut = re_search(txt, string="-- CODE_ASTER -- VERSION", result='number')
        n_fin   = re_search(txt,
                string="""<I> <FIN> ARRET NORMAL DANS "FIN" PAR APPEL A "JEFINI".""",
                result='number', flag=re.IGNORECASE)

        alarm = re_search(txt, pattern='^ *. *%s', string='<A>')
        fatal = re_search(txt, pattern='^ *. *%s', string='<F>')
        exitcode = re_search(txt, pattern='^ *%s_EXIT_CODE = ([0-9]+)',
                             string='<I>', result='value')
        exitcode = exitcode and int(exitcode[0]) or 0

        if fatal:
            expir = re_search(txt, pattern='^ *. *%s',
                    string='<F> <INIAST> VERSION EXPIREE', flag=re.IGNORECASE)
            superv = re_search(txt, pattern='^ *. *%s',
                    string='<F> <SUPERVISEUR> ARRET SUR ERREUR(S) UTILISATEUR',
                    flag=re.IGNORECASE)
        else:
            expir = superv = False

        errs = re_search(txt, pattern='^ *. *%s', string='<S>')

        if errs:
            mem = re_search(txt, string='MEMOIRE INSUFFISANTE POUR ALLOUER', flag=re.IGNORECASE)
            arretcpu = re_search(txt, string='ARRET PAR MANQUE DE TEMPS', flag=re.IGNORECASE) \
                 or re_search(txt, pattern='<%s>', string='ArretCPUError') \
                 or re_search(txt, string='timelimit expired', flag=re.IGNORECASE)
            nonconverg = max([re_search(txt, pattern='<%s>', string=exc) \
                              for exc in _no_convergence_exceptions])
            contact = max([re_search(txt, pattern='<%s>', string=exc) \
                              for exc in _contact_exceptions])
        else:
            mem = arretcpu = nonconverg = contact = False

        ok = (n_debut == n_fin and n_fin > 0) or mess
        run.DBG('n_debut=%s, n_fin=%s, mess=%s : ok=%s' % (n_debut, n_fin, mess, ok))
        run.DBG('alarm=%s, errs=%s, fatal=%s, exitcode=%s' % (alarm, errs, fatal, exitcode))
        if ok:
            diag = 'OK'
            if alarm:
                diag = '<A>_ALARM'
            if exitcode != 0:
                errs = True
        # "S" (recoverable) error
        if errs:
            diag = '<S>_ERROR'
            if arretcpu:
                diag = '<S>_CPU_LIMIT'
            elif nonconverg:
                diag = '<S>_NO_CONVERGENCE'
            elif contact:
                diag = '<S>_CONTACT_ERROR'
            elif mem:
                diag = '<S>_MEMORY_ERROR'
        # fatal error
        if fatal:
            diag = '<F>_ERROR'
            if superv:
                diag = '<F>_SUPERVISOR'
            elif expir:
                diag = '<F>_EXPIRED_VERS'
        if not ok or fatal or errs:
            stop = True

    return diag, stop


def _diag_resu(resu, cas_test):
    """Diagnostic à partir du fichier '.resu'.
    """
    diag, tcpu, tsys, ttot, telap = None, 0., 0., 0., 0.
    # 2. ----- parse result file
    if resu is None or not os.access(resu, os.R_OK):
        pass
    else:
        # OK / NOOK
        ok = False
        nook = False
        # <A>_ALARME
        alarm = False
        diag0 = diag

        with open(resu, 'rb') as f:
            txt = to_unicode(f.read())
        ok = re_search(txt, pattern='^ *OK +')
        nook = re_search(txt, pattern='^ *NOOK +')
        alarm = re_search(txt, pattern='^ *. *%s', string='<A>')

        value = re_search(txt, result='value',
                pattern='TOTAL_JOB +: +([0-9\.]+) +: +([0-9\.]+) +: +([0-9\.]+) +: +([0-9\.]+)')
        if len(value) > 0:
            tcpu, tsys, ttot, telap = [float(v) for v in value[0]]

        if nook:
            diag0 = 'NOOK_TEST_RESU'
        else:
            if cas_test and not ok:
                diag0 = 'NO_TEST_RESU'
            else:
                diag0 = 'OK'
                if alarm:
                    diag0 = '<A>_ALARM'
        diag = diag0

    return diag, tcpu, tsys, ttot, telap


def _diag_mess(mess):
    """Essaie de trouver des pistes supplémentaires si le .mess existe.
    """
    diag = None
    if mess is None or not osp.isfile(mess):
        pass
    else:
        with open(mess, 'rb') as f:
            txt = to_unicode(f.read())
        syntax = re_search(txt, string="ERREUR A LA VERIFICATION SYNTAXIQUE") or \
                    re_search(txt, pattern="ERREUR .*ACCAS")
        if syntax:
            diag = '<F>_SYNTAX_ERROR'

        else:
            # recherche de la levée non récupérée d'exception
            arretcpu = re_search(txt, pattern='<%s>', string='ArretCPUError') \
                 or re_search(txt, string='timelimit expired', flag=re.IGNORECASE)
            if arretcpu:
                diag = '<S>_CPU_LIMIT'

    return diag


def unigest2dict(funig, conf, with_fordepla=False):
    """Build a dict of the file names by parsing unigest file 'funig' where
    the keys are 'f', 'f90', 'c', 'py', 'capy', 'cata', 'test' and 'fdepl'.
    funig can be remote.
    """
    repref = { 'bibfor' : 'f', 'bibf90' : 'f90', 'bibc' : 'c', 'bibpyt' : 'py',
              'catapy' : 'capy', 'catalo' : 'cata', 'astest' : 'test' }
    dico = {}
    for cat in ('f', 'f90', 'c', 'py', 'capy', 'cata', 'test', 'fdepl'):
        dico[cat] = []

    # ----- keep a reference to the file for CompilEle
    dico['filename'] = funig
    assert osp.exists(funig), 'file not found : %s' % funig

    # parse unigest
    fo = open(funig, 'r')
    for line in fo:
        # new syntax : SUPPR bibfor/algeline/zzzzzz.f
        mat = re.search('^ *SUPPR +([^\s]+)', line)
        if mat:
            path = mat.group(1).strip()
            mod = split_path(path)[0]
            key = repref.get(mod)
            if key:
                if key == 'test' and osp.splitext(path)[-1] in ('', '.comm'):
                    path = osp.splitext(path)[0] + '.*'
                # force use of native separator
                path = osp.join(*split_path(path))
                dico[key].append(path)

        mat = re.search('^ *FORSUPPR +([-_a-zA-Z0-9]+) +([-_a-zA-Z0-9]+)', line)
        if mat:
            nam = mat.group(1).lower()+'.f'
            mod = mat.group(2).lower()
            dico['f'].append(osp.join(conf['SRCFOR'][0], mod, nam))

        mat = re.search('^ *F90SUPPR +([-_a-zA-Z0-9]+) +([-_a-zA-Z0-9]+)', line)
        if mat:
            nam = mat.group(1).lower()+'.F'
            mod = mat.group(2).lower()
            dico['f90'].append(osp.join(conf['SRCF90'][0], mod, nam))

        mat = re.search('^ *CSUPPR +([-_a-zA-Z0-9]+) +([-_a-zA-Z0-9]+)', line)
        if mat:
            nam = mat.group(1).lower()+'.c'
            mod = mat.group(2).lower()
            dico['c'].append(osp.join(conf['SRCC'][0], mod, nam))

        mat = re.search('^ *PYSUPPR +([-_a-zA-Z0-9]+) +([-_a-zA-Z0-9]+)', line)
        if mat:
            nam = mat.group(1)+'.py'
            mod = mat.group(2)
            dico['py'].append(osp.join(conf['SRCPY'][0], mod, nam))

        mat = re.search('^ *CATSUPPR +([-_a-zA-Z0-9]+) +([-_a-zA-Z0-9]+)', line)
        if mat:
            nam = mat.group(1).lower()
            mod = mat.group(2).lower()
            if mod in repcatapy:
                dico['capy'].append(osp.join(conf['SRCCAPY'][0], mod, nam+'.capy'))
            elif mod in repcatalo:
                dico['cata'].append(osp.join(conf['SRCCATA'][0], mod, nam+'.cata'))
            else:
                print('<A>_ALARM', ufmt(_('unknown type %s in unigest file'), mod), end=' ')

        mat = re.search('^ *TESSUPPR +([-_a-zA-Z0-9\.]+)', line)
        if mat:
            nam = mat.group(1).lower()
            ext = osp.splitext(nam)[-1]
            if ext in ('', '.comm'):
                nam = osp.splitext(nam)[0] + '.*'
            dico['test'].extend([osp.join(dtest, nam) for dtest in conf['SRCTEST']])

        mat = re.search('^ *FORDEPLA +([-_a-zA-Z0-9]+) +([-_a-zA-Z0-9]+)' \
                ' +([-_a-zA-Z0-9]+)', line)
        if mat:
            nam = mat.group(1).lower()+'.f'
            old = mat.group(2).lower()
            new = mat.group(3).lower()
            if with_fordepla:
                dico['fdepl'].append([osp.join(conf['SRCFOR'][0], old, nam),
                        osp.join(conf['SRCFOR'][0], new, nam)])
            else:
                dico['f'].append(osp.join(conf['SRCFOR'][0], old, nam))
    fo.close()
    return dico

def glob_unigest(dico, repref):
    """Expand paths relatively to `repref`."""
    prev = os.getcwd()
    os.chdir(repref)
    dico = dico.copy()
    for key, values in list(dico.items()):
        if key == 'filename':
            continue
        new = []
        for path in values:
            new.extend(glob(path))
        dico[key] = new
    os.chdir(prev)
    return dico

def get_include(src):
    """Returns include files in the given source."""
    code = open(src, 'r').read()
    linc = re.findall('^\#include *[\"\<]{1}(.*)[\"\>]{1}', code, re.MULTILINE)
    return linc


def build_include_depend(*dirs):
    """Build a tree of dependencies between include files."""
    linc = []
    for dirsrc in dirs:
        for base, l_dirs, l_nondirs in os.walk(dirsrc):
            linc.extend(glob(osp.join(base, "*.h")))
    wrk = {}
    for inc in linc:
        wrk[inc] = set()
        code = open(inc, 'r').read()
        for other in linc:
            if inc == other:
                continue
            mat = re.search('^\#include.*%s' % osp.basename(other), code, re.MULTILINE)
            if mat:
                wrk[inc].add(other)
    new = -1
    while new != 0:
        new = 0
        for inc in linc:
            n0 = len(wrk[inc])
            for other in linc:
                if other in wrk[inc]:
                    wrk[inc].update(wrk[other])
            new = new + len(wrk[inc]) - n0
    dep = {}
    for key, val in list(wrk.items()):
        dep[osp.basename(key)] = list(val)
    return dep

ASTER_BUILD = bwc_deprecate_class('ASTER_BUILD', AsterBuild)
