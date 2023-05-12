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
This module defines the default schemes.

Additionnal modules can be added to define others schemes to extend
the capabilities of asrun.

These plugins can be added in any directory listed in PYTHONPATH.
But it's recommended to place them in etc/codeaster/plugins because
the modules added in this directory will be kept during updates of asrun.
"""

import os
import os.path as osp

from asrun.common.i18n  import _
from asrun.core         import magic
from asrun.calcul       import parse_submission_result, parse_consbtc
from asrun.job          import parse_actu_result, print_actu_result
from asrun.profil       import AsterProfil
from asrun.core.configuration import get_plt_exec_name
from asrun.common_func  import flash_filename, edit_file
from asrun.common.utils import get_absolute_path, unique_basename
from asrun.common.sysutils import local_user, local_full_host, get_home_directory
from asrun.core.server  import build_server_from_profile, TYPES
from asrun.rex          import parse_issue_file
from asrun.profile_modifier import apply_special_service



def serv(prof, args, print_output=True, **kwargs):
    """Call --serv action on a server."""
    run = magic.run
    num_job = kwargs.get('num_job', run['num_job'])
    # decode special service
    serv, prof = apply_special_service(prof, run, on_client_side=True)
    if serv != "":
        magic.log.info(_("special service : %s"), serv)
    # set studyid (if already defined in prof, use this one)
    studyid = prof['studyid'][0]
    if studyid == '':
        studyid = "%s-%s" % (num_job, prof['mclient'][0].split('.')[0])
    # read server informations
    sexec = build_server_from_profile(prof, TYPES.EXEC)
    scopy = build_server_from_profile(prof, TYPES.COPY_TO, jobid=studyid)
    magic.log.info(_("prepare execution for %s@%s"), sexec.user, sexec.host)

    # prepare export for execution with all files present in the remote directory
    fprof = osp.join(run['tmp_user'], "%s.export" % studyid)
    forig = osp.join(run['tmp_user'], "%s.orig.export" % studyid)
    prof.set_filename(forig)
    prof.WriteExportTo(forig)
    run.ToDelete(fprof)
    run.ToDelete(forig)

    iret, remote_prof = copy_datafiles_on_server(prof, studyid, fprof)
    if iret != 0:
        return iret, ''

    # launch the study
    cmd = [osp.join(sexec.get_aster_root(), "bin",
                    get_plt_exec_name(remote_prof.get_platform(), "as_run")), ]
    cmd.append("--serv")
    cmd.append("--num_job=%s" % studyid)
    cmd.extend(run.get_rcdir_arg())
    cmd.append(remote_prof.get_filename())

    iret, output, err = sexec.exec_command(cmd, display_forwarding=True)
    run.DBG("******************** OUTPUT of as_run --serv ********************",output,
            "******************** ERROR of as_run --serv ********************", err,
            "******************** END of as_run --serv ********************",
            all=True, prefix="    ")
    jobid, queue, stid2 = parse_submission_result(output)
    run.DBG("The server returns %s and studyid is set to %s" % (stid2, studyid))
    if print_output:
        print("JOBID=%s QUEUE=%s STUDYID=%s" % (jobid, queue, studyid))
    btc = parse_consbtc(output)
    if btc is not None and print_output:
        print("BTCFILE=%s" % btc)
    if iret != 0:
        output += os.linesep.join([output,
            "******************** ERROR of as_run --serv ********************", err])
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
    serv = build_server_from_profile(prof, TYPES.COPY_FROM)

    jobid = prof['jobid'][0]
    jobname = prof['nomjob'][0]
    mode = prof['mode'][0]
    # flasheur is in the home directory
    dirname, fname = osp.split(flash_filename("flasheur", jobname, jobid, "export", mode))
    run.DBG("export file in %s is named %s" % (dirname, fname))

    # copy export file locally
    serv.set_proxy_dir(dirname)
    dst = osp.join(run['tmp_user'], 'flasheur_%s' % serv.host, fname)
    iret = serv.copyfrom(dst)
    if iret != 0:
        return None

    # read studyid
    study_prof = AsterProfil(dst, run)
    return study_prof


def call_generic_service(action, serv, prof, args, options={}):
    """Generic function : call the service on the given server."""
    # BE CAREFULL : first argument of `args` is ignored (supposed to be equal to `prof`)
    # the server is created by the caller essentially to give relevant progress informations
    # launch the service
    run = magic.run
    cmd = [osp.join(serv.get_aster_root(), "bin",
                    get_plt_exec_name(prof.get_platform(), "as_run")), ]
    cmd.append("--" + action)
    cmd.extend(run.get_rcdir_arg())
    for key, val in list(options.items()):
        if val is True:
            val = ""
        else:
            val = "=%s" % val
        cmd.append("--%s%s" % (key, val))
    cmd.extend(args[1:])

    iret, output, err = serv.exec_command(cmd)
    run.DBG("******************** OUTPUT of as_run --%s ********************" % action, output,
            #"******************** ERROR of as_run --%s ********************" % action, err,
            "******************** END of as_run --%s ********************" % action,
            all=True, prefix="    ")
    if iret != 0:
        output += os.linesep.join([output,
            "******************** ERROR of as_run --%s ********************" % action, err])
    return iret, output, err


def copy_datafiles_on_server(prof, studyid, fprof):
    """Copy data files on the server, relocate the export and write it (locally)
    into 'fprof'. Return the relocated export."""
    # read server informations
    sexec = build_server_from_profile(prof, TYPES.EXEC)
    scopy = build_server_from_profile(prof, TYPES.COPY_TO, jobid=studyid)
    forig = prof.get_filename()
    magic.log.debug("original export name is %s", forig)
    magic.run.DBG("original export :\n%s" % repr(prof), all=True)

    run_on_localhost = sexec.is_localhost()
    remote_prof = prof.copy()
    if not run_on_localhost:
        remote_prof.relocate(local_full_host, scopy.get_proxy_dir(),
                             convert=unique_basename)
    remote_prof.relocate(sexec.host, convert=unique_basename)
    remote_prof['studyid'] = studyid
    remote_prof.set_filename(fprof)
    remote_prof.WriteExportTo(fprof)
    magic.run.DBG("remote export :\n%s" % repr(remote_prof), all=True)

    # copy data files
    # - local_data : files which are on localhost and to copy on the compute server
    all_data = prof.get_data()
    if not run_on_localhost:
        local_data = all_data.get_on_serv(local_full_host)
    else:
        local_data = []
    # - remote_data : these files are already on the server, use them directly
    remote_data = all_data.get_on_serv(sexec.host, sexec.user).topath()
    # - foreign_data : if they are on a foreign server (not localhost or
    #   compute server), we can :
    #   - first copy them locally, and send them to the compute server.
    #   - or try to copy them from the compute server (<<< let this choice right now).
    all = set(all_data.topath())
    if local_data:
        all.difference_update(local_data.topath())
    all.difference_update(remote_data)
    if len(all) > 0:
        magic.log.warn(_("files on a third host may be unavailable "
                          "for calculation : %s"), all)

    # copy files on the server
    magic.log.info(_("copy export files..."))
    iret = scopy.copyto(fprof, forig)
    magic.log.info(_("copy data files..."))
    if local_data:
        local_nom, local_other = local_data.get_type('nom', with_completion=True)
        iret = scopy.copyto(convert=unique_basename, *local_other.topath())
        jret = scopy.copyto(*local_nom.topath())
        iret = max(iret, jret)

    # set remote filename
    remote_prof.set_filename(scopy.get_remote_filename(fprof))
    return iret, remote_prof


def actu(prof, args, **kwargs):
    """Default schema for 'actu' action."""
    return actu_and_results(prof, args, **kwargs)


def actu_and_results(prof, args, print_output=True, **kwargs):
    """Call --actu action on a server
    + call automatically --get_results if the job is ended."""
    iret, output = _call_actu(prof, args)
    result = parse_actu_result(output)
    if print_output:
        print_actu_result(*result)
    if iret == 0 and result[0] == "ENDED":
        iret2 = get_results(prof, args)
    return iret, output


def actu_simple(prof, args, print_output=True, **kwargs):
    """Call --actu action on a server"""
    iret, output = _call_actu(prof, args)
    result = parse_actu_result(output)
    if print_output:
        print_actu_result(*result)
    return iret, output


def _call_actu(prof, args):
    """Call --actu action on a server"""
    jobid = prof['jobid'][0]
    jobname = prof['nomjob'][0]
    mode = prof['mode'][0]
    targs = (None, jobid, jobname, mode)

    # read server informations
    serv = build_server_from_profile(prof, TYPES.EXEC)

    magic.log.info(_("ask the server for the job status"))
    iret, output, err = call_generic_service("actu", serv, prof, targs)
    magic.log.debug("server returns %s", output)
    result = parse_actu_result(output)
    magic.log.info(_("job status is %s"), result[0])
    return iret, output


def stop_del(prof, args, **kwargs):
    """Call --del action on a server"""
    # retreive the study export before it would be removed
    study_prof = get_study_export(prof)

    jobid = prof['jobid'][0]
    jobname = prof['nomjob'][0]
    mode = prof['mode'][0]
    node = prof['noeud'][0]
    targs = (None, jobid, jobname, mode, node)
    signal = kwargs.get('signal', magic.run['signal'])

    # read server informations
    serv = build_server_from_profile(prof, TYPES.EXEC)
    magic.log.info(_("ask the server to cancel the job and remove its "
                      "files from 'flasheur'"))
    iret, output, err = call_generic_service("del", serv, prof, targs,
        { 'signal' : signal })

    # stop here if signal!=KILL or the study id have not been retreived
    if signal != 'KILL' or study_prof is None:
        return iret

    # remove remote repository
    studyid = study_prof['studyid'][0]
    scopy = build_server_from_profile(study_prof, TYPES.COPY_FROM, jobid=studyid)
    scopy.delete_proxy_dir()
    return iret


def purge_flash(prof, args, **kwargs):
    """Call --purge_flash action on a server"""
    # read server informations
    serv = build_server_from_profile(prof, TYPES.EXEC)

    iret, output, err = call_generic_service("purge_flash", serv, prof, args)
    return iret


def tail(prof, args, print_output=True, **kwargs):
    """Call --tail action on a server"""
    jobid = prof['jobid'][0]
    jobname = prof['nomjob'][0]
    mode = prof['mode'][0]
    nbline = prof['tail_nbline'][0]
    regexp = prof['tail_regexp'][0]
    targs = (None, jobid, jobname, mode, 'None', nbline, regexp)

    # read server informations
    serv = build_server_from_profile(prof, TYPES.EXEC)

    options = { 'result_to_output' : True }
    iret, output, err = call_generic_service("tail", serv, prof, targs, options)
    if print_output:
        print(output)
    # not expected in output
    magic.run.PrintExitCode = False
    return iret, output


def info(prof, args, print_output=True, **kwargs):
    """Call --info action on a server"""
    # read server informations
    serv = build_server_from_profile(prof, TYPES.EXEC)

    magic.log.info(_("retreive configuration informations of the server"))
    iret, output, err = call_generic_service("info", serv, prof, args)
    if print_output:
        print(output)
    # already in output
    magic.run.PrintExitCode = False
    return iret, output


def edit(prof, args, **kwargs):
    """Default schema for 'edit' action."""
    return local_edit(prof, args, **kwargs)


def remote_edit(prof, args, **kwargs):
    """Call --edit action on a server by opening an editor on the
    server."""
    #XXX --edit does not yet support display argument: remote_edit may not work
    # maybe by adding a sleeping time...?
    action = "edit"
    jobid = prof['jobid'][0]
    jobname = prof['nomjob'][0]
    mode = prof['mode'][0]
    typ = prof['edit_type'][0]
    displ = prof['display'][0]

    # read server informations
    serv = build_server_from_profile(prof, TYPES.EXEC)

    if serv.support_display_forwarding():
        # --edit will use os.environ['DISPLAY']
        # but this will not work if ssh is run in background...
        displ = "None:0"

    # launch the service
    cmd = [osp.join(serv.get_aster_root(), "bin",
                    get_plt_exec_name(prof.get_platform(), "as_run")), ]
    cmd.append("--" + action)
    cmd.extend(magic.run.get_rcdir_arg())
    targs = (jobid, jobname, mode, typ)
    cmd.extend(targs)

    iret, output, err = serv.exec_command(cmd, display_forwarding=True)
    magic.run.DBG("******************** OUTPUT of as_run --%s ********************" % action, output,
            "******************** END of as_run --%s ********************" % action,
            all=True, prefix="    ")
    return iret


def local_edit(prof, args, **kwargs):
    """Call --edit action on a server by using a local editor after
    copying file if it's remote."""
    run = magic.run
    jobid = prof['jobid'][0]
    jobname = prof['nomjob'][0]
    mode = prof['mode'][0]
    typ = prof['edit_type'][0]
    to_output = kwargs.get('result_to_output', run['result_to_output'])

    iret = 0
    # read server informations
    serv = build_server_from_profile(prof, TYPES.COPY_FROM)

    # flasheur is in the home directory
    dirname, fname = osp.split(flash_filename("flasheur", jobname, jobid, typ, mode))
    run.DBG("file to edit is in %s named %s" % (dirname, fname))

    # copy from dirname if not on localhost
    if not serv.is_localhost():
        serv.set_proxy_dir(dirname)
        dst = osp.join(run['tmp_user'], 'flasheur_%s' % serv.host, fname)
        is_agla_astout = prof['nomjob'][0].startswith('pre_eda') \
                      or prof['nomjob'][0].startswith('asrest')
        if not osp.exists(dst) or is_agla_astout:
            iret = serv.copyfrom(dst)
    else:
        iret = 0
        dst = osp.join(get_home_directory(), dirname, fname)

    if iret == 0 and not to_output:
        magic.log.info(_("edit file %s"), dst)
        edit_file(run, dst)
    return iret


