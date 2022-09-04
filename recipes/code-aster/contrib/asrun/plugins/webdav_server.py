# -*- coding: utf-8 -*-

# ==============================================================================
# COPYRIGHT (C) 2015 ALNEOS Luca DALL'OLIO             WWW.ALNEOS.COM
# COPYRIGHT (C) 2015  EDF R&D                        WWW.CODE-ASTER.ORG
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
This module defines a WebDAV client (asrun server) for copying files.

Shell commands are issued by REST calls.

If you use astk, create a new server. In server configuration,
(.astkrc/config_serveurs) enter::
    nom_complet : <server:port>
    login : <user:pass>
    protocol_exec : asrun.plugins.webdav_server.WebDAVCallServer
    protocol_copyto : asrun.plugins.webdav_server.WebDAVFilesystemServer
    protocol_copyfrom : asrun.plugins.webdav_server.WebDAVFilesystemServer
    schema_actu : asrun.plugins.webdav_server.actu
    rep_serv : /ads

The plugin should be able to fully configure the server, if you hit refresh.

Optional steps (in case you use as_run, and you're writing your .export file by hand)
P aster_root /ads
P proxy_dir  /ads/data/tmp
P protocol_exec asrun.plugins.webdav_server.WebDAVCallServer
P protocol_copyto asrun.plugins.webdav_server.WebDAVFilesystemServer
P protocol_copyfrom asrun.plugins.webdav_server.WebDAVFilesystemServer

Since the plugin uses curl, it must have curl installed.
Additional configuration (authenticating proxy, ...) can be done in ``~/.curlrc``
or ``%userprofile%/_curlrc in windows``
Please see curl documentation for details http://curl.haxx.se/

"""
import os.path as osp
import urllib.request, urllib.parse, urllib.error
import xml.etree.cElementTree as xml

from asrun.common.i18n import _
from asrun.common.sysutils import local_full_host
from asrun.common.utils import unique_basename
from asrun.core import magic
from asrun.profil import AsterProfil
from asrun.core.server import build_server_from_profile, TYPES
from asrun.core.server import ExecServer, CopyFromServer, CopyToServer, local_shell
from asrun.job import parse_actu_result, print_actu_result
from asrun.plugins.default import _call_actu


class WebDAVCallServer(ExecServer):
    """Definition of a WebDAV call server."""

    def __init__(self, host, user, **kwargs):
        """Initialization"""
        magic.log.debug("WebDAVCallServer init")
        super(WebDAVCallServer, self).__init__(host, user, **kwargs)

    def support_display_forwarding(self):
        """Tell if the protocol supports display forwarding."""
        return False

    def prepare_curl_command(self, action, address, form={}, input="",
                             output="", header={}):
        """This creates the command arguments list (originally extracted from
        _exec_command) so that is can be used independently from local_shell,
        without code duplication."""
        cmd = ["curl"]
        if action not in ("PROPFIND",):
            cmd += ["--silent"]
        if ":" in self.user:
            cmd += ["--user " + self.user]
            cmd += ["--anyauth"]
        if len(input) >= 1:
            cmd += ["--upload-file " + input]
        if len(output) >= 1:
            cmd += ["--output " + output]
        if len(form) >= 1:
            cmd += ["--form \""]
            for name, content in list(form.items()):
                cmd += [name + "=" + content]
            cmd += ["\""]
        if len(header) >= 1:
            #cmd += ["-i"]
            for name, content in list(header.items()):
                cmd += ["--header \"" + name + ": " + content + "\""]
        cmd += ["-X ", action, "--url ",
                urllib.parse.quote(self.host, safe=":/") + urllib.parse.quote(address)]
        return cmd

    def _exec_command(self, command, display_forwarding=False, **opts):
        """Execute a command line on the server."""
        # XXX append command as string and enclosed by ' or " (escape ' or " in command)
        if type(command) not in (list, tuple):
            cmdargs = self.prepare_curl_command("POST", address=self.aster_root)
        else:
            address = command[0]
            args = command[1:]
            magic.log.debug("Calling a post url %s command : %s" % (address, args))
            cmdargs = self.prepare_curl_command("POST", address=address,
                        form={"args" : " ".join(args)})
            try:
                output = local_shell(cmdargs)
            except:
                magic.log.debug("Command failed : %s" % cmdargs)
        return output

class WebDAVFilesystemServer(WebDAVCallServer, CopyToServer, CopyFromServer):
    """
    This class defines a WebDAV server for copying files.

    In server configuration, enter:
    protocol_exec : asrun.plugins.webdav_server.WebDAVCallServer
    protocol_copyto : asrun.plugins.webdav_server.WebDAVFilesystemServer
    protocol_copyfrom : asrun.plugins.webdav_server.WebDAVFilesystemServer
    """
    def __init__(self, host, user, **kwargs):
        super(WebDAVFilesystemServer, self).__init__(host, user, **kwargs)
        self.jobid = kwargs.get('jobid', 0)
        self.remote_basedir = kwargs['proxy_dir']
        if ":" in user:
            user = user.split(":")[0]
        name = '%s-%s' % (user, self.jobid)
        name = name.strip('-')

        self.proxy_dir = osp.join(self.remote_basedir, name)

    def _create_dir(self, directory):
        """Create a directory on the server."""
        magic.log.info(_("create remote directory %s...") % directory)
        dirs = [d for d in directory.split('/') if d]
        if not dirs:
            return
        cwd = "/"
        for dir in dirs:
            cmdargs = self.prepare_curl_command("MKCOL", address=cwd + dir)
            res = local_shell(cmdargs)
            magic.log.info(_("creating folder %s"), dir)
            cwd += dir + "/"
        magic.log.info(_("returns %s"), res)
        return res

    def delete_proxy_dir(self):
        """Erase the proxy_dir directory on the server."""
        magic.log.info(_("delete remote directory %s..."), self.proxy_dir)
        cmdargs = self.prepare_curl_command("PROPFIND", address=self.proxy_dir +"/",
                                            header={"Depth":"1"})
        res = local_shell(cmdargs)
        iret=res[0]
        if iret == 0:
            tree = xml.fromstring(res[1])
            files = [elem.find('.//{DAV:}href').text \
                     for elem in tree.findall('{DAV:}response')]
            for afile in files:
                cmdargs = self.prepare_curl_command("DELETE", address=afile)
                local_shell(cmdargs)
            cmdargs = self.prepare_curl_command("DELETE", address=self.proxy_dir)
            local_shell(cmdargs)
        magic.log.info(_("returns %s"), iret)
        return iret

    def _copyoneto(self, src, convert=None):
        """Copy the file `srcto a server.
        Return 0 or >0 if it failed.
        `convert` is the function used to compute basename = f(convert).
        """
        bname = osp.basename(src)
        if convert is not None:
            bname = convert(src)
        dst = self.proxy_dir + '/' + bname
        cmdargs = self.prepare_curl_command("PUT", address=dst, input=src)
        res = local_shell(cmdargs)
        magic.log.info(_("copy %s to %s"), src, dst)
        magic.log.info(_("returns %s"), res)
        return res[0]  # WORKAROUND default.py line 75 : if iret != 0:

    def _copyonefrom(self, dst, convert=None):
        """Copy the file `dstfrom a server.
        Return 0 or >0 if it failed.
        `convert` is the function used to compute basename = f(convert).
        """
        bname = osp.basename(dst)
        if convert is not None:
            bname = convert(dst)
        src = self.proxy_dir + '/' + bname
        cmdargs = self.prepare_curl_command("GET", address=src, output=dst)
        res = local_shell(cmdargs)
        magic.log.info(_("copy %s to %s"), src, dst)
        magic.log.info(_("returns %s"), res)
        return res[0]

def actu(prof, args, **kwargs):
    """Call --actu action on a server
    + call automatically --get_results if the job is ended."""
    iret, output = _call_actu(prof, args)
    result = parse_actu_result(output)
    print_actu_result(*result)
    if iret == 0 and result[0] == "ENDED":
        iret = get_results(prof, args)
    return iret, output

def get_results(prof, args, **kwargs):
    """Download result files from the server."""
    run = magic.run

    magic.log.info(_("get result files from the server"))
    # read studyid
    study_prof = get_study_export(prof)
    if study_prof is None:
        return 4
    studyid = study_prof['studyid'][0]
    forig = osp.join(run['tmp_user'], "%s.orig.export" % studyid)

    # read server informations
    scopy = build_server_from_profile(study_prof, TYPES.COPY_FROM, jobid=studyid)
    # get original export
    iret = scopy.copyfrom(forig)
    if iret != 0:
        magic.log.warn(_("the results seem already downloaded."))
        return iret
    oprof = AsterProfil(forig, run)
    magic.run.DBG("original export :\n%s" % repr(oprof), all=True)

    run_on_localhost = scopy.is_localhost()
    # copy results files
    if not run_on_localhost:
        local_resu = oprof.get_result().get_on_serv(local_full_host)
        local_nom, local_other = local_resu.get_type('nom', with_completion=True)
        iret = scopy.copyfrom(convert=unique_basename, *local_other.topath())
        jret = scopy.copyfrom(*local_nom.topath())
        iret = max(iret, jret)
        local_resu = local_resu.topath()
    else:
        local_resu = []

    remote_resu = oprof.get_result().get_on_serv(scopy.host, scopy.user).topath()
    all = set(oprof.get_result().topath())
    all.difference_update(local_resu)
    all.difference_update(remote_resu)
    if len(all) > 0:
        magic.log.warn(_("files on a third host should have been copied "
            "at the end of the calculation (if possible) : %s"),
            [e.repr() for e in all])

    # remove remote repository
    if iret == 0:
        scopy.delete_proxy_dir()
    return iret

def get_study_export(prof):
    """Return the original export."""
    run = magic.run
    # read server informations
    jobid = prof['jobid'][0]
    serv = build_server_from_profile(prof, TYPES.COPY_FROM, jobid=jobid)

    dst = jobid + ".export"
    iret = serv.copyfrom(dst)
    if iret != 0:
        return None

    # read studyid
    study_prof = AsterProfil(dst, run)
    return study_prof
