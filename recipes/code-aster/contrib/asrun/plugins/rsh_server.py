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
This module defines the old server types :
    - RSH to execute commands on a remote server,
    - RCP to copy files to and from a remote server.

Note that these servers types are deprecated and are present only
for backward compatibility.
"""


import os.path as osp

from asrun.common.i18n import _
from asrun.core        import magic
from asrun.core.server import ( ExecServer, CopyFromServer, CopyToServer,
                                local_shell )


class RSHServer(ExecServer):
    """Definition of a RSH server."""

    def __init__(self, host, user, **kwargs):
        """Initialization"""
        magic.log.debug("RSHServer init")
        super(RSHServer, self).__init__(host, user, **kwargs)

    def support_display_forwarding(self):
        """Tell if the protocol supports display forwarding."""
        return True

    def _exec_command(self, command, display_forwarding=False, **opts):
        """Execute a command line on the server."""
        cmd = [ "rsh",
                "-n",
                "-l", self.user,
                self.host ]
        #XXX append command as string and enclosed by ' or " (escape ' or " in command)
        if type(command) not in (list, tuple):
            command = [command, ]
        cmd.extend(command)
        res = local_shell(cmd)
        return res


class RCPServer(RSHServer, CopyToServer, CopyFromServer):
    """Definition of a RCP server."""

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
        cmd = [ "rcp", "-r", src, dst]
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
            => rcp -r log@mach:`self.proxy_dir`/fname /home/user/fname

        Warning: to avoid to create /home/user/dir/fname/fname when
        fname is a directory, we execute:
            => rcp -r log@mach:`self.proxy_dir`/fname /home/user/dir/
        """
        bname = osp.basename(dst)
        if convert is not None:
            bname = convert(dst)
        src = osp.join(self.proxy_dir, bname)
        fsrc = self.user + "@" +  self.host + ":" + src
        cmd = [ "rcp", "-r", fsrc, dst]
        magic.log.info(_("copy %s to %s"), fsrc, dst)
        res = local_shell(cmd)
        magic.log.info(_("returns %s"), res[0])
        if res[2]:
            magic.log.error(res[2])
        return res[0]
