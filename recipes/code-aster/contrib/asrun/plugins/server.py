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
This module defines the main server types :
    - SSH to execute commands on a remote server,
    - SCP to copy files to and from a remote server.

Additionnal modules can be added to define others servers to extend
the capabilities of asrun.

These plugins can be added in any directory listed in PYTHONPATH.
But it's recommended to place them in etc/codeaster/plugins because
the modules added in this directory will be kept during updates of asrun.
"""

import os.path as osp

from asrun.common.i18n import _
from asrun.common.utils import renametree
from asrun.core        import magic
from asrun.core.server import ( ExecServer, CopyFromServer, CopyToServer,
                                local_shell )

class SSHServer(ExecServer):
    """Definition of a SSH server."""

    def __init__(self, host, user, **kwargs):
        """Initialization"""
        magic.log.debug("SSHServer init")
        super(SSHServer, self).__init__(host, user, **kwargs)

    def support_display_forwarding(self):
        """Tell if the protocol supports display forwarding."""
        return True

    def _exec_command(self, command, display_forwarding=False, **opts):
        """Execute a command line on the server."""
        cmd = [ "ssh",
                "-n", "-o", "StrictHostKeyChecking=no",
                "-o", "BatchMode=yes" ]
        if display_forwarding:
            cmd.append("-X")
        if opts.get('timeout'):
            cmd.extend(["-o", "'ConnectTimeout=%s'" % opts["timeout"]])
        cmd.append(self.user + "@" +  self.host)
        #XXX append command as string and enclosed by ' or " (escape ' or " in command)
        if type(command) not in (list, tuple):
            command = [command, ]
        cmd.extend(command)
        res = local_shell(cmd)
        return res


class SCPServer(SSHServer, CopyToServer, CopyFromServer):
    """Definition of a SCP server."""

    def _create_dir(self, directory):
        """Create a directory on the server."""
        dico = { 'dir' : directory }
        magic.log.info(_("create remote directory %(dir)s...") % dico)
        cmd = "mkdir -p %(dir)s" % dico
        res = self._exec_command(cmd)
        cmd = "chmod 0700 %(dir)s" % dico
        res = self._exec_command(cmd)
        magic.log.info(_("returns %s"), res[0])
        return res

    def delete_proxy_dir(self):
        """Erase the proxy_dir directory on the server."""
        cmd = "rm -rf %s" % self.proxy_dir
        magic.log.info(_("delete remote directory %s..."), self.proxy_dir)
        res = self._exec_command(cmd)
        magic.log.info(_("returns %s"), res[0])
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
        dst = self.user + "@" +  self.host + ":" + dst
        cmd = [ "scp", "-rBCq", "-o StrictHostKeyChecking=no", src, dst]
        magic.log.info(_("copy %s to %s"), src, dst)
        res = local_shell(cmd)
        magic.log.info(_("returns %s"), res[0])
        if res[2]:
            magic.log.error(res[2])
        return res[0]

    def _copyonefrom(self, dst, convert=None):
        """Copy the file `dstfrom a server.
        Return 0 or >0 if it failed.
        `convert` is the function used to compute basename = f(convert).
        Example : dst=/home/user/dir/fname
            => scp -r log@mach:`self.proxy_dir`/f(fname) /home/user/fname

        Warning: to avoid to create /home/user/dir/fname/f(fname) when
        fname exists and is a directory, we execute:
            => scp -r log@mach:`self.proxy_dir`/f(fname) /home/user/dir/fname
            => mv /home/user/dir/fname/f(fname)/* /home/user/dir/fname/
            => rmdir /home/user/dir/fname/f(fname)
        """
        to_rename = osp.isdir(dst)
        bname = osp.basename(dst)
        if convert is not None:
            bname = convert(dst)
        src = osp.join(self.proxy_dir, bname)
        fsrc = self.user + "@" +  self.host + ":" + src
        cmd = [ "scp", "-rBCq", fsrc, dst]
        magic.log.info(_("copy %s to %s"), fsrc, dst)
        res = local_shell(cmd)
        iret = res[0]
        magic.log.info(_("returns %s"), iret)
        if res[2]:
            magic.log.error(res[2])
        if to_rename:
            try:
                iret = 0
                renametree(osp.join(dst, bname), dst)
            except OSError as err:
                iret = 1
                magic.log.error(str(err))
        return iret

# for backward compatibility
from .rsh_server import RSHServer, RCPServer
