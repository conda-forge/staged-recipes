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
Definition of a Client class to manipulate the user preferences and the
servers configuration.
"""

import os
import os.path as osp
import re
from shutil import copyfile
from collections import OrderedDict

from asrun.core import magic
from asrun.installation  import confdir
from asrun.common.rcfile import read_rcfile, write_rcfile, decode_config_line
from asrun.common.utils import get_plugin
from asrun.common.sysutils import get_home_directory, local_user, local_host
from asrun.profil import AsterProfil
from asrun.plugins.actions import ACTIONS

from asrun.backward_compatibility import bwc_client_rcname, bwc_client_deprecate_run


PREFERENCES  = 'prefs'
SERVER_CONF = 'config_serveurs'

_INFO = 'astkrc_version'
_RC_VERSION = "1.1"

# because astk and asrun use different keys...
MAPPING_ASTK_ASRUN = {
    'rep_serv' : 'aster_root',
    'login' : 'username',
    'nom_complet' : 'serveur',
}

class ClientConfig(object):
    """Manipulation of the user's preferences and the servers
    configuration."""
    # replacement dict for resources files
    _repl_read_prefs = {
        '__all__' : { '_VIDE'    : '' },
    }
    _repl_read_server = {
        '__all__' : { '_VIDE'    : '' },
        'login'   : { 'username' : local_user },
    }
    _repl_write = {
        '__all__' : { '' : '_VIDE' },
    }

    def __init__(self, rcdir, run=None):
        """Initialization.
        'run' object is only used to refresh server configurations.
        """
        bwc_client_deprecate_run(run)
        self._rcdir = osp.join(get_home_directory(), rcdir)
        # cache for user preferences and servers configuration
        self._pref  = None
        self._serv  = None
        self._serv_rcversion = None

    def rcfile(self, filename, rcdir=None):
        """Return resource filename
        """
        rcdir = rcdir or self._rcdir
        fname = bwc_client_rcname(filename)
        return osp.join(rcdir, fname)

    def check_rcdir(self):
        """Check if rcdir exists and create it if necessary.
        """
        try:
            os.makedirs(self._rcdir)
        except OSError:
            pass

    def init_user_resource(self, filename):
        """Initialize 'rcdir'/'filename' if it does not exist.
        """
        if not osp.exists(self.rcfile(filename)):
            self.check_rcdir()
            copyfile(self.rcfile(filename, osp.join(confdir, 'astkrc')), self.rcfile(filename))

    def get_user_preferences(self, force=False):
        """Return user preferences.
        """
        if force or not self._pref:
            self.init_user_resource(PREFERENCES)
            self._pref = {}
            read_rcfile(self.rcfile(PREFERENCES), self._pref,
                        replacement=self._repl_read_prefs)
        return self._pref

    def set_user_preferences(self, key, value):
        """Allow to change a preference value."""
        self._pref[key] = value

    def init_server_config(self, force=False, refresh=False):
        """Return servers configuration from 'rcdir'/config_serveurs
        """
        if force or not self._serv:
            self.init_user_resource(SERVER_CONF)
            self._serv = OrderedDict()
            read_rcfile(self.rcfile(SERVER_CONF), self._serv,
                        mcfact_key='serveur', mcsimp=['vers', 'noeud'],
                        replacement=self._repl_read_server)
            if self._serv.get(_INFO) is not None:
                try:
                    self._serv_rcversion = '%.1f' % self._serv[_INFO]
                except:
                    pass
                del self._serv[_INFO]
            self._pass_backward_compatibility()
        if refresh:
            self.refresh_server_config()

    def get_server_rcinfo(self):
        """Return informations about the servers resource file.
        """
        return self._serv_rcversion

    def get_server_list(self):
        """Return the list of available servers.
        """
        if not self._serv:
            return []
        return list(self._serv.keys())

    def get_server_config(self, server, use_ip=False):
        """Return the configuration of 'server'.
        'server' is the label or the full name if 'use_ip'.
        """
        self.init_server_config()
        if use_ip:
            dname = dict([(ds["nom_complet"], key) for key, ds in list(self._serv.items())])
            server = dname.get(server, "")
        return self._serv.get(server, {})

    def with_export_keys(self, cfg):
        """Change a server configuration dict (return a copy)."""
        # exists because of use of different labels in client/server !
        # Actually, change config_serveurs keys into export ones.
        dres = {}
        for key, val in list(cfg.items()):
            dres[MAPPING_ASTK_ASRUN.get(key, key)] = val
        return dres

    def get_dict_server_config(self):
        """Return the dict of the configuration of all servers
        """
        return self._serv

    def save_server_config(self, to=None):
        """Write 'rcdir'/config_serveurs with current values.
        """
        to = to or self.rcfile(SERVER_CONF)
        write_rcfile(to, self._serv,
                     mcfact_key='serveur', mcsimp=['vers', 'noeud'],
                     replacement=self._repl_write)

    def save_user_preferences(self, to=None):
        """Write 'rcdir'/prefs with current values.
        """
        to = to or self.rcfile(PREFERENCES)
        write_rcfile(to, self._pref,
                     replacement=self._repl_write)

    def refresh_server_config(self, server_list=None):
        """Refresh configuration of each server presents in self._serv."""
        run = magic.run
        assert run is not None, "AsterRun object is necessary to call refresh_server_config"
        server_list = server_list or self.get_server_list()
        for server in server_list:
            prof = self.init_profil(server)
            if not prof:
                continue
            cfg = self._serv.get(server)
            schema_name = cfg.get('schema_info') or ACTIONS['info']['default_schema']
            schem = get_plugin(schema_name)
            _, output = schem(prof, [], print_output=False)
            self._serv[server].update(self._parse_info(output))

    def init_profil(self, server):
        """Create a *template* profil for a server."""
        cfg = self._serv.get(server)
        if cfg.get('etat') != "on":
            return None
        return serv_infos_prof(cfg)

    def _parse_info(self, content):
        """Parse information write by as_run --info"""
        info = {}
        mat = re.search("@SERV_VERS@(.*)@FINSERV_VERS@", content, re.DOTALL)
        if mat is not None:
            try:
                info["asrun_vers"] = mat.group(1).strip()
            except:
                pass
        mat = re.search("@PARAM@(.*)@FINPARAM@", content, re.DOTALL)
        if mat is not None:
            for line in mat.group(1).splitlines():
                try:
                    key, val = decode_config_line(line)
                    info[key] = val
                except:
                    pass
        mat = re.search("@VERSIONS@(.*)@FINVERSIONS@", content, re.DOTALL)
        if mat is not None:
            lvers = []
            for line in mat.group(1).splitlines():
                try:
                    key, val = decode_config_line(line)
                    lvers.append(val)
                except:
                    pass
            lvers = list(map(str, lvers))
            info['vers'] = ' '.join(lvers)
        info['versions_ids'] = OrderedDict.fromkeys(lvers)
        mat = re.search("@VERSIONS_IDS@(.*)@FINVERSIONS_IDS@", content, re.DOTALL)
        if mat is not None:
            for line in mat.group(1).splitlines():
                try:
                    key, val = decode_config_line(line)
                    info['versions_ids'][key] = val
                except:
                    pass
        mat = re.search("@NOEUDS@(.*)@FINNOEUDS@", content, re.DOTALL)
        if mat is not None:
            lnode = []
            for line in mat.group(1).splitlines():
                try:
                    key, val = decode_config_line(line)
                    lnode.append(val)
                except:
                    pass
            info['noeud'] = ' '.join(lnode)
        return info

    def _pass_backward_compatibility(self):
        """Pass backward compatibility conversion.
        """
        for server in self.get_server_list():
            cfg = self._serv.get(server)
            if cfg.get("asrun_vers") is not None and cfg["asrun_vers"] < "01.08.00":
                cfg["rep_serv"] = re.sub("/ASTK/ASTK_SERV/bin", "/ASTK/ASTK_SERV", cfg["rep_serv"])
            else:
                cfg["rep_serv"] = re.sub("/ASTK/ASTK_SERV/bin", "", cfg["rep_serv"])
                cfg["rep_serv"] = re.sub("/ASTK/ASTK_SERV",     "", cfg["rep_serv"])
            self._serv[server].update(cfg)


def serv_infos_prof(cfg):
    """Return an AsterProfil with the parameters to request a server."""
    dmap = MAPPING_ASTK_ASRUN
    run = magic.run
    prof = AsterProfil(run=run)
    serv = cfg.get("nom_complet") or cfg.get(dmap["nom_complet"])
    login = cfg.get("login") or cfg.get(dmap["login"])
    root = cfg.get("rep_serv") or cfg.get(dmap["rep_serv"])
    assert not (serv is None or login is None or root is None)
    prof["serveur"] = serv
    prof["username"] = login
    prof["aster_root"] = root
    prof["mclient"] = local_host
    if cfg.get("plate-forme"):
        prof["platform"] = cfg["plate-forme"]
    value = cfg.get("protocol_exec")
    if not value:
        value = "asrun.plugins.server.SSHServer"
        if run["remote_shell_protocol"] and run["remote_shell_protocol"].find("RSH") > -1:
            value = "asrun.plugins.server.RSHServer"
    prof["protocol_exec"] = value
    value = cfg.get("protocol_copyfrom")
    if not value:
        value = "asrun.plugins.server.SCPServer"
        if run["remote_copy_protocol"] and run["remote_copy_protocol"].find("RCP") > -1:
            value = "asrun.plugins.server.RCPServer"
    prof["protocol_copyfrom"] = value
    value = cfg.get("protocol_copyto")
    if not value:
        value = "asrun.plugins.server.SCPServer"
        if run["remote_copy_protocol"] and run["remote_copy_protocol"].find("RCP") > -1:
            value = "asrun.plugins.server.RCPServer"
    prof["protocol_copyto"] = value
    value = cfg.get("proxy_dir", "/tmp")
    prof["proxy_dir"] = value
    return prof
