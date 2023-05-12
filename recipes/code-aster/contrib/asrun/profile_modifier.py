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
This module provides functions to modify a profile.
"""

import os
from asrun.installation import datadir
from asrun.common.i18n  import _
from asrun.mystring     import ufmt
from asrun.config       import build_config_from_export
from asrun.common_func  import get_tmpname
from asrun.common.utils import YES, YES_VALUES, get_plugin

SEPAR = '%NEXT%'

class ProfileModifier(object):
    """Change a profile for a special service.
    May be deactivated if run from the client or server side."""
    service = 'service_name'

    def __init__(self, prof, run=None, on_client_side=False):
        """Init."""
        self.run       = run
        self.prof_orig = prof
        self.new_prof  = self.prof_orig.copy()
        self.special   = self.prof_orig['special'][0].split(SEPAR)
        self.on_client_side = on_client_side

    def modify(self):
        """Modifications for all services.
        """
        # keep arguments
        # empty data and result
        self.new_prof.data = []
        self.new_prof.resu = []

        # set some parameters
        self.new_prof['nomjob']  = '%s_%s' % (self.prof_orig['nomjob'][0], self.service)
        self.new_prof['actions'] = 'make_etude'
        self.new_prof['ncpus']   = 1
        self.new_prof['consbtc'] = YES
        self.new_prof['soumbtc'] = YES

        # remove some parameters :
        for p in ('special',):
            del self.new_prof[p]

    def check_filename(self, name_in):
        """If we start execution on a remote node, we must add user@'here'."""
        node = self.prof_orig['noeud'][0].split('.')[0]  # without domain name
        user, host = self.run.system.getuser_host()
        name_out = name_in
        if node != host:
            name_out = '%s@%s:%s' % (user, host, name_in)
        return name_out

    def return_profile(self):
        """Return changed profile."""
        return self.new_prof


class ProfileModifierMeshtool(ProfileModifier):
    """Modifier for meshtool service."""
    service = 'meshtool'

    def modify(self):
        """Modifications for meshtool service.
        """
        super(ProfileModifierMeshtool, self).modify()

        # job name
        self.new_prof['nomjob']  = '%s_mesh' % self.prof_orig['nomjob'][0]

        # commands file
        fcomm = os.path.join(datadir, 'meshtool.comm')
        self.new_prof.Set('D',
            { 'path' : fcomm, 'ul' : 1, 'type' : 'comm',
           'isrep' : False, 'compr' : False})

        # special : mesh IN (unit 71), mesh OUT (unit 72)
        assert len(self.special) >= 3
        self.new_prof.parse("""%s 71\n%s 72""" % tuple(self.special[1:3]))

        # parameter file : field 4 and next
        fpara = get_tmpname(self.run, self.run['shared_tmp'], basename='meshtool.para')
        self.run.Delete(fpara)
        txt = os.linesep.join(self.special[3:])
        with open(fpara, 'w') as f:
            f.write(txt)
        self.new_prof.Set('D',
            { 'path' : self.check_filename(fpara), 'ul' : 70, 'type' : 'libr',
           'isrep' : False, 'compr' : False})


class ProfileModifierConvbase(ProfileModifier):
    """Modifier for convbase service."""
    service = 'convbase'

    def modify(self):
        """Modifications for convbase service.
        """
        super(ProfileModifierConvbase, self).modify()

        # commands file
        fcomm = os.path.join(datadir, 'convbase.comm')
        self.new_prof.Set('D',
            { 'path' : fcomm, 'ul' : 1, 'type' : 'comm',
           'isrep' : False, 'compr' : False})

        # special : base IN, base OUT
        assert len(self.special) >= 3
        self.new_prof.parse("""%s\n%s""" % tuple(self.special[1:3]))


class ProfileModifierStanley(ProfileModifier):
    """Modifier for stanley service."""
    service = 'stanley'

    def modify(self):
        """Modifications for stanley service."""
        super(ProfileModifierStanley, self).modify()

        # job name
        self.new_prof['nomjob']  = '%s_post' % self.prof_orig['nomjob'][0]

        # commands file
        fcomm = os.path.join(datadir, 'stanley_post.comm')
        self.new_prof.Set('D',
            { 'path' : fcomm, 'ul' : 1, 'type' : 'comm', 'isrep' : False, 'compr' : False})

        # special : "R base repertoire flag 0"
        assert len(self.special) >= 2
        self.new_prof.parse(self.special[1])


class ProfileModifierDistribution(ProfileModifier):
    """Modifier for distributed calculations."""
    service = 'distribution'

    def modify(self):
        """Modifications for distribution service.
        """
        self.new_prof['actions'] = self.service
        del self.new_prof['distrib']
        setMasterParameters(self.new_prof)


MASTER_PARAMETERS = {
    'mpi_nbcpu': 1,
    'mpi_nbnoeud': 1,
    'ncpus': 1,
    # empty means "computed during execution (read from config file)"
    'time_limit': None,
    'memory_limit': None,
}

def setMasterParameters(prof):
    """Store original parameters for future slaves"""
    for param, value in list(MASTER_PARAMETERS.items()):
        prof['MASTER_%s' % param] = prof[param]
        if value is not None:
            prof[param] = value

def setSlaveParameters(prof):
    """Restore parameters to assign them to a slave profile"""
    for param in list(MASTER_PARAMETERS.keys()):
        value = prof['MASTER_%s' % param][0]
        if value != "":
            prof[param] = value


class ProfileModifierMultiple(ProfileModifier):
    """Modifier for distributed calculations."""
    service = 'multiple'

    def modify(self):
        """Modifications for "multiple" service.
        """
        self.new_prof['actions'] = self.service
        self.new_prof['multiple_actions'] = self.prof_orig['actions']
        del self.new_prof['multiple']


class ProfileModifierExecTool(ProfileModifier):
    """Modifier for extern tool."""
    service = 'exectool'

    def modify(self):
        """Modifications for extern tool."""
        if self.on_client_side:
            return
        # get executable
        dbg = self.prof_orig['debug'][0]
        if dbg == '':
            dbg = 'nodebug'
        if self.prof_orig.Get('D', typ='exec'):
            d_exe = self.prof_orig.Get('D', typ='exec')[0]
        else:
            d_exe = { 'path' : '?', 'type' : 'exec', 'isrep' : False, 'compr' : False, 'ul' : 0 }
            conf = build_config_from_export(self.run, self.prof_orig)
            if dbg == 'nodebug':
                d_exe['path'] = conf.get_with_absolute_path('BIN_NODBG')[0]
            else:
                d_exe['path'] = conf.get_with_absolute_path('BIN_DBG')[0]
        # add valgrind command
        if self.prof_orig['exectool'][0] == '':
            self.run.Mess(_('"exectool" is not defined !'), '<F>_PROGRAM_ERROR')
        cmd = self.prof_orig['exectool'][0]
        if self.run.get(cmd):
            cmd = self.run[cmd] + ' '
        else:
            cmd += ' '
        if self.run.IsRemote(d_exe['path']):
            self.run.Mess(_('"exectool" can not be used with a remote executable.'), "<F>_ERROR")
        cmd += d_exe['path'] + ' "$@" 2>&1'
        # write script
        exetmp = get_tmpname(self.run, self.run['shared_tmp'], basename='front_exec')
        cmd += '\n' + 'rm -f %s' % exetmp
        with open(exetmp, 'w') as f:
            f.write(cmd)
        os.chmod(exetmp, 0o755)
        d_exe['path'] = exetmp
        # change profile
        del self.new_prof['exectool']
        self.new_prof.Del('D', typ='exec')
        self.new_prof.Set('D', d_exe)


def ModifierFactory(service, prof, run=None, on_client_side=False):
    """Return the ProfileModifier object to apply."""
    pm_name = {
        'meshtool' : ProfileModifierMeshtool,
        'stanley' : ProfileModifierStanley,
        'convbase' : ProfileModifierConvbase,
        'distribution' : ProfileModifierDistribution,
        'exectool' : ProfileModifierExecTool,
        'multiple' : ProfileModifierMultiple,
    }
    modifier = pm_name.get(service)
    if not modifier:
        return None
    return modifier(prof, run, on_client_side)


def apply_special_service(prof, run, on_client_side=False):
    """Return the profile modified for the "special" service."""
    # allow customization of the modifier
    if run.get('schema_profile_modifier'):
        schem = get_plugin(run['schema_profile_modifier'])
        run.DBG("calling plugin : %s" % run['schema_profile_modifier'])
        serv, prof = schem(prof, on_client_side)

    serv = prof['special'][0].split(SEPAR)[0]
    if serv == "":
        if prof['distrib'][0] in YES_VALUES:
            serv = 'distribution'
        elif prof['exectool'][0] != '':
            serv = 'exectool'
        elif prof['multiple'][0] in YES_VALUES:
            serv = 'multiple'
        else:
            return serv, prof

    modifier = ModifierFactory(serv, prof, run, on_client_side)
    if modifier is None:
        run.Mess(ufmt(_("unknown service name : %s"), serv), '<F>_ERROR')
    modifier.modify()
    new_prof =  modifier.return_profile()
    return serv, new_prof
