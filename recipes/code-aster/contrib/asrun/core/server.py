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
This module defines a server used for as_run services.
"""

import os
import os.path as osp

from asrun.core import magic
from asrun.common.i18n import _
from asrun.common.utils import Enum, get_plugin
from asrun.common.sysutils import (local_user, local_host, get_home_directory,
                                   safe_pathname)
from asrun.common_func import is_localhost2

# pylint: disable-msg=E1101
TYPES = Enum("COPY_TO", "COPY_FROM", "EXEC")

KEYS = {
    TYPES.COPY_TO : 'protocol_copyto',
    TYPES.COPY_FROM : 'protocol_copyfrom',
    TYPES.EXEC : 'protocol_exec',
}

DEFAULT_ID = "j%d" % os.getpid()


# ----------------------------------------------------------------------
#TODO to import from a *new* system module
def local_shell(command):
    """Execute a command locally."""
    magic.log.debug("command: %s", command)
    res = magic.run.Shell(command, separated_stderr=True)
    magic.log.debug("returns %s", res)
    return res
# ----------------------------------------------------------------------


class BaseServer(object):
    """Base class to define a server to execute commands or
    to copy files.
    A server requires at least two arguments:
        host : ip or full name of the host
        user : username used to connect
    """
    def __init__(self, host, user, **kwargs):
        """Initialization"""
        self.host = host or local_host
        self.user = user or local_user
        self._is_localhost = is_localhost2(self.host, self.user)
        magic.log.debug("BaseServer init host=%s user=%s", self.host, self.user)

    def is_localhost(self):
        """Tell if the server is the local host."""
        return self._is_localhost


class ExecServer(BaseServer):
    """Server with execution capability."""
    def __init__(self, host, user, **kwargs):
        """Initialization"""
        super(ExecServer, self).__init__(host, user, **kwargs)
        self.aster_root = kwargs.get('aster_root')

    def set_aster_root(self, aster_root):
        """Configure the server."""
        self.aster_root = aster_root

    def get_aster_root(self):
        return self.aster_root

    def support_display_forwarding(self):
        """Tell if the protocol supports display forwarding."""
        # If True the display must be reset before calling exec_command,
        # the protocol shoud redefined it internally ($DISPLAY is the
        # right value). Example: SSH (which uses localhost:11.0).
        # If False, the current value can be used but will work only
        # if remote display connections are allowed. Example: RSH.
        return False

    def exec_command(self, command, display_forwarding=False, **opts):
        """Execute a command line on the server."""
        cmd = command
        if type(cmd) in (list, tuple):
            cmd = ' '.join(cmd)
        magic.log.info(_("execute on %s@%s : %s"), self.user, self.host, cmd)
        res = self._exec_command(command, display_forwarding, **opts)
        magic.log.info(_("returns %s"), res[0])
        return res

    def _exec_command(self, command, display_forwarding=False, **opts):
        """Execute a command line on the server."""
        # the server must deal with display_forwarding option
        # and print a warning if it doesn't support it.
        raise NotImplementedError('must be defined in a derivated class')


class CopyServer(BaseServer):
    """Server with copy capability.
    Requires host, user + proxy_dir : directory used for copying.
    jobid allows to identify the "repository" (something as fromhost-pid)
    """
    def __init__(self, host, user, **kwargs):
        """Initialization"""
        super(CopyServer, self).__init__(host, user, **kwargs)
        self.jobid = kwargs.get('jobid', DEFAULT_ID)
        self.remote_basedir = kwargs['proxy_dir']
        name = '%s-%s-%s' % (self.user, self.host, self.jobid)
        name = safe_pathname(name.strip('-'))
        self.proxy_dir = osp.join(self.remote_basedir, name)

    def set_proxy_dir(self, proxy_dir):
        """Configure the server."""
        if self.is_localhost():
            self.proxy_dir = osp.join(get_home_directory(self.user), proxy_dir)
        else:
            self.proxy_dir = proxy_dir

    def get_proxy_dir(self):
        return self.proxy_dir

    def delete_proxy_dir(self):
        """Erase the proxy_dir directory on the server."""
        raise NotImplementedError('must be defined in a derivated class')


class CopyToServer(CopyServer):
    """Server with copy capability.
    Requires host, user + proxy_dir : directory in which the files
    will be copied.
    """
    # files should be on localhost or already on "self"
    # If a file is on another server, we try to use this protocol.
    def __init__(self, host, user, **kwargs):
        """Initialization"""
        super(CopyToServer, self).__init__(host, user, **kwargs)
        self._proxydir_created = False

    def _create_dir(self, directory):
        """Create a directory on the server."""
        raise NotImplementedError('must be defined in a derivated class')

    def _create_proxy_dir(self):
        """Create proxy_dir directory on the server."""
        if not self._proxydir_created:
            self._create_dir(self.proxy_dir)
        self._proxydir_created = True

    def _copyoneto(self, src, convert=None, **opts):
        """Copy the file `srcto a server.
        Return 0 or >0 if it failed.
        `convert` is the function used to compute basename = f(convert).
        """
        raise NotImplementedError('must be defined in a derivated class')

    def copyto(self, *files, **opts):
        """Copy `filesto a server."""
        self._create_proxy_dir()
        ret = 0
        if len(files) == 0:
            magic.log.info(_("no file to copy."))
        for src in files:
            iret = self._copyoneto(src, **opts)
            ret = max(ret, iret)
        return ret

    def get_remote_filename(self, src):
        """Return the filename of 'src' after being copied on the server
        (using copyto)."""
        return osp.join(self.get_proxy_dir(), osp.basename(src))


class CopyFromServer(CopyServer):
    """Server with copy capability.
    Requires host, user + proxy_dir : directory from which the files
    will be download.
    """
    # files are on the server and will be copied on localhost.
    # If a file should be copied on another host, it should fail.
    def _create_local_destdir(self, dst):
        """Create destination directory of `dst(on localhost)."""
        dname = osp.dirname(dst)
        magic.log.debug('mkdir %s', dname)
        try:
            os.makedirs(dname)
        except:
            # the copy will fail later...
            pass

    def _copyonefrom(self, dst, convert=None, **opts):
        """Copy the file `dst` from a server.
        Return 0 or >0 if it failed.
        `convert` is the function used to compute basename = f(convert).
        Example : dst=/home/user/dir/fname
            => COPY log@mach:`self.proxy_dir`/convert(fname) /home/user/dir/fname

        Warning: to avoid to create /home/user/dir/fname/fname when
        fname is a directory, it's usually better to execute:
            => COPY log@mach:`self.proxy_dir`/convert(fname) /home/user/dir/
        """
        raise NotImplementedError('must be defined in a derivated class')

    def copyfrom(self, *files, **opts):
        """Copy each element of `files` from a server."""
        ret = 0
        if len(files) == 0:
            magic.log.info(_("no file to copy."))
        for dst in files:
            self._create_local_destdir(dst)
            iret = self._copyonefrom(dst, **opts)
            ret = max(ret, iret)
        return ret


class LocalExecServer(ExecServer):
    """To execute command on localhost."""
    #TODO AsterSystem need refactoring (as a module) to be called here
    # support_display_forwarding is False, the current display value
    # will be used.
    # For example, --edit receive localhost.domain:0.0, see it's the
    # local host, and so finally use :0.0
    # I think it can not automatically use :0.0, if astk is run from
    # a remote machine. In this case, we must try to use remote.domain:0...

    def __init__(self, host, user, **kwargs):
        """Initialization"""
        magic.log.debug("LocalExecServer init")
        super(LocalExecServer, self).__init__(host, user, **kwargs)
        self.user = local_user
        self.host = local_host

    def _exec_command(self, command, display_forwarding=False, **options):
        """Execute a command line on the server."""
        return local_shell(command)


class LocalCopyServer(CopyToServer, CopyFromServer):
    """To execute command on localhost."""
    #TODO AsterSystem need refactoring (as a module) to be called here

    def __init__(self, host, user, **kwargs):
        """Initialization"""
        magic.log.debug("LocalCopyServer init")
        super(LocalCopyServer, self).__init__(host, user, **kwargs)
        self.user = local_user
        self.host = local_host

    def _create_dir(self, directory):
        """Create a directory on the server."""
        magic.log.info(_("create directory %s..."), directory)
        try:
            os.makedirs(directory)
        except:
            pass
        magic.log.info(_("done"))

    def delete_proxy_dir(self):
        """Erase the proxy_dir directory on the server."""
        import shutil
        magic.log.info(_("delete directory %s..."), self.proxy_dir)
        try:
            shutil.rmtree(self.proxy_dir)
        except OSError:
            magic.log.info(_("failed"))
        else:
            magic.log.info(_("done"))

    def _copyoneto(self, src, convert=None):
        """Copy the file `srcto a server.
        Return 0 or >0 if it failed.
        `convert` is the function used to compute basename = f(convert).
        """
        magic.log.info(_("copy %s to %s"), src, self.proxy_dir)
        bname = osp.basename(src)
        if convert is not None:
            bname = convert(src)
        dst = osp.join(self.proxy_dir, bname)
        iret = magic.run.Copy(dst, src, niverr='SILENT')
        magic.log.info(_("returns %s"), iret)
        return iret

    def _copyonefrom(self, dst, convert=None):
        """Copy the file `dst` from a server.
        `convert` is the function used to compute basename = f(convert).
        Return 0 or >0 if it failed.
        Example : dst=/home/user/dir/fname
            => cp -r `self.proxy_dir`/convert(fname) /home/user/dir/fname

        Warning: to avoid to create /home/user/dir/fname/fname when
        fname is a directory, we execute:
            => cp -r `self.proxy_dir`/convert(fname) /home/user/dir/
        """
        bname = osp.basename(dst)
        if convert is not None:
            bname = convert(dst)
        fsrc = osp.join(self.proxy_dir, bname)
        magic.log.info(_("copy %s to %s"), fsrc, dst)
        iret = magic.run.Copy(dst, fsrc, niverr='SILENT')
        magic.log.info(_("returns %s"), iret)
        return iret



def build_server(classname, host, user, **kwargs):
    """Build a server calling the specified protocol class.
    the argument type is necessary to choose a LocalServer variant.
    """
    path = classname.split('.')
    if is_localhost2(host, user=user) and kwargs.get('type') is not None:
        magic.log.debug("'%s' is the local host", host)
        if kwargs['type'] in (TYPES.COPY_TO, TYPES.COPY_FROM):
            sclass = LocalCopyServer
        else:
            sclass = LocalExecServer
    elif globals().get(path[-1]):
        sclass = globals()[path[-1]]
    else:
        # external server type
        sclass = get_plugin(classname)
    magic.log.debug("create %s with %s, %s, %s", sclass, host, user, kwargs)
    return sclass(host, user, **kwargs)


def build_server_from_profile(prof, type, **kwargs):
    """Build a server object from content of an AsterProfil object.
    The export must defined :
        - proxy_dir for COPY_TO/COPY_FROM servers
        - aster_root for an EXEC server
    """
    host = prof['serveur'][0]
    user = prof['username'][0]
    proto = prof[KEYS[type]][0]
    assert proto, "'%s' not defined in the profile" % KEYS[type]
    if type in (TYPES.COPY_TO, TYPES.COPY_FROM):
        kwargs['proxy_dir'] = prof['proxy_dir'][0]
        assert kwargs['proxy_dir'], "'proxy_dir' not defined in the profile"
    if type == TYPES.EXEC:
        kwargs['aster_root'] = prof['aster_root'][0]
        assert kwargs['aster_root'], "'aster_root' not defined in the profile"
    if not TYPES.exists(type):
        raise TypeError('invalid type: %s' % repr(type))

    serv = build_server(proto, host, user, type=type, **kwargs)
    return serv