def sendmail(prof, args, **kwargs):
    """Call --sendmail action on a server.
    Allow to send a mail even if it's not configured on localhost."""
    # put the file on the server
    run = magic.run
    num_job = kwargs.get('num_job', run['num_job'])
    to = kwargs.get('report_to', run['report_to'])
    jobid = '%s-%s' % (num_job, "sendmail")
    # read server informations
    sexec = build_server_from_profile(prof, TYPES.EXEC)
    scopy = build_server_from_profile(prof, TYPES.COPY_TO, jobid=jobid)

    # copy text file
    scopy.copyto(args[1])
    rfile = scopy.get_remote_filename(args[1])
    targs = (None, rfile, )

    iret, output, err = call_generic_service("sendmail", sexec, prof, targs,
        { 'report_to' : to })
    scopy.delete_proxy_dir()
    return iret


def get_export(prof, args, print_output=True, **kwargs):
    """Call --get_export action on a server."""
    # read server informations
    serv = build_server_from_profile(prof, TYPES.EXEC)
    vers = kwargs.get('vers', magic.run['aster_vers'])

    iret, output, err = call_generic_service("get_export", serv, prof, args,
        { 'vers' : vers })
    if print_output:
        print(output)
    return iret, output


def serv_with_reverse_access(prof, args, print_output=True, **kwargs):
    """The old way to call a server :
    - the server is called directly through ssh/rsh
    - reverse access to the client from the server is required to
      read the export file and other data files.
    """
    action = "serv"
    # read server informations
    serv = build_server_from_profile(prof, TYPES.EXEC)

    filename = get_absolute_path(prof.get_filename())
    if not serv.is_localhost():
        prof.from_remote_server()
        prof.WriteExportTo(filename)

    filename = "%s:%s" % (local_full_host, filename)
    if local_user != '':
        filename = "%s@%s" % (local_user, filename)

    cmd = [osp.join(serv.get_aster_root(), "bin",
                    get_plt_exec_name(prof.get_platform(), "as_run")), ]
    cmd.append("--" + action)
    cmd.append(filename)

    # for compatibility with old asrun server
    cmd.extend(magic.run.get_as_run_args())

    iret, output, err = serv.exec_command(cmd, display_forwarding=True)
    magic.run.DBG("******************** OUTPUT of as_run --%s ********************" % action, output,
            "******************** END of as_run --%s ********************" % action,
            all=True, prefix="    ")
    res = parse_submission_result(output)
    if print_output:
        print("JOBID=%s QUEUE=%s STUDYID=%s" % res)
    return iret


