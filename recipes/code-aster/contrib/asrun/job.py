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
This module gives functions to manipulate Code_Aster jobs :
- return informations from astk server configuration,
- edit output or error file,
- get job status,
- kill and delete the job files,
- search strings in output of a job,
- purge 'flasheur' directory.
The functions are called by an AsterRun object.
"""

import os
import os.path as osp
import signal
import glob
import re
from collections import namedtuple

from asrun.common.i18n   import _
from asrun.common.rcfile import get_nodepara
from asrun.mystring      import convert, ufmt, to_unicode
from asrun.profil        import AsterProfil
from asrun.batch         import BatchSystemFactory
from asrun.system        import shell_cmd
from asrun.common_func   import get_tmpname, flash_filename, edit_file, is_localhost2
from asrun.common.utils  import YES_VALUES, dhms2s, get_plugin
from asrun.toolbox       import ConvertToHtml
from asrun.backward_compatibility import bwc_edit_args
from asrun.plugins.actions import ACTIONS
from asrun.maintenance   import get_aster_version


def SetParser(run):
    """Configure the command-line parser, add options name to store to the list,
    set actions informations.
    run : AsterRun object which manages the execution
    """
    acts_descr = {
        'info' : {
            'method' : Info,
            'syntax' : '',
            'help'   : _('Returns informations from astk server configuration : '\
                    'batch, interactive (yes/no, limits), compute nodes, '\
                    'versions')
        },
        'actu' : {
            'method' : Actu,
            'syntax' : 'job_number job_name mode',
            'help'   : _('Returns the state, diagnosis, execution node, spent '\
                    'cpu time and working directory of a job')
        },
        'edit' : {
            'method' : Edit,
            'syntax' : 'job_number job_name mode output|error',
            'help'   : _('Opens output or error file')
        },
        'del' : {
            'method' : Del,
            'syntax' : 'job_number job_name mode [node] [--signal=...]',
            'help'   : _('Kill a job and delete related files')
        },
        'purge_flash' : {
            'method' : Purge,
            'syntax' : 'job_number1 [job_number2 [...]]]',
            'help'   : _('Delete files of jobs which are NOT in the list')
        },
        'tail' : {
            'method' : Tail,
            'syntax' : 'job_number job_name mode fdest nb_lines [regexp]',
            'help'   : _('Output the last part of fort.6 file or filter lines ' \
                    'matching a pattern')
        },
        'convert_to_html' : {
            'method' : ConvertToHtml,
            'syntax' : '[user@machine:]file --output=FILE',
            'help'   : _('Convert a file (may be on a remote machine) into html '
                'format and write result to FILE'),
        },
    }
    opts_descr = {
        'signal' : {
            'args'   : ('--signal', ),
            'kwargs' : {
                'action'  : 'store',
                'default' : 'KILL',
                'choices' : ('KILL', 'USR1'),
                'dest'    : 'signal',
                'help'    : _('signal to the job (KILL|USR1)')
            }
        },
        'result_to_output' : {
            'args'   : ('--result_to_output', ),
            'kwargs' : {
                'action'  : 'store_true',
                'default' : False,
                'dest'    : 'result_to_output',
                'help'    : _('writes result to stdout instead of FILE')
            }
        },
    }
    title = 'Options for operations on jobs'
    run.SetActions(
            actions_descr = acts_descr,
            actions_order = ['info', 'actu', 'edit', 'tail', 'del', 'purge_flash',
                    'convert_to_html'],
            group_options=True, group_title=title, actions_group_title=False,
            options_descr = opts_descr,
    )


def Info(run, *args):
    """Return informations from astk server configuration.
    """
    if len(args) > 0:
        run.parser.error(_("'--%s' requires no argument") % run.current_action)

    on_machref = run.get('rep_agla', 'local') != 'local'

    # astk server version
    l_v = run.__version__.split('.')
    try:
        svers = '.'.join(['%02d' % int(i) for i in l_v])
    except ValueError:
        svers = run.__version__
    output = ["@SERV_VERS@", svers, "@FINSERV_VERS@"]

    # all these parameters are necessary
    output.append("@PARAM@")
    output.extend(['%s : %s' % (p, run[p]) \
        for p in (
            'protocol_exec', 'protocol_copyto', 'protocol_copyfrom', 'proxy_dir',
            'plate-forme',
            'batch',
            'batch_memmax', 'batch_tpsmax', 'batch_nbpmax', 'batch_mpi_nbpmax',
            'interactif',
            'interactif_memmax', 'interactif_tpsmax', 'interactif_nbpmax',
            'interactif_mpi_nbpmax',
            )])
    # and optional ones
    for act in list(ACTIONS.keys()):
        p = 'schema_%s' % act
        if run.get(p) is not None and run[p].strip() != '':
            output.append('%s : %s' % (p, run[p]))
    output.append("@FINPARAM@")

    # Code_Aster versions
    output.append("@VERSIONS@")
    lvers = run.get_ordered_versions()
    output.extend(['vers : %s' % v for v in lvers])
    output.append("@FINVERSIONS@")

    output.append("@DEFAULT_VERSION@")
    output.append('default_vers : %s' % osp.basename(run.get('default_vers', '')))
    output.append("@FINDEFAULT_VERSION@")

    output.append("@VERSIONS_IDS@")
    for vers in lvers:
        res = get_aster_version(vers, error=False)
        if res:
            output.append("{name} : {num[0]}.{num[1]}.{num[2]}"
                          .format(name=vers, num=res))
    output.append("@FINVERSIONS_IDS@")

    output.append("@NOEUDS@")
    output.extend(['noeud : %s' % n for n in run.get('noeud', '').split()])
    output.append("@FINNOEUDS@")

    # batch scheduler informations
    if run['batch'] in YES_VALUES:
        l_queue_group = run.get('batch_queue_group', '').split()
        l_group = []
        for group in l_queue_group:
            l_cl = run.get('batch_queue_%s' % group, '').split()
            if len(l_cl) > 0:
                l_group.append(group)
        if len(l_group) > 0:
            output.extend(["@QUEUE_INFO@", ' '.join(l_group), "@FINQUEUE_INFO@"])

    if on_machref:
        output.extend(["@MACHREF@", "@FINMACHREF@"])
        output.extend(["@REX_URL@", run.get('rex_url', ''), "@FINREX_URL@"])
        output.extend(["@REX_REPFICH@", run.get('rep_rex', ''), "@FINREX_REPFICH@"])
        output.extend(["@MAIL_ATA@", run.get('mail_ata', ''), "@FINMAIL_ATA@"])

    # message of the day
    output.append("@MOTD@")
    if run.get('motd', '') != '' and osp.exists(run['motd']):
        with open(run['motd'], 'r') as f:
            output.append(f.read())
    output.append("@FINMOTD@")

    print(os.linesep.join(output))


def Func_actu(run, *args):
    """Return state, diagnosis, node, cpu time and working directory of a job.
    """
    if len(args) != 3:
        run.parser.error(_("'--%s' takes exactly %d arguments (%d given)") % \
            (run.current_action, 3, len(args)))

    njob, nomjob, mode = args
    # defaults
    etat  = '_'
    diag  = '_'
    node  = '_'
    tcpu  = '_'
    wrk   = '_'
    queue = '_'
    psout = ''
    # the real job id may differ
    jobid = str(njob)
    # astk profile
    pr_astk = osp.join(run['flasheur'], '%s.p%s' % (nomjob, njob))
    prof = None
    if osp.isfile(pr_astk):
        prof = AsterProfil(pr_astk, run)
        wrk = prof['rep_trav'][0] or '_'

    # 1. get information about the job
    # 1.1. batch mode
    if mode == "batch":
        m = 'b'
        scheduler = BatchSystemFactory(run, prof)
        etat, diag, node, tcpu, wrkb, queue = scheduler.get_jobstate(njob, nomjob)

    # 1.2. interactive mode
    elif mode == "interactif":
        m = 'i'
        # if it doesn't exist the job is ended
        etat = "ENDED"
        if prof is not None:
            node = prof['noeud'][0]
    else:
        run.Mess(_('unexpected mode : %s') % mode, '<F>_UNEXPECTED_VALUE')

    # 2. query the process
    if node != '_':
        if mode == "interactif" or tcpu == '_':
            jret, psout = run.Shell(run['ps_cpu'], mach=node)
        # ended ?
        if mode == "interactif" and psout.find('btc.%s' % njob) > -1:
            etat = "RUN"

    # 3.1. the job is ended
    if etat == "ENDED":
        fdiag = osp.join(run['flasheur'], '%s.%s%s' % (nomjob, m, njob))
        if osp.isfile(fdiag):
            with open(fdiag, 'r') as f:
                diag = f.read().split(os.linesep)[0] or "?"
        if diag == '?' :
            diag = '<F>_SYSTEM'
            # try to find something in output
            fout = osp.join(run['flasheur'], '%s.o%s' % (nomjob, njob))
            if osp.isfile(fout):
                f = open(fout, 'rb')
                for line in f.readlines():
                    line = to_unicode(line)
                    if line.find('--- DIAGNOSTIC JOB :')>-1:
                        diag = line.split()[4]
                    elif line.find('Cputime limit exceeded')>-1:
                        diag = '<F>_CPU_LIMIT_SYSTEM'
                f.close()
            # copy fort.6 to '.o'
            if node != '_':
                ftcp = get_tmpname(run, run['tmp_user'], basename='actu')
                # same name as in the btc script generated by calcul.py
                wrk6 = get_nodepara(node, 'rep_trav', run['rep_trav'])
                fort6 = osp.join(wrk6, '%s.%s.fort.6.%s' % (nomjob, njob, m))
                jret = run.Copy(ftcp, '%s:%s' % (node, fort6), niverr='SILENT')
                if osp.isfile(ftcp):
                    txt = [os.linesep*2]
                    txt.append('='*48)
                    txt.append('===== Pas de diagnostic, recopie du fort.6 =====')
                    txt.append('='*48)
                    with open(ftcp, 'rb') as f:
                        txt.append(f.read().decode(errors='replace'))
                    txt.append('='*48)
                    txt.append('='*48)
                    txt.append(os.linesep*2)
                    with open(fout, 'a') as f:
                        f.write(os.linesep.join(txt))
    else:
    # 3.2. job is running
        if etat in ('RUN', 'SUSPENDED'):
            # working directory
            if wrk == '_':
                wrk = get_tmpname(run, basename=mode, node=node, pid=njob)
        if etat == 'RUN' and tcpu == '_':
            # tcpu may have been retrieved upper
            l_tcpu = []
            for line in psout.split(os.linesep):
                if re.search(r'\-\-num_job=%s' % njob, line) != None and \
                    re.search(r'\-\-mode=%s' % mode, line) != None:
                    l_tcpu.append(re.sub(r'\..*$', '',
                                         line.split()[0]).replace('-', ':'))
            if len(l_tcpu) > 0:
                try:
                    tcpu = dhms2s(l_tcpu)
                except ValueError:
                    pass

    # 4. return the result
    if node == "":
        node = "_"
    return etat, diag, node, tcpu, wrk, queue


def Actu(run, *args):
    """Return state, diagnosis, node, cpu time and working directory of a job.
    """
    print_actu_result(*Func_actu(run, *args))


def Edit(run, *args):
    """Open output or error file of a job.
    """
    args = bwc_edit_args(args)
    if len(args) < 4:
        run.parser.error(_("'--%s' takes at least %d arguments (%d given)") % \
            (run.current_action, 4, len(args)))

    njob, nomjob, mode, typ = args

    # filename to edit
    fname = flash_filename(run['flasheur'], nomjob, njob, typ, mode)
    run.DBG('filename =', fname)

    if osp.isfile(fname):
    # write file content to stdout
        if run.get('result_to_output'):
            run.PrintExitCode = False
            with open(fname, "r") as f:
                print(f.read())
        # edit the file
        else:
            edit_file(run, fname)
    else:
        run.Sortie(4)


def Del(run, *args, **kwargs):
    """Kill a job and delete related files.
    """
    if len(args) < 3:
        run.parser.error(_("'--%s' takes at least %d arguments (%d given)") % \
            (run.current_action, 3, len(args)))
    elif len(args) > 4:
        run.parser.error(_("'--%s' takes at most %d arguments (%d given)") % \
            (run.current_action, 4, len(args)))

    # 0. arguments
    njob, nomjob, mode = args[:3]
    if len(args) > 3:
        node = args[3]
    else:
        node = ''
    sent_signal = run['signal']
    if kwargs.get('signal'):
        sent_signal = kwargs['signal']
    delete_files = sent_signal == 'KILL'

    use_batch_cmd = False
    scheduler = None
    if mode == 'batch':
        scheduler = BatchSystemFactory(run)
        use_batch_cmd = sent_signal == 'KILL' or scheduler.supports_signal()

    # 1. retrieve the job status
    etat, diag, node, tcpu, wrk, queue = Func_actu(run, njob, nomjob, mode)
    run.DBG("actu returns : etat/diag/node/tcpu/wrk/queue", (etat, diag, node, tcpu, wrk, queue))

    # 2. send the signal
    if etat in ('RUN', 'SUSPENDED', 'PEND'):
        if use_batch_cmd:
            iret = scheduler.signal_job(njob, sent_signal)
            if iret != 0:
                run.Sortie(4)
        else:
            numpr, psout = '', ''
            # get process id
            if node == '_':
                # try on localhost
                node = ''
            if node != '_':
                jret, psout = run.Shell(run['ps_pid'], mach=node)
                exp = re.compile(r'^ *([0-9]+) +(.*)\-\-num_job=%s.*\-\-mode=%s' \
                        % (njob, mode), re.MULTILINE)
                res = exp.findall(psout)
                res.reverse()  # the relevant process should be the last one
                run.DBG("processes :", res)
                for numj, cmd in res:
                    # "sh -c" is automatically added by os.system
                    if cmd.find(shell_cmd) < 0 and cmd.find("sh -c") < 0:
                        numpr = int(numj)
                        run.DBG("Signal will be sent to process : %s" % numpr)
                        break
                if numpr == '':
                    # try to kill its as_run parent (but USR1 will not stop as_run)
                    sent_signal = 'KILL'
                    exp = re.compile(r'^ *([0-9]+) +(.*as_run.*\-\-num_job=+%s.*)' \
                            % njob, re.M)
                    res = exp.findall(psout)
                    res.reverse()  # the relevant process should be the last one
                    run.DBG("as_run processes :", res)
                    for numj, cmd in res:
                        # python run by bin/as_run
                        if cmd.find('python') > -1:
                            numpr = int(numj)
                            run.DBG("Signal will be sent to process : %s" % numpr)
                            break
            if numpr != '':
                if is_localhost2(node):
                    os.kill(numpr, getattr(signal, 'SIG%s' % sent_signal))
                else:
                    iret, psout = run.Shell('kill -%s %s' % (sent_signal, numpr), mach=node)
            else:
                run.DBG('<job.Del> process not found :' , psout, 'node = %s' % node, all=True)

    # 3. delete files
    if delete_files:
        l_fich = glob.glob(osp.join(run['flasheur'], '%s.?%s' % (nomjob, njob)))
        for f in l_fich:
            run.Delete(f)


def Func_tail(run, njob, nomjob, mode, nbline, expression=None):
    """Return the output the last part of fort.6 file or filter lines matching a pattern.
    """
    # retrieve the job status
    etat, diag, node, tcpu, wrk, queue = Func_actu(run, njob, nomjob, mode)
    run.DBG("actu returns : etat/diag/node/tcpu/wrk/queue", (etat, diag, node, tcpu, wrk, queue))
    # fill output file
    s_out = ''
    if mode == 'batch' and run['batch_nom'] == 'SunGE':
        s_out = _("Sorry I don't know how to ask Sun Grid Engine batch " \
                "scheduler the running node.")
    if etat == 'RUN':
        cmd = "cat {fich}"
        if expression is None or expression.strip() == "":
            cmd += " | tail -{nbline}"
        else:
            cmd += " | egrep -- '{expression}'"
        # file to parse
        fich = osp.join(wrk, 'fort.6')
        run.DBG(ufmt('path to fort.6 : %s', fich))
        if node != '_':
            mach = node
            fich = '%s:%s' % (node, fich)
        else:
            mach = ''
        # execute command
        if run.Exists(fich):
            fich = run.PathOnly(fich)
            jret, s_out = run.Shell(cmd.format(**locals()),
                                    mach=mach)
    return etat, diag, s_out


def Tail(run, *args):
    """Output the last part of fort.6 file or filter lines matching a pattern.
    """
    if len(args) < 5:
        run.parser.error(_("'--%s' takes at least %d arguments (%d given)") % \
            (run.current_action, 5, len(args)))
    elif len(args) > 6:
        run.parser.error(_("'--%s' takes at most %d arguments (%d given)") % \
            (run.current_action, 6, len(args)))

    # arguments
    njob, nomjob, mode, fdest, nbline = args[:5]
    expression = None
    if len(args) > 5:
        expression = args[5]

    # allow to customize of the executed function
    worker = Func_tail
    if run.get('schema_tail_exec'):
        worker = get_plugin(run['schema_tail_exec'])
        run.DBG("calling plugin : %s" % run['schema_tail_exec'])
    etat, diag, s_out = worker(run, njob, nomjob, mode, nbline, expression)
    print_tail_result(nomjob, njob, etat, diag)

    if s_out == "":
        s_out = _('the output is empty (job ended ?)')
    # exit if job isn't running
    run.PrintExitCode = False

    if run.get('result_to_output') or fdest == 'None':
        run.DBG(_('tail put to output'))
        print(s_out)
    else:
        # send output file
        if run.IsRemote(fdest):
            ftmp = get_tmpname(run, run['tmp_user'], basename='tail')
            with open(ftmp, 'w') as f:
                f.write(convert(s_out))
            jret = run.Copy(fdest, ftmp)
        else:
            fdest = run.PathOnly(fdest)
            with open(fdest, 'w') as f:
                f.write(convert(s_out))
            run.DBG(ufmt('output written to : %s', fdest))


def Purge(run, *args):
    """Delete files of the jobs which are NOT listed in args.
    """
    if len(args) < 1:
        run.parser.error(_("'--%s' takes at least %d arguments (%d given)") % \
            (run.current_action, 1, len(args)))

    l_keep = []
    l_f = os.listdir(run['flasheur'])
    for f in l_f:
        delete = True
        for j in args:
            if re.search(r'\.[a-z]?%s$' % j, f) != None:
                delete = False
                break
        if delete:
            run.Delete(osp.join(run['flasheur'], f), verbose=True)


def print_actu_result(*args):
    """Print the result of actu command."""
    print("ETAT=%s DIAG=%s EXEC=%s TCPU=%s REP_TRAV=%s QUEUE=%s" % args)


def print_tail_result(*args):
    """Print the result of tail command."""
    print("JOB=%s JOBID=%s ETAT=%s DIAG=%s" % args)


def parse_actu_result(txt):
    """Decode output of the Actu function.
    """
    if txt.strip() == '':
        # it means that we cannot retreive the job status
        resu = 'ENDED', '_', '_', '_', '_', '_'
        return resu
    resu = ("_",) * 6
    expr = re.compile("ETAT=(.+) +DIAG=(.+) +EXEC=(.+) +TCPU=(.+) +REP_TRAV=(.+) +QUEUE=(.+)")
    mat = expr.search(txt)
    if mat is not None:
        resu = mat.groups()
    return namedtuple('jobstatus',
        ['state', 'diag', 'node', 'cputime', 'wrkdir', 'queue'])(*resu)


def parse_tail_result(txt):
    """Decode output of the Tail function.
    """
    resu = ("_",) * 4
    expr = re.compile("JOB=(.+) JOBID=(.+) ETAT=(.+) DIAG=(.+)")
    mat = expr.search(txt)
    if mat is not None:
        resu = mat.groups()
    return namedtuple('jobtail',
        ['jobname', 'jobid', 'state', 'diag'])(*resu)
