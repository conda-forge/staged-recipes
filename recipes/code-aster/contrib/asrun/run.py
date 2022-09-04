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
Definition of AsterRun class.
"""

import sys
import os
import os.path as osp
import re
import time
import traceback
import pprint
from glob import glob
from configparser import ConfigParser, NoOptionError
from optparse import OptionGroup
from warnings import warn

from asrun.core          import magic, RunAsterError
from asrun.common.i18n   import _
from asrun.mystring      import convert_list, to_unicode, ufmt
from asrun.parser        import (define_parser, default_options, get_option_value,
                                SUPPRESS_HELP)
from asrun.timer         import AsterTimer
from asrun.common.rcfile import read_rcfile
from asrun.installation  import aster_root, confdir, localedir
from asrun.thread        import is_main_thread, TaskAbort
from asrun.common.sysutils import (get_home_directory, local_host, local_full_host,
                                   local_user_path, get_exec_name)
from asrun.common.utils  import get_subdirs, get_unique_id
from asrun.common_func   import get_limits

from asrun.backward_compatibility import bwc_config_rc, bwc_deprecate_class

# default - may be branch dependent
ASTKRC = ".astkrc"


class AsterRun:
    """Main class to manage execution.
    """

    def __init__(self, **kwargs):
        """Initializations"""
        self.ExitOnFatalError = True
        self.PrintExitCode    = True
        self.__initialized    = False
        self._val_pid         = 0
        self.rcdir = kwargs.get('rcdir')
        # ----- verification de la version de Python
        if sys.hexversion < 0x020600F0:
            print(_("This script requires Python 2.6 or higher, sorry !"))
            self.Sortie(4)

        # ----- package informations
        from asrun.__pkginfo__ import version, copyright
        self.program     = 'as_run'
        self.__version__ = version

        # ----- options, liste des options du parser à stocker dans options
        self.options = default_options
        # always use _add_option to extend options_list
        self.options_list = ['debug', 'verbose', 'silent', 'force', 'num_job',
            'debug_stderr', 'stdout', 'stderr', 'log_progress',
            'remote_shell_protocol', 'remote_copy_protocol']

        # ----- informations about actions : module, method
        # always use set_action to define a new action
        self.actions_info = {}
        # store current action
        self.current_action = ''

        # ----- user preferences and defaults
        self.user_vars = {
            'editor' :
                {  'val'  : 'nedit',
                   'help' : _('editor command') },
            'devel_server_user' :
                {  'val'  : '',
                    'help' : _('login on the development server') + os.linesep + \
                    _('# (name/ip address is usually set in /etc/codeaster/asrun)') },
        }

        # ----- formats
        self.fmt = {
            'usage'     : '   - %s :'+os.linesep+'      %s'+os.linesep,
            'verb1'     : ' %-15s = %s',
            'msg+cod'   : os.linesep+'%-18s %s'+os.linesep,
            'msg_info'  : '<INFO>%s %s',
            'silent'    : '      %s %s',
            'title'     : os.linesep+'-'*80+os.linesep+'%s %s'+os.linesep,
            'diag'      : os.linesep+'-'*60+os.linesep+\
                       '--- DIAGNOSTIC JOB : %s'+\
                       os.linesep+'-'*60+os.linesep,
            'exit'      : os.linesep+'EXIT_CODE='+'%d'
        }

        # ----- diagnostic
        self.diag = ''

        # ----- list of files/directories to delete on exit
        self.to_delete = []

        # ----- lists of text to print on exit depending on diagnostic
        # this allows to keep important messages when a lot of output is generated
        # and to print them once again at end
        self.print_on_exit = {}

        # ----- do not print timer info on exit by default
        self.timer = None
        self.print_timer = False

        # ----- parser
        self.parser = define_parser(self)

        # ----- user resource directory
        # if self.rcdir is set, it's supposed to start with ".astkrc_"
        # or to be an absolute directory name.
        # if it's an absolute pathname it may be unusable on the remote host
        if self.rcdir is None:
            self.rcdir = get_option_value(sys.argv, "--rcdir", default=ASTKRC)
        assert self.rcdir.startswith(".astkrc") or osp.abspath(self.rcdir) == self.rcdir, \
            "absolute path or similar to '.astkrc_xxx' expected not: %s" % self.rcdir

        # ----- read master configuration file and user preferences
        self.config = {}
        oldrc = osp.join(get_home_directory(), self.rcdir, 'config')
        bwc_config_rc(oldrc, self._read_rc)

        self.user_rc = osp.join(get_home_directory(), self.rcdir, 'prefs')
        self._read_rc(osp.join(confdir, 'asrun'), self.config, mcsimp=['noeud'])
        verslist = [osp.join(confdir, 'aster')]
        verslist.extend(glob(osp.join(aster_root, '*', 'aster.conf')))
        verslist.extend(glob('/opt/aster/*/aster.conf'))
        verslist.extend(glob('/opt/codeaster/*/aster.conf'))
        for optrc in verslist:
            self._read_rc(optrc,  self.config, optional=True, mcsimp=['vers'])
        self._init_rc()

        # add user plugins directory
        sys.path.append(osp.join(get_home_directory(), self.rcdir))
        # ----- prepare tmp_user and cache_dir
        # no folder in cache_dir
        tmp_user = osp.join(self.config['rep_tmp'], 'astk_' + local_user_path)
        self.config['tmp_user'] = tmp_user
        self.config['cache_dir'] = osp.join(tmp_user, 'cache')
        # safer as osp.exists for multiple executions
        try:
            os.makedirs(tmp_user)
        except OSError:
            pass
        if not os.access(tmp_user, os.W_OK):
            print(ufmt(_('no write access to %s'), tmp_user))
            self.Sortie(4)

        # safer as osp.exists for multiple executions
        try:
            os.mkdir(self.config['cache_dir'])
        except OSError:
            pass

        # ----- check for 'flasheur'
        flash = osp.join(get_home_directory(), "flasheur")
        self.config['flasheur'] = flash
        # safer as osp.exists for multiple executions
        try:
            os.makedirs(flash)
        except OSError:
            pass
        if not os.access(flash, os.W_OK):
            print(ufmt(_('no write access to %s'), flash))
            self.Sortie(4)

        # ----- init timer
        self.timer = AsterTimer()
        self.LoadExtensions()
        self.CheckExtensions()


    def ParseArgs(self):
        """Call the arguments parser, returns options and arguments."""
        opts, args = self.parser.parse_args()
        # ----- all should have been initialized !
        self.__initialized = True

        # ----- stocke les options
        for option in self.options_list:
            self.options[option] = getattr(opts, option)

        if opts.display != None:
            os.environ['DISPLAY'] = opts.display
            self.DBG('set DISPLAY to', opts.display)

        # ----- migration
        if self.options['version_dev'] is not None:
            warn('--version_dev=... is deprecated. Use --vers=... instead.', DeprecationWarning, stacklevel=2)
            if self.options['aster_vers'] != self.options['version_dev']:
                warn('--vers=%s will be overwritten by --version_dev into --vers=%s' \
                 % (self.options['aster_vers'], self.options['version_dev']), DeprecationWarning, stacklevel=2)
            self.options['aster_vers'] = self.options['version_dev']

        args = [to_unicode(arg) for arg in args]
        return opts, args


    def _init_rc(self):
        """Read user preferences or create the file the first time"""
        ficrc = self.user_rc
        dname = osp.dirname(ficrc)
        # ----- check for ressources directory
        # safer as osp.exists for multiple executions
        try:
            os.makedirs(dname)
        except OSError:
            pass

        if not osp.isfile(ficrc):
            # create ressources file
            from asrun.client import ClientConfig
            try:
                client = ClientConfig(self.rcdir)
                client.init_user_resource(osp.basename(ficrc))
            except (OSError, IOError):
                # permission denied into rcdir
                pass
        if osp.isfile(ficrc):
            # read user ressource file if exists
            self._read_rc(ficrc, self.config, mcsimp=['vers', 'noeud'], optional=True)
        self._check_config()


    def _read_rc(self, ficrc, destdict, optional=False, mcsimp=None):
        """Read a ressource file and store variables to 'destdict'."""
        if osp.isfile(ficrc):
            read_rcfile(ficrc, destdict, mcsimp=mcsimp)
        elif not optional:
            print(ufmt(_('file not found : %s'), ficrc))
            self.Sortie(4)


    def _check_config(self):
        """Check configuration for deprecated fields or arguments."""
        for key in ("editor", "editeur", "terminal"):
            value = self.config.get(key, None)
            # always used current display (eventually set by "ssh -X")
            if value and value.find('@D') > -1:
                warn("'%s' : the argument '@D' is deprecated. "
                     "Remove it from your configuration file." % key,
                     DeprecationWarning, stacklevel=2)
                # remove display
                self.config[key] = re.sub('\-+display[ =]+@D', '', value)


    def _add_action(self, action, info):
        """Set informations about an action
        Prefer use this method over extend manually the dictionnary."""
        if not type(action) in (str, str):
            self.Mess(_('invalid type (expect %s not %s)') % \
                    ('string', type(action)), '<F>_PROGRAM_ERROR')
        if not type(info) is dict:
            self.Mess(_('invalid type (expect %s not %s)') % \
                    ('dict', type(info)), '<F>_PROGRAM_ERROR')
        if action in list(self.actions_info.keys()):
            self.Mess(_('action already defined : %s') % action,
                    '<F>_PROGRAM_ERROR')
        else:
            self.actions_info[action] = info


    def _add_option(self, *args):
        """Add one or more option which will be available through getitem.
        Prefer use this method over extending manually the list."""
        if not type(args) in (list, tuple):
            self.Mess(_('invalid type (expect %s not %s)') % \
                    ('string', type(args)), '<F>_PROGRAM_ERROR')
        for opt in args:
            if opt in self.options_list:
                self.Mess(_('option already defined : %s') % opt,
                    '<F>_PROGRAM_ERROR')
            else:
                self.options_list.append(opt)


    def LoadExtensions(self):
        """Initialisations des extensions."""
        import asrun.maintenance
        import asrun.execute
        import asrun.services
        import asrun.job
        import asrun.rex
        import asrun.bddetudes
        asrun.execute.SetParser(self)
        asrun.maintenance.SetParser(self)
        asrun.services.SetParser(self)
        asrun.job.SetParser(self)
        asrun.rex.SetParser(self)
        asrun.bddetudes.SetParser(self)


    def CheckExtensions(self):
        """Initialisations des éventuelles extensions."""
        user_extensions    = osp.join(get_home_directory(), self.rcdir, 'as_run.extensions')
        cwd_extensions     = 'as_run.extensions'
        config = ConfigParser()
        l_read = config.read([user_extensions, cwd_extensions])

        l_ext = config.sections()
        for extension in l_ext:
            try:
                filename = osp.splitext(config.get(extension, 'module'))[0]
                if self['verbose']:
                    print(ufmt(_('Loading extension %s from %s...'), extension, filename))
                module = __import__(filename, globals(), locals(), ['SetParser'])
                init_function = getattr(module, 'SetParser')
                init_function(self)
                if self['verbose']:
                    print(_('Extension %s loaded') % extension)
            except (ImportError, NoOptionError) as msg:
                print(_('Extension %s not loaded (reason : %s)') % (extension, msg))


    def SetActions(self, actions_descr, **dico):
        """Add new actions to the parser configuration
            actions_descr  : description of each action :
                key   = action name,
                value = {syntax, help, method}
        optional arguments :
            actions_order  : order to display actions in help (default to '' :
                arbitrary order of dico.keys method)
            group_options  : add a option group to list options (default to True)
            group_title    : title of the option group (default to '')
            actions_group_title : list actions names in the title between
                parenthesis (default to True)
            options_descr  : description of each option (default to {}) :
                key   = option name,
                value = {args, kwargs} passed to add_option parser method
            stored_options : list of options which should be available using
                getitem (default to all "dest" from options_descr)"""
        # ----- default values
        # actions_order
        if 'actions_order' in dico:
            lacts = dico['actions_order']
        else:
            lacts = list(actions_descr.keys())
            lacts.sort()
        # title
        if 'group_title' in dico:
            title = dico['group_title']+' ('
        else:
            title = ''
        # actions_group_title
        if 'actions_group_title' not in dico:
            dico['actions_group_title'] = True
        #  group_options
        if 'group_options' not in dico:
            dico['group_options'] = True
        # options_descr
        if 'options_descr' not in dico:
            dico['options_descr'] = {}
        # stored_options
        if 'stored_options' not in dico:
            dico['stored_options'] = [d["kwargs"]['dest'] \
                    for d in list(dico['options_descr'].values())]
        # ----- check types
        # dict
        for obj in (actions_descr, dico['options_descr']):
            if not type(obj) is dict:
                self.Mess(_('invalid type (expect %s not %s)') % \
                        ('dict', type(obj)), '<F>_PROGRAM_ERROR')
        # list
        for obj in (lacts, dico['stored_options']):
            if not type(obj) is list:
                self.Mess(_('invalid type (expect %s not %s)') % \
                        ('list', type(obj)), '<F>_PROGRAM_ERROR')
        prem = True
        for act in lacts:
            descr = actions_descr[act]
            # ----- actions_info
            self._add_action(act, { 'method' : descr['method'] })
            # ----- parser
            if descr['help'] != SUPPRESS_HELP:
                new_usage = self.parser.get_usage()+ \
                    (self.fmt['usage'] % \
                        (descr['help'], 'as_run --'+act+' '+descr['syntax']))
                self.parser.set_usage(new_usage)
            self.parser.add_option('--'+act,
                    action='store_const_once', dest='action', const=act,
                    help=SUPPRESS_HELP)
            if not prem:
                title = title+', '
            prem = False
            title = title+('%r' % act)
        title = title+') '
        if not dico['actions_group_title']:
            title = dico['group_title']
        # ----- specific options
        if dico['group_options']:
            group = OptionGroup(self.parser, title=title)
            self.parser.add_option_group(group)
        else:
            group = self.parser
        for opt, descr in list(dico['options_descr'].items()):
            group.add_option(*descr['args'], **descr['kwargs'])
        # ----- add options to the options list to store
        self._add_option(*dico['stored_options'])


    def PrintConfig(self):
        """Imprime la liste et la valeur des paramètres"""
        self.parser.print_version()
        print(os.linesep+_('Parameters (config attribute)')+' :')
        for key, val in list(self.config.items()):
            print(self.fmt['verb1'] % (key, val))
        print(os.linesep+_('Options (options attribute)')+' :')
        for key, val in list(self.options.items()):
            print(self.fmt['verb1'] % (key, val))


    def ToDelete(self, path):
        """Add 'path' to to_delete list."""
        if not path in self.to_delete:
            self.to_delete.append(path)


    def DoNotDelete(self, path):
        """Remove 'path' from to_delete list."""
        if path in self.to_delete:
            self.to_delete.remove(path)


    def _clear_tmp(self):
        """Empty cache directory if necessary (remove files for which last access
        is older than 'deltat' seconds), and delete all directories
        from 'self.to_delete'."""
        # to avoid to delete current directory (it may freeze some systems...)
        try:
            os.chdir(get_home_directory())
        except OSError:
            print(_("Can not change to the home directory ('%s'). "
                      "Temporay files have not been deleted.") % get_home_directory())
            return
        ct = time.time()
        deltat = 24*3600
        # ----- config is not set during __init__
        if self.__initialized:
            if self['verbose']:
                print(_('Clear cache directory')+' '+self['cache_dir']+'...')
            # ----- avoid deleting such folders : /, /usr or /home !!!
            if re.search('^/.+/.*', self['cache_dir']):
                for root, dirs, files in os.walk(self['cache_dir'], topdown=False):
                    for name in files:
                        if ct - os.stat(osp.join(root, name)).st_atime > deltat:
                            os.remove(osp.join(root, name))
                        for name in dirs:
                            try:
                                os.rmdir(osp.join(root, name))
                            except OSError:
                                pass
            # ----- delete each directory in list_dirs
            if self['verbose']:
                print(_('Clear temporary files/directories'))
            # if a Delete system function has been added
            if hasattr(self, 'Delete'):
                to_del = [d for d in get_subdirs(self.to_delete) if d.startswith('/')]
                for d in to_del:
                    getattr(self, 'Delete')(d)


    def __getitem__(self, key):
        """Méthode pour accéder facilement aux paramètres de configuration ou à la
        valeur d'une option.
        Les options surchargent les paramètres de configuration."""
        UNDEF = "__undefined__"
        if hasattr(self, '__'+key+'__'):
            return getattr(self, '__'+key+'__')
        elif self.options.get(key, UNDEF) != UNDEF:
            return self.options[key]
        elif self.config.get(key, UNDEF) != UNDEF:
            return self.config[key]
        elif self.__initialized:
            self.Mess(_("""'%s' does not exist in config or options.
 Perhaps it must be defined in %s.""") % (key, self.user_rc), \
                    '<F>_PROGRAM_ERROR')


    def get(self, key, default=None):
        """Semblable à getitem avec la possibilité de retourner une valeur par défaut
        si la valeur n'est pas trouvée."""
        if hasattr(self, '__'+key+'__'):
            return getattr(self, '__'+key+'__')
        elif self.options.get(key) != None:
            return self.options[key]
        elif self.config.get(key) != None:
            return self.config[key]
        else:
            return default


    def get_pid(self, num=None):
        """Return a jobid based on self['num_job'].
        Counter is incremented at each call."""
        return get_unique_id(self['num_job'], num)


    def get_versions_dict(self):
        """Return a dict of the available versions indexed with their label.
        The versions are defined in etc/codeaster/aster + $HOME/.astkrc/prefs."""
        dict_vers = {}
        if self.get('vers'):
            for vname in self['vers'].split():
                if len(vname.split(':')) == 2:
                    key, vname = vname.split(':')
                else:
                    key = osp.basename(vname)
                if dict_vers.get(key) is not None:
                    self.Mess(_("%s is already known as %s (%s is ignored). Check your configuration file : %s") \
                        % (key, dict_vers[key], vname, osp.join(confdir, "aster")), "<A>_ALARM")
                    continue
                dict_vers[key] = vname
        return dict_vers

    def get_ordered_versions(self):
        """Return the version labels ordered as defined in the
        configuration files."""
        lv = []
        if self.get('vers'):
            for vname in self['vers'].split():
                if len(vname.split(':')) == 2:
                    key, vname = vname.split(':')
                else:
                    key = osp.basename(vname)
                if key not in lv:
                    lv.append(key)
        return lv

    def get_version_path(self, label, root=aster_root):
        """Return full path to the version named 'label'."""
        if not label:
            return None
        dict_vers = self.get_versions_dict()
        return osp.join(root, dict_vers.get(label, label))


    def PostConf(self):
        """Ajuste la configuration dynamiquement (car dépendance au contexte et
        pas seulement au fichier 'config').
        Paramètres déclenchants :
            serv_as_node, only_serv_as_node, limits"""
        if not self.__initialized or not hasattr(self, 'GetHostName'):
            print(_('Warning : AsterRun object not ready for dynamic adjustement !'))
            return

        # add localhost as a compute node
        if self.config.get('serv_as_node', False):
            l_node = self.config.get('noeud', '').split()
            if not local_full_host in l_node and not local_host in l_node:
                l_node.insert(0, local_host)
            if self.config.get('only_serv_as_node', False):
                l_node = [local_host,]
            self.config['noeud'] = ' '.join(l_node)

        # hard limits
        self.SetAutoLimit()
        # trace installation parameter
        self.DBG('installation dirs (aster_root, confdir, localedir, LANG)',
                    aster_root, confdir, localedir, os.environ.get('LANG', 'undefined'))


    def SetAutoLimit(self):
        """Set memory & cpu limits.
        Must be called after the initialization of the system object."""
        dlim_i = get_limits(self, 'interactif')
        dlim_b = get_limits(self, 'batch')
        self.config.update(dlim_i)
        self.config.update(dlim_b)


    def GetGrav(self, cod):
        """Return the severity behind 'cod' as a number to allow comparison"""
        dgrav = { '?' : -9, '_' : -9, 'OK' : 0, 'A' : 1,
                'NO_TEST_RESU' : 1.9, 'NOOK' : 2,
                'S' : 4,
                'E' : 6, 'NO_RESU_FILE' : 6,
                'F' : 10 }
        g = dgrav['?']
        mat = re.search('<(.)>', cod)
        if cod in list(dgrav.keys()):
            g = dgrav[cod]
        elif re.search('NOOK', cod):
            g = dgrav['NOOK']
        elif mat != None:
            try:
                g = dgrav[mat.group(1)]
            except KeyError:
                pass
        return g


    def Mess(self, msg, cod='', store=False):
        """Print a message sur stdout,
        'cod' is an error code (format "<.>_...")
            <E> : continue,
            <F> : stop,
            <A> : alarm, continue,
            '' or INFO : for an info,
            SILENT : like an info without <INFO> string,
            TITLE : add a separator.
        If cod='<F>' (without a description), if exists last <E> error is
        transformed into <F>, else <F>_ABNORMAL_ABORT.
        If store is True, 'msg' is stored in print_on_exit dictionnary."""
        # ----- gravite
        g0 = self.GetGrav(self.diag)
        g1 = self.GetGrav(cod)
        coderr = cod
        if cod == '<F>':
            if g0 < self.GetGrav('<E>'):
                coderr =  '<F>_ABNORMAL_ABORT'
            else:
                coderr = self.diag.replace('<E>', '<F>')
        if g1 >= self.GetGrav('<A>'):
            self.DBG('Warning or error raised :', '%s %s' % (cod, msg),
                        print_traceback=True)

        # ----- message
        if cod == '' or cod == 'INFO':
            fmt = self.fmt['msg_info']
            coderr = ''
        elif cod == 'SILENT':
            fmt = self.fmt['silent']
            coderr = ''
        elif cod == 'TITLE':
            fmt = self.fmt['title']
            coderr = ''
        else:
            fmt = self.fmt['msg+cod']
            # unknown flag
            if g1 == -9:
                coderr = '<I> '+coderr
        print(ufmt(fmt, coderr, msg))
        magic.get_stdout().flush()
        # ----- store in print_on_exit
        if store or (not self.ExitOnFatalError and g1 >= self.GetGrav('<S>')):
            k = '?'
            msg2 = msg
            mat = re.search('<(.)>', cod)
            if mat != None and mat.group(1) in ('A', 'S', 'E', 'F'):
                k = mat.group(1)
                msg2 = self.fmt['msg+cod'] % (coderr, msg)
            elif cod in ('OK', 'NOOK'):
                k = cod
            self.print_on_exit[k] = self.print_on_exit.get(k, []) + [msg2, ]

        # ----- diagnostic le plus défavorable
        if g1 > g0:
            self.diag = coderr
            if g1 == self.GetGrav('<F>'):
                self.Sortie(4)


    def get_important_messages(self, reinit=False):
        """Return the important messages previously emitted."""
        titles = {
            '?'      : _('Important messages previously printed :')+os.linesep,
            'OK'     : _('Successful messages previously printed:')+os.linesep,
            'NOOK'   : _('NOOK messages previously printed:')+os.linesep,
            'A'      : _('<A> Alarms previously raised :')+os.linesep,
            'S'      : _('<S> errors previously raised :')+os.linesep,
            'E'      : _('<E> errors previously raised :')+os.linesep,
            'F'      : _('<F> errors previously raised :')+os.linesep,
        }
        msg = []
        for k, tit in list(titles.items()):
            lmsg = self.print_on_exit.get(k, [])
            if len(lmsg) > 0:
                msg.append(self.fmt['title'] % (tit, ""))
                msg.extend(lmsg)
        if reinit:
            self.print_on_exit = {}
        return os.linesep.join(msg)


    def Sortie(self, exit_code):
        """Exit by printing diagnostic if defined or exit code if not null"""
        # print important messages
        msg = self.get_important_messages()
        if len(msg) > 0:
            print(msg)

        # raise an exception to be catched by the Worker object
        if not is_main_thread():
            raise TaskAbort(msg)

        # helps to locate error in PROGRAM_ERROR case or in verbose mode
        if self.diag == '<F>_PROGRAM_ERROR' \
                or (exit_code != 0 and (self['debug'] or self['verbose'] or not self.ExitOnFatalError)):
            self.DBG('### Raise RunAsterError exception because of program error or debug mode ###')
            raise RunAsterError(exit_code)

        # stop all timers
        if self.print_timer and hasattr(self, 'timer'):
            print(os.linesep, self.timer)
        if self.print_timer: # related to non silent actions
            print(self.program + ' ' + self.__version__)

        if self.diag:
            # change <E> to <F>
            self.diag = self.diag.replace('<E>', '<F>')
            print(self.fmt['diag'] % self.diag)
            if exit_code == 0 and \
               ("NOOK" in self.diag or self.diag == "NO_TEST_RESU"):
                exit_code = 1
        if self.PrintExitCode or exit_code != 0:
            print(self.fmt['exit'] % exit_code)
        self._clear_tmp()
        self.DBG("exit %s" % exit_code)
        sys.exit(exit_code)


    def CheckOK(self, tole='<S>'):
        """Exit one error more severe than 'tole' occurred."""
        if self.GetGrav(self.diag) >= self.GetGrav(tole):
            self.Sortie(4)


    def ReinitDiag(self, diag='?'):
        """Reinitialize diagnostic (for example if a global diagnostic is stored)"""
        self.diag = diag


    def check_version_setting(self):
        """Check version is defined."""
        if not self.get('aster_vers'):
            self.parser.error(_("You must define 'default_vers' in 'aster' configuration " \
                                "file or use '--vers' option."))

    def _get_msecs(self):
        ct =  time.time()
        return (ct - int(ct)) * 1000


    def _printDBG(self, *args, **kargs):
        """Print debug information to stderr."""
        print_traceback = kargs.get('print_traceback', True)
        ferr            = kargs.get('file', magic.get_stderr())
        stack_id        = -3 - kargs.get('stack_id', 0)      # -1 : _printDBG, -2 : DBG ou ASSERT
        all             = kargs.get('all', False)
        prefix = kargs.get('prefix', '')
        try:
            form = """
>>> %(time)12s  %(orig)s
%(content)s%(traceback)s"""
            formTB = """
Traceback:
%s
"""
            stack = traceback.format_stack(limit=10)
            try:
                ls = []
                for a in args:
                    if type(a) in (str, str):
                        ls.append(a)
                    else:
                        ls.append(pprint.pformat(a))
                content = os.linesep.join(convert_list(ls))
                if not all and len(content) > 800:
                    content = content[:800] + os.linesep + '[...]'
            except None:
                content = str(args)
            if prefix:
                content = os.linesep.join([prefix + lin for lin in content.splitlines()])
            dinfo = {
                'time'      : time.strftime('%Y/%m/%d-%H:%M:%S') + '.%03d' % self._get_msecs(),
                'orig'      : stack[stack_id],
                'content'   : content,
                'traceback' : '',
            }
            try:
                mat = re.search('File [\'\"]*(.*?)[\'\"]*, *line ([0-9]+), *in (.*)', dinfo['orig'])
                dinfo['orig'] = '[%s@%s:%s]' % (mat.group(3), mat.group(1), mat.group(2))
            except None:
                pass
            if print_traceback:
                dinfo['traceback'] = formTB % (''.join(stack))
            print(form % dinfo, file=ferr)
            ferr.flush()
        except None:
            pass


    def DBG(self, *args, **kargs):
        """Print debug information to stderr."""
        print_traceback = kargs.get('print_traceback', False)
        ferr            = kargs.get('file', magic.get_stderr())
        stack_id        = kargs.get('stack_id', 0)
        all             = kargs.get('all', False)
        prefix = kargs.get('prefix', '')
        if ((not hasattr(ferr, "isatty") or not ferr.isatty()) or self['debug'] or self['verbose']) \
                and (self['debug_stderr'] or ferr != sys.stderr):
            self._printDBG(print_traceback=print_traceback, file=ferr,
                           stack_id=stack_id, all=all, prefix=prefix, *args)

    def ASSERT(self, condition):
        """Print errors to stdout and stderr."""
        if not condition:
            for f in (magic.get_stdout(), magic.get_stderr()):
                self._printDBG('Assertion failed', print_traceback=True, file=f, stack_id=0)

    def get_as_run_cmd(self, with_args=True):
        """Return as_run command line (type list)."""
        cmd = [osp.join(aster_root, "bin", get_exec_name("as_run")),]
        if with_args:
            cmd.extend(self.get_as_run_args())
        return cmd

    def get_as_run_args(self):
        """Return arguments for as_run command line (type list)."""
        args = []
        args.extend(self.get_rcdir_arg())
        args.extend(self.get_remote_args())
        return args

    def get_rcdir_arg(self):
        """Return rcdir argument for as_run command line (type list)."""
        args = []
        if self.rcdir != ".astkrc":
            args.append("--rcdir=%s" % get_option_value(["--rcdir=%s" % self.rcdir], "--rcdir"))
        return args

    def get_remote_args(self):
        """Return remote arguments for as_run command line."""
        #XXX should be deprecated in future
        return ["--remote_shell_protocol=%s" % self['remote_shell_protocol'],
                "--remote_copy_protocol=%s" % self['remote_copy_protocol'],]

    def set_logger(self, log_progress, stderr=None):
        """Wrapper to set the loggers."""
        if stderr:
            magic.set_stderr(stderr)
        magic.init_logger(filename=log_progress, debug=self['debug'])


def AsRunFactory(*args, **kargs):
    """Initialization of an AsterRun object"""
    # pre 1.8 backward compatibility : astk_serv_root argument removed
    if len(args) != 0:
        warn('AsRunFactory : astk_serv_root argument is deprecated', DeprecationWarning, stacklevel=2)

    from asrun.system import AsterSystem

    run = AsterRun(**kargs)
    run.options['debug']   = False
    run.options['debug_stderr'] = True
    run.options['verbose'] = False
    run.options['force']   = False
    run.options['num_job'] = str(os.getpid())
    run.options['log_progress'] = None
    for opt, value in list(kargs.items()):
        if opt in run.options:
            run.options[opt] = value
        elif opt in run.config:
            run.config[opt] = value
    run.system = AsterSystem(run, **kargs)
    run.print_timer = False
    run.SetAutoLimit()
    magic.run = run
    run.set_logger(run['log_progress'], kargs.get('stderr'))
    return run

ASTER_RUN = bwc_deprecate_class('ASTER_RUN', AsterRun)
