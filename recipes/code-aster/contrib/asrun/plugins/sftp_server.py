# -*- coding: utf-8 -*-

# ==============================================================================
# COPYRIGHT (C) 2014 ALNEOS Luca DALL'OLIO             WWW.ALNEOS.COM
# COPYRIGHT (C) 2014  EDF R&D                        WWW.CODE-ASTER.ORG
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
This module defines a SFTP server for copying files.

I is usually used with a SSH server for shell commands.

In server configuration, enter:
protocol_exec : asrun.plugins.server.SSHServer
protocol_copyto : asrun.plugins.sftp_server.SFTPFilesystemServer
protocol_copyfrom : asrun.plugins.sftp_server.SFTPFilesystemServer
"""

import os
import os.path as osp

from asrun.common.i18n import _
from asrun.core        import magic
from asrun.core.server import ( ExecServer, CopyFromServer, CopyToServer,
                                local_shell )

class SFTPCallServer(ExecServer):
    """Definition of a SFTP call server."""

    def __init__(self, host, user, **kwargs):
        """Initialization"""
        magic.log.debug("SFTPCallServer init")
        super(SFTPCallServer, self).__init__(host, user, **kwargs)

    def support_display_forwarding(self):
        """Tell if the protocol supports display forwarding."""
        return False

    def mylocal_shell(self, cmdargs):
        """Alternative method, used in two cases : calling this class directly
        and when issuing a command that might normally fail (such as a chdir).
        Should find a better way of always using local_shell and get rid
        of this. In the latter case, even prepare_sftp_command could be thrown away."""
        import subprocess
        cmdline = ' '.join(cmdargs)
        magic.log.info(_("running %s..."), cmdline)
        p= subprocess.Popen(cmdline, stdout=subprocess.PIPE, shell=True)
        p.wait()
        if p.returncode != 0:
            raise IOError(p.returncode)
        lines = p.stdout.readlines()
        lines.pop(0)
        output = os.linesep.join(lines)
        return p.returncode, output

    def prepare_sftp_command(self, commanditem):
        """This creates the command arguments list (originally extracted from
        _exec_command) so that is can be used independently from local_shell,
        without code duplication."""
        cmd = ["sftp", "-q","-b", "-", "-o StrictHostKeyChecking=no", self.user+"@"+self.host]
        cmdargs = ["echo", commanditem, "|"]
        cmdargs.extend(cmd)
        return cmdargs

    def _exec_command(self, command, display_forwarding=False, **opts):
        """Execute a command line on the server."""
        #XXX append command as string and enclosed by ' or " (escape ' or " in command)
        if type(command) not in (list, tuple):
            command = [command, ]
        for commanditem in command:
            cmdargs = self.prepare_sftp_command(commanditem)
            output = local_shell(cmdargs)
        return output


class SFTPFilesystemServer(SFTPCallServer, CopyToServer, CopyFromServer):
    """
    This class defines a SFTP server for copying files.

    It is usually used with a SSH server for shell commands.

    In server configuration, enter:
    protocol_exec : asrun.plugins.server.SSHServer
    protocol_copyto : asrun.plugins.sftp_server.SFTPFilesystemServer
    protocol_copyfrom : asrun.plugins.sftp_server.SFTPFilesystemServer
    """

    def mkdir_RECURSIVE(self, remote_directory, rights=None):
        """Simulating a "mkdir -p" command in sftp"""
        if remote_directory == '/':
            # absolute path so change directory to root
            res = self._exec_command("chdir /")
            return res
        if remote_directory == '':
            # top-level relative directory must exist
            return
        remote_dirname, basename = osp.split(remote_directory)
        self.mkdir_RECURSIVE(remote_dirname)  # make parent directories
        try:
            cmdargs = self.prepare_sftp_command("chdir " + remote_directory)
            res = self.mylocal_shell(cmdargs) # sub-directory exists
        except IOError:
            res = self._exec_command("mkdir " + remote_directory) # sub-directory missing, so created it
            if rights is not None:
                res = self._exec_command("chmod " + rights + " " + remote_directory)
            res = self._exec_command("chdir " + remote_directory)
        return res

    def rmdir_RECURSIVE(self, path):
        """Simulating a rm -R command in sftp"""
        res = self._exec_command("ls -1 " + path)
        files = res[1] # stdout
        if files is not None:
            files = files.split("\n")
            for f in files:
                if len(f) == 0:
                    continue
                filepath = osp.join(path, f)
                try:
                    cmdargs = self.prepare_sftp_command("rm " + filepath)
                    res = self.mylocal_shell(cmdargs)
                except IOError:
                    self.rmdir_RECURSIVE(filepath)
        res = self._exec_command("rmdir " + path)
        return res

    def _create_dir(self, directory):
        """Create a directory on the server."""
        magic.log.info(_("create remote directory %s...") % directory)
        res = self.mkdir_RECURSIVE(directory, "0700")
        magic.log.info(_("returns %s"), res)
        return res

    def delete_proxy_dir(self):
        """Erase the proxy_dir directory on the server."""
        cmd = "rm -rf %s" % self.proxy_dir
        magic.log.info(_("delete remote directory %s..."), self.proxy_dir)
        res = self.rmdir_RECURSIVE(self.proxy_dir)
        magic.log.info(_("returns %s"), res)
        return res

    def _copyoneto(self, src, convert=None):
        """Copy the file `srcto a server.
        Return 0 or >0 if it failed.
        `convert` is the function used to compute basename = f(convert).
        """
        bname = osp.basename(src)
        if convert is not None:
            bname = convert(src)
        dst = osp.join(self.proxy_dir, bname)
        res = self._exec_command("put -r " + src + " " + dst)
        magic.log.info(_("copy %s to %s"), src, dst)
        magic.log.info(_("returns %s"), res)
        return res[0]

    def _copyonefrom(self, dst, convert=None):
        """Copy the file `dstfrom a server.
        Return 0 or >0 if it failed.
        `convert` is the function used to compute basename = f(convert).
        """
        bname = osp.basename(dst)
        if convert is not None:
            bname = convert(dst)
        src = osp.join(self.proxy_dir, bname)
        res = self._exec_command("get -r " + src + " " + dst)
        magic.log.info(_("copy %s to %s"), src, dst)
        iret = res[0]
        magic.log.info(_("returns %s"), iret)
        return iret
