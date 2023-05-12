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
This class define a 'light' modified parser :
    - change exit method which exits using run.Sortie method
    - add an action 'store_const_once' to the parser.
"""

import os
from optparse import OptionParser, SUPPRESS_HELP, Option, OptionError, OptionValueError

from asrun.common.i18n  import _
from asrun.__pkginfo__  import version, copyright
from asrun.mystring     import convert
from asrun.core         import magic


class AsRunOption(Option):
    """Add 'store_const_once' action, it works like 'store_const' except that
    a value can be stored only once, next occurences will raise an error.
    """
    ACTIONS = Option.ACTIONS + ("store_const_once",)
    STORE_ACTIONS = Option.STORE_ACTIONS + ("store_const_once",)
    TYPED_ACTIONS = Option.TYPED_ACTIONS + ("store_const_once",)

    def take_action (self, action, dest, opt, value, values, parser):
        """Uses 'store_const_once' or standard actions.
        """
        if action == "store_const_once":
            # ----- store_const_once
            if not hasattr(values, dest) or not getattr(values, dest):
                setattr(values, dest, getattr(self, 'const'))
            else:
                raise OptionValueError("%r is invalid because '%s' previously occurs" \
                        % (getattr(self, 'const'), dest))
        else:
            # ----- standard actions
            Option.take_action(self, action, dest, opt, value, values, parser)

    def _check_const (self):
        if self.action != "store_const" and self.action != "store_const_once" \
                and getattr(self, 'const') is not None:
            raise OptionError(
                    "'const' must not be supplied for action %r" % self.action, self)

    # ----- because of changes to private method _check_conf
    CHECK_METHODS = [Option._check_action,
                    Option._check_type,
                    Option._check_choice,
                    Option._check_dest,
                    _check_const,
                    Option._check_nargs,
                    Option._check_callback]


class AsRunParser(OptionParser):
    """Modify lightly the standard parser.
    """
    def __init__(self, run, *args, **kwargs):
        """Initialization."""
        self.run = run
        # set option_class = AsRunOption here
        OptionParser.__init__(self, option_class=AsRunOption, *args, **kwargs)


    def exit(self, status=0, msg=None):
        """Call 'run.Sortie' method instead of 'sys.exit'."""
        if msg:
            magic.get_stderr().write(convert(msg))
        self.run.PrintExitCode = False
        self.run.Sortie(status)


    #def get_usage(self):
        #return to_unicode(OptionParser.get_usage(self))
    def print_usage(self, file=magic.get_stdout()):
        """Print the usage message for the current program"""
        if self.usage:
            print(self.get_usage(), file=file)


# values used if arguments are not parsed (when using AsRunFactory for example)
default_options = {
    'verbose' : False,
    'silent'  : False,
    'num_job' : str(os.getpid()),
}


def define_parser(run):
    """Build argument parser.
    """
    p = AsRunParser(run,
        usage="""%prog action [options] [arguments]

  Functions :
""",
        version="""as_run %s
%s""" % (version, copyright))
    p.add_option('-v', '--verbose',
        action='store_true', dest='verbose', default=default_options['verbose'],
        help=_('increase verbosity'))
    p.add_option('--silent',
        action='store_true', dest='silent', default=default_options['silent'],
        help=_('run as silent as possible'))
    p.add_option('-g', '--debug',
        action='store_true', dest='debug', default=False,
        help=_('print debugging information'))
    p.add_option('--stdout',
        action='store', dest='stdout', default=None, metavar='FILE',
        help=_('allow to redirect messages usually written on sys.stdout'))
    p.add_option('--stderr',
        action='store', dest='stderr', default=None, metavar='FILE',
        help=_('allow to redirect messages usually written on sys.stderr '
                '(only asrun messages)'))
    p.add_option('--log_progress',
        action='store', dest='log_progress', default=None, metavar='FILE',
        help=_('redirect progress informations to a file instead of sys.stderr'))
    p.add_option('--nodebug_stderr',
        action='store_false', dest='debug_stderr', default=True,
        help=_('disable printing of debugging information to stderr'))
    p.add_option('-f', '--force',
        action='store_true', dest='force', default=False,
        help=_('force operations which can be cached (download, ' \
             'compilation...)'))
    p.add_option('--num_job',
        action='store', dest='num_job', default=default_options['num_job'],
        help=SUPPRESS_HELP)
    p.add_option('--display',
        action='store', dest='display', default=None,
        help=_('value of DISPLAY variable (NOTE : some functions read it from a file)'))
    p.add_option('--rcdir',
        action='store', dest='rcdir', default=None, metavar='DIR',
        help=_("use resources directory $HOME/'DIR' (default is .astkrc). "
            "Avoid absolute path because it will be passed to remote servers."))
    # options which override the server configuration
    #XXX howto to merge with SSHServer and co ?
    p.add_option('--remote_shell_protocol',
        action='store', dest='remote_shell_protocol', default='SSH',
        help=_('remote protocol used for shell commands'))
    p.add_option('--remote_copy_protocol',
        action='store', dest='remote_copy_protocol', default='SCP',
        help=_('remote protocol used to copy files and directories'))

    return p


def get_option_value(args_list, opt, default=None, action="store"):
    """Parse the arguments 'args_list' and return value of the option named 'opt'."""
    def fpass(err, *args, **kwargs):
        """do not exit"""
        raise
    if not type(opt) in (list, tuple):
        opt = [opt,]
    kwargs = { "dest" : "var", "action" : action }
    parser = OptionParser()
    parser.error = fpass
    parser.add_option(*opt, **kwargs)
    value = None
    if action == "store_true":
        value = False
    l_args = []
    # --help would raise print_help of the working parser
    if "-h" not in args_list and "--help" not in args_list:
        for arg in args_list:
            l_args.append(arg)
            try:
                options, args = parser.parse_args(l_args)
                value = options.var
            except Exception:
                l_args.pop(-1)
    if value is None:
        value = default
    return value
