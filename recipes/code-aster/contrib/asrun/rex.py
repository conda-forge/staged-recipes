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
Give methods to :
    - create a new issue in the tracker database,
    - close an issue,
    - extract messages from the tracker to write a histor file...
Methods are called by an AsterRun object.
"""

import os
import os.path as osp
import re

from asrun.installation import datadir, confdir
from asrun.common.i18n import _
from asrun.mystring     import ufmt, convert, cut_long_lines
from asrun.maintenance  import GetVersion
from asrun.common_func  import get_tmpname
from asrun.common.sysutils import on_linux
from asrun.common.utils import now


try:
    import asrun.myconnect as db
    from asrun.schema    import ReadDB, TYPE, USER, PRODUIT, STATUS, ISSUE, MSG, \
                               ISSUE_MESSAGES, YES, NO, ReadDBError, WriteDBError, \
                               mysql_date_fmt, ISSUE_NOSY
    from asrun.histor    import InitHistor
    imports_succeed = True
except ImportError:
    imports_succeed = False

db_encoding  = 'utf-8'


def in_adm_group(run):
    """Tell if the current user has admin rights.
    """
    if on_linux():
        import grp
        is_adm = grp.getgrgid(os.getgid())[0] in (run.get('agla_adm_group'), )
    else:
        is_adm = False
    return is_adm


def parse_issue_file(content):
    """Parse the content of the issue."""
    l_champs = ['NOMUSER', 'MAILUSER', 'UNIUSER',
                'TITRE', 'DATE1', 'DATE2', 'VERSION', 'TYPFIC', 'TEXTE',
                'FICASS']
    dinf = {}
    for ch in l_champs:
        exp = re.compile('\@%s\@(.*)\@FIN%s\@' % (ch, ch), re.MULTILINE | re.DOTALL)
        mat = exp.search(content)
        if mat != None and mat.group(1).strip() != 'Non_défini':
            dinf[ch] = mat.group(1).strip()
    return dinf


def SetParser(run):
    """Configure the command-line parser, add options name to store to the list,
    set actions informations.
    run : AsterRun object which manages the execution
    """
    acts_descr = {
        'create_issue' : {
            'method' : Creer,
            'syntax' : 'issue_file export_file',
            'help'   : _('Insert a new entry in the issue tracking system and '
                          'copy attached files if an export file is provided')
        },
        'extract_histor' : {
            'method' : Histor,
            'syntax' : '[--status=STAT] [--format=FORM] [--all_msg] input_file histor',
            'help'   : _('Extract the content of issues listed in `input_file` to `histor`')
        },
        'close_issue' : {
            'method' : Solder,
            'syntax' : '--vers=VERS histor',
            'help'   : _('Fill "corrVdev" or "corrVexpl" field (depends on VERS) in issues found in `histor` and eventually close them')
        },
    }
    opts_descr = {
        'status' : {
            'args'   : ('--status', ),
            'kwargs' : {
                'action'  : 'store',
                'default' : 'all',
                'metavar' : 'STAT',
                'choices' : ('all', 'resolu', 'valide_EDA', 'attente_doc', 'ferme'),
                'dest'    : 'status',
                'help'    : _('raise an error if issues are not in this status')
            }
        },
        'format' : {
            'args'   : ('--format', ),
            'kwargs' : {
                'action'  : 'store',
                'default' : 'text',
                'metavar' : 'FORM',
                'choices' : ('text', 'html', 'fsq'),
                'dest'    : 'format',
                'help'    : _('format of generated histor file (text or html)')
            }
        },
        'all_msg' : {
            'args'   : ('--all_msg', ),
            'kwargs' : {
                'action'  : 'store_true',
                'default' : False,
                'dest'    : 'all_msg',
                'help'    : _('retrieve all the messages of issues')
            }
        },
    }
    title = _('Options for issue tracker interface')
    run.SetActions(
            actions_descr=acts_descr,
            actions_order=['create_issue', 'close_issue', 'extract_histor'],
            group_options=True, group_title=title, actions_group_title=False,
            options_descr=opts_descr,
    )


def Creer(run, *args):
    """Create a new issue in REX database.
    """
    # backward compatibility: 2nd argument was optional in astk <= 1.8.3
    if len(args) < 1 or len(args) > 2:
        run.parser.error(_("'--%s' requires one or two arguments") % run.current_action)

    iret = 0
    on_machref = run.get('rep_agla', 'local') != 'local'
    if not on_machref:
        run.Mess(_('Only available on the AGLA machine'), '<F>_AGLA_ERROR')

    # 0. check imports
    if not imports_succeed:
        run.Mess(_('Imports of REX interface failed.'), '<F>_IMPORT_ERROR')

    # 1. copy issue file
    jn = run['num_job']
    ffich = get_tmpname(run, run['tmp_user'], basename='rex_fich')
    kret = run.Copy(ffich, args[0], niverr='<F>_COPYFILE')

    # 1b. parse issue file
    with open(ffich, 'r') as f:
        content = f.read()
    d = parse_issue_file(content)
    if run['debug']:
        print('Dict issue content : ', repr(d))

    fichetude = int(d.get('FICASS') is not None)
    if fichetude == 1:
        assert len(args) > 1, "inconsistent data" # check backward compatibility
        fprof = get_tmpname(run, run['tmp_user'], basename='rex_prof')
        kret = run.Copy(fprof, args[1], niverr='<F>_PROFILE_COPY')

    # 3. open database connection
    try:
        c = db.CONNECT('REX', rcdir=confdir, verbose=run['debug'])
    except Exception as msg:
        run.Mess(msg, '<F>_DB_ERROR')

    typ = ReadDB(TYPE, c)
    d_typ = {
        'AL'   : typ['anomalie'],
        'EL'   : typ['evolution'],
        'AOM'  : typ['aide utilisation'],
        'AO'   : typ['anomalie'],
        'EO'   : typ['evolution'],
        'ED'   : typ['evolution'],
    }
    if not d['TYPFIC'] in list(d_typ.keys()):
        run.Mess(_('Unknown issue type : %s') % d['TYPFIC'], '<F>_PARSE_ERROR')

    # 4. create new issue
    # 4.1. get fields from db
    login = run.system.getuser_host()[0]
    loginrex = login
    try:
        res = c.exe("""SELECT id, _username FROM _user WHERE _loginaster='%s' AND __retired__=0;""" % login)
        loginrex = res[0][1]
        if len(res) > 1:
            run.Mess(_("More than one user has '%s' as login in REX database, " \
                    "'%s' is taken") % (login, loginrex),
                '<A>_MULTIPLE_USER')
    except (IndexError, db.MySQLError) as msg:
        run.Mess(str(msg))
        run.Mess(_('User %s unknown in REX database') % login,
                '<F>_UNKNOWN_USER')
    user = USER({'_username' : loginrex}, c)
    try:
        user.read()
    except ReadDBError:
        run.Mess(_('User %s unknown in REX database') % login,
                '<F>_UNKNOWN_USER')
    prod = PRODUIT({'_name' : 'Code_Aster'}, c)
    try:
        prod.read()
    except ReadDBError:
        run.Mess(_('Code_Aster product not found in database !'), '<F>_DB_ERROR')
    emis = STATUS({'_name' : 'emis'}, c)
    try:
        emis.read()
    except ReadDBError:
        run.Mess(_("Status 'emis' not found in database !"), '<F>_DB_ERROR')

    # 4.2. get version item
    d_vers = prod.GetLinks()
    vers = d_vers.get(d['VERSION'])
    if vers == None:
        run.Mess(_("Version %s not found in database !") % d['VERSION'])

    # 4.3. fill fields
    date_now = now(datefmt=mysql_date_fmt, timefmt="")
    txtmsg = convert(d['TEXTE'], db_encoding)
    txtmsg = cut_long_lines(txtmsg, maxlen=100)
    issue = ISSUE({
            '_creator'  : user,
            '_produit'  : prod,
            '_status'   : emis,
            '_title'    : convert(d['TITRE'], db_encoding),
            '_type'     : d_typ[d['TYPFIC']],
            '_version'  : vers,
            '_fichetude' : fichetude,
        }, c)
    descr = MSG({'_author'   : user,
                '_creation' : date_now,
                '_creator'  : user,
                '_date'     : date_now,
                '_summary'  : txtmsg[:255], } ,c)
    lien = ISSUE_MESSAGES({'linkid' : descr, 'nodeid' : issue}, c)

    # 4.4. insert issue in database
    try:
        lien.write()
    except WriteDBError as msg:
        run.Mess(_('Insert issue failed'), '<F>_DB_ERROR')

    # 4.5. add user in nosy list
    nosy = ISSUE_NOSY({'linkid' : user['id'], 'nodeid' : issue['id']}, c)
    try:
        nosy.write()
    except WriteDBError as msg:
        run.Mess(_('Add user to nosy list failed'), '<F>_DB_ERROR')

    # 5. get message and issue id
    numid = issue['id']
    msgid = descr['id']
    print('INDEX=%s MESSAGE=%s' % (numid, msgid))

    # 6. copy message file
    repid = str(int(msgid) // 1000)
    fmsg = osp.join(run['tmp_user'], 'msg%s' % msgid)
    with open(fmsg, 'w') as f:
        f.write(txtmsg + '\n')
    cmd = []
    cmd.append(osp.join(run['rep_agla'], 'roundup_cp_uid'))
    cmd.append('put')
    cmd.append(fmsg)
    cmd.append('%s' % repid)
    iret, output = run.Shell(' '.join(cmd))
    if iret != 0:
        run.Mess(_('Error message: %s') % output)
        run.Mess(_('Error occurs during copying message file'), '<F>_COPY')

    # 7. study files
    if fichetude == 1:
        cmd = []
        cmd.append(osp.join(datadir, 'as_rex_prof'))
        cmd.append(fprof)
        cmd.append('%06d' % numid)
        iret, output = run.Shell(' '.join(cmd))
        if iret != 0:
            run.Mess(_('Error occurs during copying study files'), '<F>_COPY')


def Histor(run, *args):
    """Extract the content of some issues from REX database.
    """
    if len(args) != 2:
        run.parser.error(_("'--%s' requires two arguments") % run.current_action)

    iret = 0
    on_machref = run.get('rep_agla', 'local') != 'local'
    if not on_machref:
        run.Mess(_('Only available on the AGLA machine'), '<F>_AGLA_ERROR')

    # 0. check imports
    if not imports_succeed:
        run.Mess(_('Imports of REX interface failed.'), '<F>_IMPORT_ERROR')

    # 1. copy input file
    jn = run['num_job']
    ffich = get_tmpname(run, run['tmp_user'], basename='hist_input')
    kret = run.Copy(ffich, args[0], niverr='<F>_COPYFILE')

    # 2. read input file
    with open(ffich, 'r') as f:
        hist_content = f.read()
    expr = re.compile('([0-9]+)', re.MULTILINE)
    l_nf = [int(n) for n in expr.findall(hist_content)]

    # 3. open database connection
    try:
        c = db.CONNECT('REX', rcdir=confdir, verbose=run['debug'])
    except Exception as msg:
        run.Mess(convert(msg), '<F>_DB_ERROR')

    histor = build_histor(run, l_nf, c)

    # 5. copy histor file
    ffich = get_tmpname(run, run['tmp_user'], basename='hist_output')
    with open(ffich, 'w') as f:
        f.write(repr(histor))
    kret = run.Copy(args[1], ffich, niverr='<F>_COPYFILE')
    run.Mess(_("Histor successfully generated."), 'OK')


def Solder(run, *args):
    """Fill corrVdev/corrVexpl fields and close issues found in a histor file.
    """
    if not run.get('aster_vers'):
        run.parser.error(_("You must define 'default_vers' in 'aster' configuration file or use '--vers' option."))
    if len(args) != 1:
        run.parser.error(_("'--%s' requires one argument") % run.current_action)

    on_machref = run.get('rep_agla', 'local') != 'local'
    if not on_machref:
        run.Mess(_('Only available on the AGLA machine'), '<F>_AGLA_ERROR')
    try:
        is_adm = in_adm_group(run)
        if not is_adm:
            raise KeyError
    except KeyError as msg:
        run.Mess(_('insufficient privileges to close issues !'), '<F>_AGLA_ERROR')

    # 0. check imports
    if not imports_succeed:
        run.Mess(_('Imports of REX interface failed.'), '<F>_IMPORT_ERROR')

    # 1. read histor file
    jn = run['num_job']
    ffich = get_tmpname(run, run['tmp_user'], basename='hist_input')
    kret = run.Copy(ffich, args[0], niverr='<F>_COPYFILE')

    with open(ffich, 'r') as f:
        hist_content = f.read()
    expr = re.compile('RESTITUTION FICHE +([0-9]+)', re.MULTILINE)
    l_nf = [int(n) for n in expr.findall(hist_content)]
    if len(l_nf) == 0:
        run.Mess(_('Incorrect file, no issue to close.'), '<F>_AGLA_ERROR')

    # 2. get version number and database fields to fill
    expl = False
    # also accept a version number (ex. '2011.1') instead of 'NEW10'
    if run['aster_vers'].replace('.', '').isdigit():
        tagv = run['aster_vers']
        run.Mess(ufmt(_('Close issues with version tag : %s'), tagv))
    else:
        run.Mess(_('Close issues in :'))
        iret, l_res = GetVersion(run, silent=False, vers=run['aster_vers'])
        tagv = '.'.join(l_res[:3])
        expl = l_res[4]

    # 3. open database connection
    try:
        c = db.CONNECT('REX', rcdir=confdir, verbose=run['debug'])
    except Exception as msg:
        run.Mess(msg, '<F>_DB_ERROR')

    etat = _read_table(run, c, STATUS)
    # 4. read issues from database
    mark_as_closed(run, l_nf, c, tagv, expl)

    # 5. delete files of *all* closed issues
    # list of closed issues
    query = """SELECT id from _issue WHERE _status=%s;""" % etat['ferme']['id']
    try:
        res = c.exe(query)
    except db.MySQLError as msg:
        run.Mess(ufmt(_("error executing a query to the database\n %s"), query), '<F>_DB_ERROR')
    l_ferm = set([i[0] for i in res])
    # list of existing directories
    l_dirs = set([int(d) for d in os.listdir(osp.join(run['rep_rex'], "emise")) \
                if osp.isdir(osp.join(run['rep_rex'], "emise", d)) and d.isdigit()])
    to_del = l_dirs.intersection(l_ferm)
    dir_to_del = ["%06d" % num for num in to_del]
    for d in dir_to_del:
        run.Delete(osp.join(run['rep_rex'], "emise", d))
        run.Mess(_("files of issue %s have been deleted.") % d)

def _read_table(run, cnx, typ):
    """return status and product tables"""
    try:
        tab = ReadDB(typ, cnx)
    except ReadDBError:
        run.Mess(_('Unable to read the table'), '<F>_DB_ERROR')
    return tab

def mark_as_closed(run, l_nf, cnx, tagv, expl):
    """Mark a list of issues as closed
    l_nf: list of issues numbers
    cnx: connection object to database
    tagv: tag inserted in issues
    expl: True if it concerns a stable version (exploitation)"""
    etat = _read_table(run, cnx, STATUS)
    prod = _read_table(run, cnx, PRODUIT)
    typv = 'dev'
    autr = 'expl'
    if expl:
        typv = 'expl'
        autr = 'dev'
    d_champ = {
        'a_corrige' : '_corrV' + typv,
        'v_correct' : '_verCorrV' + typv,
        'a_tester'  : '_corrV' + autr,
        'v_tester'  : '_verCorrV' + autr,
    }
    req_status = 'valide_EDA'
    for numf in l_nf:
        # 4.1. read the issue
        try:
            issue = ISSUE(numf, cnx)
        except ReadDBError:
            run.Mess(_('Unable to read issue %s') % numf, '<E>_UNKNOWN_ISSUE')
            continue

        # 4.2. check issue values
        status = issue['_status'].GetPrimValue()
        if status != req_status:
            run.Mess(_("Status of issue %s is not '%s' (%s)") \
                    % (numf, req_status, status), '<A>_UNEXPECTED_VALUE')
            issue['_status'] = etat[req_status]

        if issue['_produit'].GetPrimValue() == 'Code_Aster':
            if not issue[d_champ['a_corrige']] \
                and issue['_type'].GetPrimValue() != 'aide utilisation':
                issue[d_champ['a_corrige']] = YES
                run.Mess(_("issue %s should not been solved in version %s") \
                        % (numf, typv), '<A>_UNEXPECTED_VALUE')
        else:
            issue[d_champ['a_corrige']] = NO
            issue[d_champ['a_tester']] = NO

        # 4.3. fill issue fields
        issue[d_champ['v_correct']] = tagv

        # 4.4. close issue ?
        if not issue[d_champ['a_tester']] or not issue[d_champ['v_tester']] in ('', None):
            new_status = etat['attente_doc']
            if not issue['_impactDoc']:
                new_status = etat['ferme']
            issue['_status'] = new_status
            run.Mess(_('issue %s is closed') % numf)
        else:
            run.Mess(_('issue %s must be solved in V%s too') % (numf, autr))

        # 4.5. write issue in database
        try:
            if not run['debug']:
                issue.write(force=True)
            else:
                issue.repr()
        except WriteDBError as msg:
            run.Mess(_('error occurs during writing issue'), '<F>_DB_ERROR')


def build_histor(run, l_nf, cnx):
    """Build an Histor instance from a list of issues
    l_nf: list of issues numbers
    cnx: connection object to database"""
    # 4. read issues from database
    histor = InitHistor(format=run['format'], url=run['rex_url'])
    for numf in l_nf:
        # 4.1. read the issue
        issue = ISSUE({'id' : numf}, cnx)
        try:
            issue.read()
        except ReadDBError:
            run.Mess(_('Unable to read issue %s') % numf, '<E>_UNKNOWN_ISSUE')
            continue

        # 4.2.
        # 4.2.1. check status
        status = issue['_status'].GetPrimValue()
        if status != run['status'] and run['status'] != 'all':
            run.Mess(_("Status of issue %s is not '%s' (%s)") \
                    % (numf, run['status'], status), '<E>_UNEXPECTED_VALUE')

        # 4.2.2. alarm on impactDoc : no
        # 4.3.1. user header : no

        # 4.3.2. get message file of answer
        l_rep = []
        d_msg = issue.GetLinks()
        # allow to print all messages
        if run['all_msg']:
            l_msgid = list(d_msg.keys())
            l_msgid.sort()
            l_msgid.reverse()
        else:
            l_msgid = [max(d_msg.keys())]
        for i, msgid in enumerate(l_msgid):
            repid = str(int(msgid) // 1000)
            msgfile = '%s%smsg%s' % (repid, os.sep, msgid)
            fmsg = osp.join(run['rep_tmp'], 'msg%s' % msgid)
            cmd = []
            cmd.append(osp.join(run['rep_agla'], 'roundup_cp_uid'))
            cmd.append('get')
            cmd.append('%s%smsg%s' % (repid, os.sep, msgid))
            cmd.append(run['rep_tmp'])
            iret, output = run.Shell(' '.join(cmd))
            if iret != 0 or not osp.exists(fmsg):
                run.Mess(_('Error message: %s') % output)
                run.Mess(_('Error occurs during copying message file %s, ' \
                       'only the summary will be printed') % msgid, '<F>_COPY_MSG')
            else:
                with open(fmsg, 'r') as f:
                    txt = f.read()
                if len(l_msgid) > 1:
                    l_rep.append(_('message %d :') % (len(l_msgid) - i))
                l_rep.append(txt)

        # 4.3.3. add this issue to the histor object
        histor.AddIssue(issue, l_rep)
    return histor