def create_issue(prof, args, **kwargs):
    """Call --create_issue on a server."""
    # put the files on the server
    run = magic.run
    num_job = kwargs.get('num_job', run['num_job'])
    jobid = '%s-%s' % (num_job, "create_issue")
    # read server informations
    sexec = build_server_from_profile(prof, TYPES.EXEC)
    scopy = build_server_from_profile(prof, TYPES.COPY_TO, jobid=jobid)

    # read issue file
    issue_file = args[0]
    with open(issue_file, 'r') as f:
        content = f.read()
    dinf = parse_issue_file(content)
    scopy.copyto(issue_file)
    rfile = scopy.get_remote_filename(issue_file)

    # should we copy data files ?
    profname = "no_attachment"
    if dinf.get('FICASS') is not None:
        fprof = osp.join(run['tmp_user'], "%s.export" % jobid)
        iret, remote_prof = copy_datafiles_on_server(prof, jobid, fprof)
        profname = remote_prof.get_filename()
        if iret != 0:
            return iret

    targs = (None, rfile, profname)
    iret, output, err = call_generic_service("create_issue", sexec, prof, targs)
    scopy.delete_proxy_dir()
    return iret


def insert_in_db(prof, args, **kwargs):
    """Call --insert_in_db on a server."""
    run = magic.run
    num_job = kwargs.get('num_job', run['num_job'])
    jobid = '%s-%s' % (num_job, "insert_in_db")
    # read server informations
    sexec = build_server_from_profile(prof, TYPES.EXEC)
    scopy = build_server_from_profile(prof, TYPES.COPY_TO, jobid=jobid)

    # copy data files
    #XXX should result files be copied too ?
    #XXX should be run in foreground to keep display
    fprof = osp.join(run['tmp_user'], "%s.export" % jobid)
    iret, remote_prof = copy_datafiles_on_server(prof, jobid, fprof)
    if iret != 0:
        return iret

    targs = (None, remote_prof.get_filename(), )
    iret, output, err = call_generic_service("insert_in_db", sexec, prof, targs)
    scopy.delete_proxy_dir()
    return iret
