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
Get cpu and memory informations of a list of machines.
"""

import os
import os.path as osp

from asrun.common.i18n import _
from asrun.config       import build_config_of_version, AsterConfig
from asrun.mystring     import ufmt
from asrun.common_func  import get_tmpname
from asrun.contrib      import convert2html
from asrun.thread       import Task, Dispatcher
from asrun.repart       import ResourceManager


def GetInfos(run, *l_hosts):
    run.PrintExitCode = False
    if len(l_hosts) < 1:
        run.parser.error(
                _("'--%s' requires one or more arguments") % run.current_action)
    numthread = run.GetCpuInfo('numthread')
    # request all hosts
    host_infos = {}
    task = GetInfosTask(run=run, silent=run["silent"], host_infos=host_infos)
    check = Dispatcher(l_hosts, task, numthread)
    run.DBG(check.report())
    # build ResourceManager object and print its representation
    hostrc = ResourceManager(host_infos)
    result = hostrc.hostinfo_repr()
    if run.get('output'):
        with open(run['output'], 'w') as f:
            f.write(result)
        print(ufmt(_('The results have been written into the file : %s'), run['output']))
    else:
        print(result)


def ConvertToHtml(run, *args):
    """Convert a file into html format.
    """
    run.PrintExitCode = False
    # ----- check argument
    if len(args) != 1:
        run.parser.error(_("'--%s' requires one argument") % run.current_action)
    if run.get('output') is None:
        run.parser.error(_("'--%s' requires --output=FILE option") % run.current_action)

    ftmp = get_tmpname(run, run['tmp_user'], basename='convert_html')
    run.ToDelete(ftmp)
    kret = run.Copy(ftmp, args[0], niverr='<F>_COPYFILE')

    out = convert2html(ftmp)
    out.sortieHTML(run['output'])


class GetInfosTask(Task):
    """Task to retreive informations from a host.
    """
    # declare attrs
    run = host_infos = silent = None

    def execute(self, host, **kwargs):
        """Function called for each item of the stack
        (up to 'nbmaxitem' at each called).
        Warning : 'execute' should not modify attributes.
        """
        cpu = mem = 0
        connect = self.run.Ping(host)
        if connect:
            cpu = self.run.GetCpuInfo('numcpu', mach=host) or 0
            mem = self.run.GetMemInfo('memtotal', mach=host) or 0
        return host, connect, cpu, mem


    def result(self, host, connect, cpu, mem, **kwargs):
        """Function called after each task to treat results of 'execute'.
        Arguments are 'execute' results + keywords args.
        'result' is called thread-safely, so can store results in attributes.
        """
        if not self.silent:
            print(_("checking %s... ") % host, end="")
            if not connect:
                print(_("connection failed"))
            elif cpu == mem == 0:
                print(_("no result"))
            else:
                print(_("ok"), "cpu=%s mem=%s" % (cpu, mem))
        self.host_infos[host] = { "cpu" : cpu, "mem" : mem }


# to be used by Code_Aster/UMAT testcases
def make_shared(lib, srcfiles, conf=None, compiler_command=None):
    """Produce a shared library from a list of source files
    using the provided command line or a AsterConfig object."""
    # command line
    cmd = []
    # using the provided command line
    if compiler_command is not None:
        cmd.append(compiler_command)
    elif conf is None:
        # supposed to exist in pwd
        assert osp.exists("config.txt"), \
            "at least a command line, a AsterConfig object or config.txt file is required!"
        conf = AsterConfig("config.txt")
    # using AsterConfig object
    if conf is not None:
        cmd.append(conf['F90'][0] or 'gfortran')
        cmd.extend(conf['OPTF90_O'])
        cmd.extend(conf['INCLF90'])
    cmd.extend(["-shared", "-o", lib])
    if type(srcfiles) not in (list, tuple):
        srcfiles = [srcfiles,]
    cmd.extend(srcfiles)
    cmdline = ' '.join(cmd)
    # "-c" should not be in OPTF...
    cmdline = cmdline.replace(" -c ", " ")
    # execute
    os.system(cmdline)
    assert osp.exists(lib), "ERROR: library not built!"


def MakeShared(run, *l_src):
    """Helper function to produce a shared library from a list of source files.
    """
    if len(l_src) < 1:
        run.parser.error(
                _("'--%s' requires one or more arguments") % run.current_action)
    if run.get('output') is None:
        run.parser.error(_("you must use '-o filename.so' or '--output=filename.so' "
            "to give the name of the shared library to build."))

    # get config object
    run.PrintExitCode = False
    run.check_version_setting()
    conf = build_config_of_version(run, run['aster_vers'])

    # set per version environment
    for f in conf.get_with_absolute_path('ENV_SH'):
        run.AddToEnv(f)

    make_shared(run['output'], l_src, conf)
