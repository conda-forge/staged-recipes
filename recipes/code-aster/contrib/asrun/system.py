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
Definition of AsterSystem class.
"""


import os
import os.path as osp
import sys
import re
import glob

from asrun.common.i18n import _
from asrun.mystring import convert, to_unicode, ufmt
from asrun.system_command import COMMAND as command
from asrun.common.utils import get_tmpname_base, get_encoding, now
from asrun.common.sysutils import (
    FileName,
    on_linux,
    on_mac,
    on_windows,
    on_64bits,
    local_user,
    local_full_host,
    local_host,
    get_hostname,
)
from asrun.common_func import is_localhost2
from asrun.core import magic

from asrun.backward_compatibility import bwc_deprecate_class

# colors and tty...
label = { 'OK' : '  OK  ', 'FAILED' : 'FAILED', 'SKIP' : ' SKIP ' }
if on_linux() and hasattr(magic.get_stdout(), "isatty") and magic.get_stdout().isatty():
    label['OK']     = '\033[1;32m%s\033[m\017' % label['OK']
    label['FAILED'] = '\033[1;31m%s\033[m\017' % label['FAILED']
#   label['SKIP']   = '\033[1;34m%s\033[m\017' % label['SKIP']
for k in label:
    label[k] = '['+label[k]+']'


shell_cmd = command["shell_cmd"]


def _exitcode(status, default=99):
    """Extract the exit code from status. Return 'default' if the process
    has not been terminated by exit.
    """
    if os.WIFEXITED(status):
        iret = os.WEXITSTATUS(status)
    elif os.WIFSIGNALED(status):
        iret = os.WTERMSIG(status)
    elif os.WIFSTOPPED(status):
        iret = os.WSTOPSIG(status)
    else:
        iret = default
    return iret


_command_id = 0
def get_command_id():
    """Return a unique identifier for command started by 'local_shell'.
    """
    global _command_id
    _command_id += 1
    return '%d_%08d' % (os.getpid(), _command_id)


def env2dict(s):
    """Convert output to a dictionnary."""
    l = s.split(os.linesep)
    d = {}
    for line in l:
        mat = re.search('^([-a-zA-Z_0-9@\+]+)=(.*$)', line)
        if mat != None:
            d[mat.group(1)] = mat.group(2)
    return d


def get_command_line(cmd_in, bg, follow_output, separated_stderr,
                     output_filename, error_filename, var_exitcode):
    """Returns the command to run to redirect output/error, retreive exit code
    """
    values = {
        'cmd' : cmd_in,
        'output' : output_filename,
        'error' : error_filename,
        'var' : var_exitcode,
    }
    if bg:
        # new_cmd = cmd + ' &' => NO : stdout/stderr must be closed not to block
        new_cmd = command['background'] % values
    elif follow_output:
        if not separated_stderr:
            new_cmd = command['follow_with_stderr'] % values
        else:
            new_cmd = command['follow_separ_stderr'] % values
    else:
        if not separated_stderr:
            new_cmd = command['not_follow_with_stderr'] % values
        else:
            new_cmd = command['not_follow_separ_stderr'] % values
    #print(u"Command :", new_cmd)
    # may happen if tmpdir has been deleted before another one, just before exit.
    if not osp.isdir(osp.dirname(output_filename)):
        new_cmd = command['foreground'] % values
    return new_cmd


def get_system_tmpdir():
    """Returns a directory for temporary files
    """
    var = os.environ.get("ASTER_TMPDIR") or os.environ.get("TMPDIR") \
       or os.environ.get('TEMP') or os.environ.get('TMP')
    if var:
        return var
    if on_linux():
        return "/tmp"
    else:
        return osp.join(os.environ.get("%systemroot%", "c:\\windows"), "temp")


def split_path(path):
    """Split a path using platform 'os.path.sep',
    but try "/", "\\" if no 'sep' was found.
    """
    splitted = path.split(osp.sep)
    if len(splitted) == 1:
        splitted = splitted[0].split('/')
    if len(splitted) == 1:
        splitted = splitted[0].split('\\')
    return splitted



class AsterSystem:
    """Class to encapsultate "system" commands on local or remote machine.
    Available methods :
        'Copy', 'Shell', 'IsRemote', 'MkDir', 'Delete', 'Exists', 'IsDir',
        'Gzip', 'Gunzip', 'AddToEnv', 'GetHostName', 'PathOnly', 'Rename',
        'VerbStart, 'VerbEnd', 'VerbIgnore', 'SetLimit', 'Which',
        'GetCpuInfo', 'FindPattern', 'Symlink'
    Supported protocols :
    - for copy :
        LOCAL, RCP, SCP, RSYNC, HTTP
    - for shell execution :
        LOCAL, RSH, SSH
    """
    # this values must be set during installation step.
    MaxCmdLen = 32768
    MultiThreading = sys.version_info >= (2, 5)
    # line length -9
    _LineLen = 80-9
    # required parameters for initialisation
    RequiredParam = ['remote_copy_protocol', 'remote_shell_protocol']

    def __init__(self, run, **kargs):
        """run : AsterRun object
        OR just a dictionnary to define 'RequiredParam' + 'verbose', 'debug'
        """
        self.verbose = run['verbose']
        self.debug = run['debug']
        self._tmpdir = get_system_tmpdir()
        # ----- fill param
        self.param = {}
        for key in self.RequiredParam:
            self.param[key] = run[key]
        # ----- reference to AsterRun object which manages the execution
        self.run = run
        # ----- check if protocols are supported
        if not self.param['remote_shell_protocol'] in ('LOCAL', 'RSH', 'SSH'):
            self.param['remote_shell_protocol'] = 'SSH'
        if not self.param['remote_copy_protocol'] in ('LOCAL', 'RCP', 'SCP', 'RSYNC', 'HTTP'):
            self.param['remote_copy_protocol'] = 'SCP'
        self._dbg('AsterSystem param :', self.param)
        # ----- cache cpuinfo, meminfo
        self._cpuinfo_cache = {}
        self._meminfo_cache = {}
        # ----- check for shared folders (never use remote copy for them)
        self.shared_folders = []
        if self.run.get('shared_folders'):
            self.shared_folders = [rep.strip() \
                        for rep in self.run['shared_folders'].split(',')]
        # ----- add shortcuts - example: run.Copy instead of run.system.Copy
        if type(run) != dict:
            for meth in list(AsterSystem.__dict__.keys()):
                if meth[0] == meth[0].upper() and not hasattr(run, meth) \
                        and hasattr(self, meth) and callable(getattr(self, meth)):
                    setattr(run, meth, getattr(self, meth))


    def getuser_host(self):
        return local_user, local_host


    def _mess(self, msg, cod='', store=False):
        """Just print a message
        """
        if hasattr(self.run, 'Mess'):
            self.run.Mess(msg, cod, store)
        else:
            print('%-18s %s' % (cod, msg))


    def _dbg(self, *args, **kargs):
        """Print debug informations
        """
        if hasattr(self.run, 'DBG'):
            kargs['stack_id'] = kargs.get('stack_id', 1)
            self.run.DBG(*args, **kargs)
        elif self.debug:
            print('<DBG> %s // %s' % (str(args), str(kargs)))


    def VerbStart(self, cmd, verbose=None):
        """Start message in verbose mode
        """
        Lm = self._LineLen
        if verbose == None:
            verbose = self.verbose
        if verbose:
            pcmd = cmd
            if len(cmd) > Lm-2 or cmd.count(os.linesep) > 0:
                pcmd = pcmd+os.linesep+' '*Lm
            print(('%-'+str(Lm)+'s') % (pcmd, ), end=' ')
            magic.get_stdout().flush()


    def VerbEnd(self, iret, output='', verbose=None):
        """End message in verbose mode
        """
        if verbose == None:
            verbose = self.verbose
        if verbose:
            if iret == 0:
                print(label['OK'])
            else:
                print(label['FAILED'])
                print(_('Exit code : %d') % iret)
            if (iret != 0 or self.debug) and output:
                print(output)


    def VerbIgnore(self, verbose=None):
        """End message in verbose mode
        """
        if verbose == None:
            verbose = self.verbose
        if verbose:
            print(label['SKIP'])


    def local_shell(self, cmd, bg=False, verbose=False, follow_output=False,
                   alt_comment=None, interact=False, separated_stderr=False,
                   stack_id=3, **ignore_args):
        """Execute a command shell
            cmd           : command
            bg            : put command in background if True
            verbose       : print status messages during execution if True
            follow_output : follow interactively output of command
            alt_comment   : print this "alternative comment" instead of "cmd"
        Return :
            iret     : exit code if bg = False,
                    0 if bg = True
            output   : output lines (as string)
        """
        if not alt_comment:
            alt_comment = cmd
        if len(cmd) > self.MaxCmdLen:
            self._mess((_('length of command shell greater '\
                    'than %d characters.') % self.MaxCmdLen), '<A>_ALARM')
        self._dbg('cmd :', cmd, 'background : %s' % bg, 'follow_output : %s' % follow_output,
                  all=True, stack_id=stack_id)
        self.VerbStart(alt_comment, verbose=verbose)
        if follow_output and verbose:
            print(os.linesep+_('Command output :'))

        var_id = "EXIT_COMMAND_%s" % get_command_id()
        fout_name = get_tmpname_base(self._tmpdir, 'local_shell_output',
                                     user=local_user, node=local_host, pid="auto")
        ferr_name = get_tmpname_base(self._tmpdir, 'local_shell_error',
                                     user=local_user, node=local_host, pid="auto")
        new_cmd = get_command_line(cmd, bg, follow_output, separated_stderr,
                                   fout_name, ferr_name, var_id)
        # execution
        iret = os.system(convert(new_cmd))
        output, error = "", ""
        try:
            with open(fout_name, "r") as f:
                output = to_unicode(f.read())
            os.remove(fout_name)
        except:
            pass
        try:
            with open(fout_name, "r") as f:
                error = to_unicode(f.read())
            os.remove(ferr_name)
        except:
            pass

        if follow_output:
            # repeat header message
            self.VerbStart(alt_comment, verbose=verbose)
        mat = re.search('(?:EXIT_CODE|EXECUTION_CODE_ASTER_EXIT_.*?)=([0-9]+)', output)
        if mat:
            iret = int(mat.group(1))
        elif follow_output:
            # os.system returns exit code of tee
            mat = re.search("%s=([0-9]+)" % var_id, output)
            if mat:
                iret = int(mat.group(1))
        self.VerbEnd(iret, output, verbose=verbose)
        if iret != 0:
            self._dbg('ERROR : iret = %s' % iret, '+++ STANDARD OUTPUT:', output,
                      '+++ STANDARD ERROR:', error, '+++ END', all=True,
                      prefix="    ")
        if bg:
            iret = 0
        if not separated_stderr:
            result = iret, output
        else:
            result = iret, output, error
        return result


    def filename2dict(self, s):
        """Convert file name 's' given in format [[user[:passwd]@]machine:]name
        into a dictionnary with keys = user, passwd, mach, name
        """
        try:
            fname = FileName(s)
        except TypeError:
            self._mess(_('unexpected type'), '<F>_PROGRAM_ERROR')
        d = fname.asdict()
        for rep in self.shared_folders:
            if d['name'].startswith(rep):
                d['user'] = d['passwd'] = d['mach'] = ''
                break
        return d


    def PathOnly(self, filename):
        """Return only the path of file given as [[user[:passwd]@]machine:]name.
        Very useful when `filename` contains 'user@mach:' string but refers to a
        local filename.
        """
        return self.filename2dict(filename)['name']


    def Copy(self, dest, *src, **opts):
        """Copy files/directories (from 'src' list) to 'dest'
        Remote names format :
            [[user[:passwd]@]machine:]name
        where name is an absolute or a relative path.
        optional arguments : verbose, follow_output passed to local_shell,
            niverr : default is set to <F>_COPY_ERROR, but may be '<A>' or less !
            protocol : to use a different protocol just for this copy.
        Note : if src[i] is a directory and dest doesn't exist
             dest is created and the content of src[i] is copied into dest.
             This is not a default behavior of rsync which would create
             `basename src[i]` in dest even if dest doesn't exist.
        """
        iret = 0
        kargs = {}
        # take values from opts if exist
        kargs['verbose'] = opts.get('verbose', self.verbose)
        kargs['follow_output'] = opts.get('follow_output', False)
        kargs['separated_stderr'] = False
        if opts.get('niverr'):
            niverr = opts['niverr']
        else:
            niverr = '<F>_COPY_ERROR'
        ddest = self.filename2dict(dest)
        if self.IsRemote(dest) \
                or (ddest['user'] != '' and ddest['user'] != local_user):
            fdest = ddest['user']+'@'+ddest['mach']+':'+ddest['name']
        else:
            fdest = ddest['name']
        self._dbg('source list : %s' % (src,), 'destination : %s' % fdest, stack_id=2)

        if len(src) < 1:
            self._mess(_('no source file to copy'), '<A>_ALARM')

        for f in src:
            # here because we can change 'proto' if necessary
            proto = opts.get('protocol', self.param['remote_copy_protocol'])
            jret = 0
            df = self.filename2dict(f)
            if self.IsRemote(f):
                fsrc = df['user']+'@'+df['mach']+':'+df['name']
            else:
                fsrc = df['name']
                df['user'] = df['mach'] = ''
            cmd = ''
            tail = '.../'+'/'.join(f.split('/')[-2:])
            if 'alt_comment' not in opts:
                kargs['alt_comment'] = ufmt(_("copying %s..."), tail)
            else:
                kargs['alt_comment'] = opts['alt_comment']
            if df['mach'] == '' and ddest['mach'] == '':
                cmd = command['copy'] % { "args" : fsrc+' '+fdest }
            else:
                if proto == 'RSYNC' and df['mach'] != '' and ddest['mach'] != '':
                    proto = 'RCP'
                    self._mess(_("copying a remote file to another remote server " \
                            "isn't allowed through RSYNC, trying with RCP."))
                if proto == 'RCP':
                    cmd = 'rcp -r '+fsrc+' '+fdest
                elif proto == 'SCP':
                    cmd = 'scp -rBCq -o StrictHostKeyChecking=no '+fsrc+' '+fdest
                elif proto == 'RSYNC':
                    if self.IsDir(f) and not self.Exists(dest):
                        self.MkDir(dest)
                        cmd = 'rsync -rz '+os.path.join(fsrc, '*')+' '+fdest
                    else:
                        cmd = 'rsync -rz '+fsrc+' '+fdest
                elif proto == 'HTTP':
                    str_user = ''
                    if not df['user'] in ('', 'anonymous'):
                        str_user = df['user']+'@'
                    # dest must be local
                    if ddest['mach'] == '':
                        cmd = 'wget http://'+str_user+df['mach']+df['name']+' -O '+fdest
                    else:
                        cmd = ''
                        self._mess(ufmt(_('remote destination not allowed through %s' \
                                           ' : %s'), proto, fdest), niverr)
            if cmd != '':
                jret, out = self.local_shell(cmd, **kargs)
                if jret != 0 and niverr != 'SILENT':
                    self._mess(ufmt(_('error during copying %s to %s'), f, fdest) \
                        + os.linesep + ufmt(_('message : %s'), out), niverr)
            else:
                self._mess(_('unexpected error or unknown copy protocol : %s') \
                   % proto, niverr)
            iret = max(jret, iret)
        return iret


    def Rename(self, src, dest, **opts):
        """Rename 'src' to 'dest'.
        Try using os.rename then 'mv -f' if failure.
        """
        iret = 0
        try:
            os.rename(src, dest)
            assert os.path.exists(dest)      # could avoid NFS failure
        except (AssertionError, OSError):
            cmd = 'mv -f %s %s' % (src, dest)
            result = self.local_shell(cmd, **opts)
            iret = result[0]
        return iret

    def Symlink(self, src, link_name, verbose=True):
        """Create a symbolic link."""
        if on_windows():
            return self.Copy(link_name, src)

        self.VerbStart(ufmt(_('adding a symbolic link %s to %s...'),
                              link_name, src), verbose=verbose)
        iret = 0
        output = ''
        try:
            if osp.exists(link_name):
                self.Delete(link_name)
            os.symlink(src, link_name)
        except OSError as output:
            iret = 4
            self._mess(ufmt(_('error occurs during creating a symbolic link' \
                    ' from %s to %s'), src, link_name), '<E>_SYMLINK')
        self.VerbEnd(iret, output, verbose=verbose)
        return iret

    def Shell(self, cmd, mach='', user='', **opts):
        """Execute a command shell on local or remote machine.
        Options : see local_shell
        """
        #TODO use list type
        if type(cmd) in (list, tuple):
            cmd = ' '.join(map(convert, cmd))
        iret = 1
        # valeurs par défaut
        kargs = {
            'verbose'         : self.verbose,
            'bg'              : False,
            'interact'        : False,
            'follow_output'   : False,
            'alt_comment'     : cmd,
            'timeout'         : None,
            'display_forwarding' : False,
        }
        # surcharge par opts
        kargs.update(opts)

        proto = self.param['remote_shell_protocol']

        # distant ?
        user = user or local_user
        distant = not is_localhost2(mach, user=user)
        self._dbg('remote command (%s <> %s and %s <> %s) ? %s' % (mach, local_host, user, local_user, distant))

        if not distant:
            result = self.local_shell(cmd, **kargs)
        else:
            action = ''
            # pour recuperer correctement l'output, il faut des " et non des ' autour des
            # commandes sous "sh -c" et sous "xterm -e"
            cmd = cmd.replace('"', '\\"')
            cmd = cmd.replace('$', '\\$')
            cmd = '"%s"' % cmd
            if proto == 'RSH':
                action = 'rsh -n -l '+user+' '+mach+' '+cmd
            #elif proto == 'SSH': is the default
            else:
                options = "-n -o StrictHostKeyChecking=no -o BatchMode=yes"
                if kargs['timeout']:
                    options += " -o 'ConnectTimeout=%s'" % kargs["timeout"]
                if kargs['display_forwarding']:
                    options += " -X"
                action = "ssh %(options)s -l %(user)s %(host)s %(command)s" % {
                    "user" : user,
                    "host" : mach,
                    "command" : cmd,
                    "options" : options,
                }
            result = self.local_shell(action, **kargs)
        return result


    def Gzip(self, src, **opts):
        """Compress file or content of directory 'src'.
        optional arguments : verbose, niverr, cmd (to override gzip command).
        Only local files/directories supported !
        """
        return self._gzip_gunzip('gzip', src, **opts)


    def Gunzip(self, src, **opts):
        """Decompress file or content of directory 'src'.
        optional arguments : verbose, niverr, cmd (to override gzip -d command).
        Only local files/directories supported !
        """
        return self._gzip_gunzip('gunzip', src, **opts)


    def _gzip_gunzip(self, mode, src, **opts):
        """Called by Gzip (mode=gzip) and Gunzip (mode=gunzip) methods.
        Return status and filename of src after de/compression.
        Only local files/directories supported !
        """
        para = {
            'gzip' : {
                'cmd'     : 'gzip ',
                'niverr'  : '<F>_COMPRES_ERROR',
                'msg0'    : _('no file/directory to compress'),
                'comment' : _('compressing %s'),
                'msgerr'  : _('error during compressing %s'),
            },
            'gunzip' : {
                # sometimes gunzip doesn't exist, gzip seems safer
                'cmd'     : 'gzip -d ',
                'niverr'  : '<F>_DECOMPRESSION',
                'msg0'    : _('no file/directory to decompress'),
                'comment' : _('decompressing %s'),
                'msgerr'  : _('error during decompressing %s'),
            },
        }
        if not mode in list(para.keys()):
            self._mess(_('unknown mode : %s') % mode, '<F>_PROGRAM_ERROR')
        iret = 0
        if 'cmd' in opts:
            cmd = opts['cmd']
        else:
            cmd = para[mode]['cmd']
        if 'verbose' in opts:
            verbose = opts['verbose']
        else:
            verbose = self.verbose
        if 'niverr' in opts:
            niverr = opts['niverr']
        else:
            niverr = para[mode]['niverr']

        if len(src) < 1:
            self._mess(para[mode]['msg0'], '<A>_ALARM')
            return iret

        if not os.path.isdir(src):
            if mode == 'gzip':
                name = src + '.gz'
            else:
                name = re.sub('\.gz$', '', src)
            lf = [src]
        else:
            name = src
            lf = glob.glob(os.path.join(src, '*'))
        for f in lf:
            jret = 0
            comment = para[mode]['comment'] % f
            if os.path.isdir(f):
                self.VerbStart(comment, verbose=verbose)
                self.VerbIgnore(verbose=verbose)
            else:
                jret = self.local_shell(cmd+f, verbose=verbose, alt_comment=comment)[0]
            if jret != 0:
                self._mess(para[mode]['msgerr'] % f, niverr)
            iret = max(iret, jret)
        return iret, name


    def IsRemote(self, path):
        """Return True if 'path' seems to be on a remote host.
        NB : we suppose that host and host.domain are identical.
        """
        dico  = self.filename2dict(path)
        return not is_localhost2(dico["mach"])


    def Exists(self, path):
        """Return True if 'path' exists (file or directory).
        """
        iret = 0
        exists = True
        dico = self.filename2dict(path)
        if self.IsRemote(path):
            dico["cmd"] = shell_cmd
            cmd = "%(cmd)s 'if test -f %(name)s ; then echo FILE_EXISTS; " \
                  "elif test -d %(name)s ; then echo DIR_EXISTS ; " \
                  "else echo FALSE ; fi'"
            iret, out = self.Shell(cmd % dico, dico['mach'], dico['user'], verbose=self.verbose)
            if out.find('FALSE') > -1:
                exists = False
        else:
            exists = os.path.exists(dico['name'])
        return exists


    def IsDir(self, path):
        """Return True if 'path' is a directory.
        """
        iret = 0
        isdir = False
        dico = self.filename2dict(path)
        if self.IsRemote(path):
            dico["cmd"] = shell_cmd
            cmd = "%(cmd)s 'if test -d %(name)s ; then echo IS_DIRECTORY; " \
                  "else echo FALSE ; fi'"
            iret, out = self.Shell(cmd % dico, dico['mach'], dico['user'], verbose=self.verbose)
            if out.find('IS_DIRECTORY') > -1:
                isdir = True
        else:
            isdir = os.path.isdir(dico['name'])
        return isdir


    def FileCat(self, src=None, dest=None, text=None):
        """Append content of 'src' to 'dest' (filename or file object).
        Warning : Only local filenames !
        """
        assert dest != None and (src != None or text != None)
        if type(dest) == str:
            if not os.path.isdir(dest) or os.access(dest, os.W_OK):
                f2 = open(dest, 'a')
            else:
                self._mess(ufmt(_('No write access to %s'), dest), '<F>_ERROR')
                return
        else:
            f2 = dest
        if text is None:
            if os.path.exists(src):
                if os.path.isfile(src):
                    with open(src, 'r') as f:
                        text = f.read()
                else:
                    self._mess(ufmt(_('file not found : %s'), src), '<F>_FILE_NOT_FOUND')
                    return
        if text:
            f2.write(text)

        if type(dest) == str:
            f2.close()


    def _check_filetype(self, path):
        """Return file type or '' on remote files."""
        if on_windows():
            return ''
        dico = self.filename2dict(path)
        out = ''
        if not self.IsRemote(path):
            cmd = command['file'] % { 'args' : path }
            iret, out = self.Shell(cmd, verbose=self.verbose)
            out = re.sub(re.escape(path) + ': *', '', out)
        return out


    def IsText(self, path):
        """Return True if `path` is a text file.
        Warning : return False if `path` is remote
        """
        return self._check_filetype(path).find('text') > -1


    def IsTextFileWithCR(self, path):
        """Return True if `path` is a text file containing line terminators.
        Warning : return False if `path` is remote
        """
        out = self._check_filetype(path)
        return out.lower().find('text') > -1 and out.find('CR') > -1


    def MkDir(self, rep, niverr=None, verbose=None, chmod=0o755):
        """Create the directory 'rep' (mkdir -p ...)
        """
        if niverr == None:
            niverr = '<F>_MKDIR_ERROR'
        if verbose == None:
            verbose = self.verbose
        iret = 0
        dico = self.filename2dict(rep)
        if self.IsRemote(rep):
            cmd = 'mkdir -p %(dir)s ; chmod %(chmod)o %(dir)s' % {
                'dir' : dico['name'],
                'chmod' : chmod,
            }
            iret, out = self.Shell(cmd, dico['mach'], dico['user'], verbose=verbose)
        else:
            dico['name'] = osp.expandvars(dico['name'])
            self.VerbStart(ufmt(_('creating directory %s'), dico['name']), verbose)
            # ----- it's not tested in remote
            s = ''
            try:
                os.makedirs(dico['name'])
            except OSError as err:
                # maybe simultaneously created by another process
                s = err.args[0]
                if not os.path.isdir(dico['name']):
                    iret = 4
            try:
                os.chmod(dico['name'], chmod)
            except OSError as err:
                s = err.args[0]
                self._mess(ufmt(_('can not change permissions on %s'), rep), '<A>_ALARM')
            self.VerbEnd(iret, s, verbose)
        if iret != 0:
            self._mess(ufmt(_('can not create directory %s'), rep), niverr)
        return iret


    def Delete(self, rep, remove_dirs=True, verbose=None):
        """Delete a file or a directory tree (rm -rf ...).
        Set 'remove_dirs' to False to be sure to delete 'rep' only if it's a file.
        """
        if verbose == None:
            verbose = self.verbose
        iret = 0
        dico = self.filename2dict(rep)
        # preventing to delete first level directories (as /, /home, /usr...)
        if dico['name'][0] == '/' and len(dico['name'][:-1].split(os.sep)) <= 2:
            self._mess(ufmt(_('deleting this directory seems too dangerous. ' \
                    '%s has not been removed'), dico['name']), '<A>_ALARM')
            return

        if remove_dirs:
            cmd = command['rm_dirs'] % { 'args' : dico['name'] }
        else:
            cmd = command['rm_file'] % { 'args' : dico['name'] }

        tail = '.../'+'/'.join(rep.split('/')[-2:])
        comment = ufmt(_('deleting %s'), tail)
        if self.IsRemote(rep):
            iret, out = self.Shell(cmd, dico['mach'], dico['user'],
                                alt_comment=comment, verbose=verbose, stack_id=4)
        else:
            iret, out = self.Shell(cmd, alt_comment=comment, verbose=verbose, stack_id=4)
        return


    def AddToEnv(self, profile):
        """Read 'profile' file (with sh/bash/ksh syntax) and add updated
        variables to os.environ.
        """
        if not os.path.isfile(profile):
            self._mess(ufmt(_('file not found : %s'), profile), '<A>_FILE_NOT_FOUND')
            return
        # read initial environment
        iret, out = self.Shell('%s env' % shell_cmd)
        self._dbg("env_init", out, all=True)
        env_init = env2dict(out)
        if iret != 0:
            self._mess(_('error getting environment'), '<E>_ABNORMAL_ABORT')
            return
        # read profile and dump modified environment
        iret, out = self.Shell('%s ". %s && env"' % (shell_cmd, profile))
        self._dbg("env_prof", out, all=True)
        env_prof = env2dict(out)
        if iret != 0:
            self._mess(ufmt(_('error reading profile : %s'), profile), '<E>_ABNORMAL_ABORT')
            return
        # "diff"
        for k, v in list(env_prof.items()):
            if env_init.get(k, None) != v:
                self._dbg('AddToEnv set : %s=%s' % (k, v))
                os.environ[k] = convert(v)
        for k in [k for k in list(env_init.keys()) if env_prof.get(k) is None]:
            self._dbg('unset %s ' % k, DBG=True)
            try:
                del os.environ[k]
            except:
                pass


    def GetHostName(self, host=None):
        """Return hostname of the machine 'host' or current machine if None.
        """
        return get_hostname(host)


    def GetCpuInfo(self, what, mach='', user=''):
        """Return CPU information.
        what='numcpu'    : number of processors
        what='numthread' : number of threads (depends on MultiThreading attribute)
        """
        if self._cpuinfo_cache.get(what+mach+user) is not None:
            return self._cpuinfo_cache[what+mach+user]
        if what in ('numcpu', 'numthread'):
            num = 1
            if not self.MultiThreading and what == "numthread":
                return 1
            if on_mac():
                try:
                    num = int(os.popen('sysctl -n hw.ncpu').read())
                except ValueError:
                    pass
            elif on_linux():
                iret, out = self.Shell('cat /proc/cpuinfo', mach, user)
                exp = re.compile('^processor\s+:\s+([0-9]+)', re.MULTILINE)
                l_ids = exp.findall(out)
                if len(l_ids) >= 1:      # else: it should not !
                    num = max([int(i) for i in l_ids]) + 1
            elif on_windows():
                num = 1
            self._cpuinfo_cache[what+mach+user] = num
            self._dbg("GetCpuInfo '%s' returns : %s" % (what, num))
            return num
        else:
            return None


    def GetMemInfo(self, what, mach='', user=''):
        """Return memory information.
        """
        if self._meminfo_cache.get(what+mach+user) is not None:
            return self._meminfo_cache[what+mach+user]
        if what in ('memtotal',):
            num = None
            if on_linux():
                iret, out = self.Shell('cat /proc/meminfo', mach, user)
                mat = re.search('^%s *: *([0-9]+) *kb' % what, out, re.MULTILINE | re.IGNORECASE)
                if mat != None:         # else: it should not !
                    num = int(mat.group(1)) // 1024
                    if not on_64bits():
                        num = min(num, 2047)
            self._meminfo_cache[what+mach+user] = num
            self._dbg("GetMemInfo '%s' returns : %s" % (what, num))
            return num
        else:
            return None


    def Ping(self, mach='', timeout=2):
        """Return True if 'mach' is responding.
        """
        if is_localhost2(mach):
            return True
        iret, output = self.Shell(command['ping'] % { 'host' : mach, 'timeout' : timeout })
        return iret == 0


    def SendMail(self, dest, author=None, subject='no subject', text=''):
        """Send a message by mail.
        Use ", " in `dest` to separate multiple recipients.
        """
        sign = _('email sent at %s by as_run from %s') % (now(), local_host)
        sign = os.linesep*2 + '-'*len(sign) + os.linesep \
           + sign \
           + os.linesep   + '-'*len(sign) + os.linesep
        try:
            import smtplib
            from asrun.common.utils import MIMETextClass
            if MIMETextClass is None:
                raise ImportError
        except ImportError:
            self._mess(_('Can not send mail from this machine'),
                '<A>_NO_MAILER')
            return
        dest = [s.strip() for s in dest.split(',')]
        mail_encoding = get_encoding()
        content = convert(to_unicode(text) + sign, mail_encoding)
        msg = MIMETextClass(content, _charset=mail_encoding)
        msg['Subject'] = convert(subject, mail_encoding)
        if author == None:
            author = '%s@%s' % (local_user, local_full_host)
        msg['From'] = author
        msg['To'] = ', '.join(dest)
        s = smtplib.SMTP()
        s.connect()
        s.sendmail(msg['From'], dest, msg.as_string())
        s.close()


    def SetLimit(self, what, *l_limit):
        """Set a system limit.
        `what` is one of CORE, CPU... (see help of resource module).
        If provided `l_limit` contains (soft limit, hard limit).
        """
        if not on_linux():
            return
        import resource
        nomp = 'RLIMIT_%s' % what.upper()
        param = getattr(resource, nomp)
        if param != None:
            if len(l_limit) == 1:
                l_limit = (l_limit[0], l_limit[0])
            elif len(l_limit) != 2:
                l_limit = (-1, -1)
            l_limit = list(l_limit)
            for i, lim in enumerate(l_limit):
                if type(lim) not in (int, int):
                    l_limit[i] = -1
            try:
                self._dbg([what, nomp, l_limit])
                resource.setrlimit(param, l_limit)
            except Exception as msg:
                self._mess(_('unable to set %s limit to %s') % (nomp, l_limit))


    def Which(self, cmd):
        """Same as `which cmd`. Returns the path found or None.
        """
        ldirs = os.environ.get('PATH').split(':')
        for d in ldirs:
            path = os.path.join(d, cmd)
            if os.path.isfile(path) and os.access(path, os.X_OK):
                return path
        return None


    def FindPattern(self, root, pattern, maxdepth=5):
        """Return a list of the files matching 'pattern'.
        The same as glob if maxdepth=0.
        """
        if self.IsRemote(root):
            self._mess(_('Find files matching a pattern only works on local files/directories'), \
                '<F>_PROGRAM_ERROR')
        root = self.PathOnly(root)
        if os.path.isfile(root):
            return [root, ]
        root = os.path.realpath(root)
        dirs = [root,]
        if maxdepth > 0:
            level = len(split_path(root))
            for base, l_dirs, l_nondirs in os.walk(root):
                lev=len(split_path(base))
                if lev <= (level + maxdepth):
                    if not base in dirs:
                        dirs.append(base)
                else:
                    del l_dirs[:] # empty dirs list so we don't walk needlessly
        res = []
        for d in dirs:
            res.extend(glob.glob(os.path.join(d, pattern)))
        self._dbg('FindPattern : rootdir=%s  pattern=%s' % (root, repr(pattern)), res)
        return res



class AsterSystemMinimal(AsterSystem):
    """Fake AsterRun to use easily AsterSystem outside of asrun.
    """
    def __init__(self, **kargs):
        """Initialization
        """
        opts = {
            'debug'   : False,
            'verbose' : False,
            'remote_copy_protocol' : 'SCP',
            'remote_shell_protocol' : 'SSH',
        }
        opts.update(kargs)
        AsterSystem.__init__(self, run=opts)


ASTER_SYSTEM = bwc_deprecate_class('ASTER_SYSTEM', AsterSystem)
ASTER_SYSTEM_MINIMAL = bwc_deprecate_class('ASTER_SYSTEM_MINIMAL',
                                           AsterSystemMinimal)

if __name__ == '__main__':
    system = AsterSystemMinimal()
