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
Build a list of testcases using a list of command/keywords and/or
verifying some criterias about cputime or memory.
"""
PARAMS = ('memory_limit', 'memjob', 'time_limit', 'tpsjob', 'mem_aster',
          'ncpus', 'mpi_nbnoeud', 'mpi_nbcpu', 'testlist')

import os
import os.path as osp
import re
from glob         import glob

from asrun.core import magic
from asrun.installation import aster_root
from asrun.common.i18n import _
from asrun.mystring     import ufmt
from asrun.profil       import AsterProfil
from asrun.config       import build_config_of_version
from asrun.progress     import Progress
from asrun.common.utils import getpara, get_list, list_para_test, force_list


class FILTER(object):
    """Permet de savoir si on conserve un test ou non.
    La méthode 'check' retourne True si on doit conserver le test, False sinon.
    Les arguments sont :
        test : nom du cas-test avec le répertoire, sans l'extension
        para : dictionnaire des paramètres (fichier .para)
        jdc  : texte du jeu de commandes (fichiers *.com?)
    """


class FILTER_REGEXP(FILTER):
    """Le contenu du fichier de commandes doit vérifiée une expression régulière.
    """
    def __init__(self, s_regexp, flags=re.MULTILINE | re.DOTALL):
        """s_regexp : chaine de l'expression qui doit être vérifiée.
        """
        print(ufmt(_(" - regular expression : %s"), repr(s_regexp)))
        self.regexp = re.compile(s_regexp, flags)

    def check(self, **kwargs):
        """Applique le filtre.
        Argument : jdc
        """
        content = kwargs.get('jdc', '')
        mat = self.regexp.search(content)
        return mat is not None


class FILTER_PARA(FILTER):
    """Les paramètres du cas-test doivent vérifiée une condition.
    """
    def __init__(self, s_cond):
        """s_cond : texte de la condition
        """
        self.condition = s_cond

    def check(self, **kwargs):
        """Applique le filtre.
        Argument : para
        """
        para = kwargs.get('para', {})
        try:
            keep = eval(self.condition, para)
        except KeyError:
            keep = False
        return keep


class LISTE_CT(object):
    """Classe permettant de lire un ensemble de fichiers de tests et d'effectuer
    un filtre selon certains critères afin d'extraire une liste de cas-test.
    """
    def __init__(self, astest_dir, all=False, verbose=True):
        """Initialisations
        """
        self.astest_dir = force_list(astest_dir)
        self.liste_ct = []
        self.alltest = all
        self.filter = []
        self.liste_crit = []
        self.list_para_test = list_para_test
        self.verbose = verbose
        if self.verbose:
            print(ufmt(_('Directory of testcases : %s'), self.astest_dir))

    def add_ct(self, l_file):
        """Ajoute des cas-tests dans la liste.
        """
        new_ct = set()
        if len(l_file) == 0 and self.alltest:
            if self.verbose:
                print(ufmt(_("Searching '*.export' from %s..."), ','.join(self.astest_dir)))
            l_file = '*'
        # sans extension
        for ct in l_file:
            l_gl = self.filename(ct, 'export', first_only=False)
            new_ct.update([osp.basename(osp.splitext(t)[0]) for t in l_gl])
        new_ct.update(self.liste_ct)
        self.liste_ct = list(new_ct)
        self.liste_ct.sort()
        if self.verbose:
            print(ufmt(_('%6d testcases in the list.'), len(self.liste_ct)))

    def filename(self, ct, ext, first_only=True):
        """Retourne la liste des fichiers du cas-test qui existent dans les
        répertoires."""
        lf = []
        for tdir in self.astest_dir:
            lf.extend(glob(osp.join(tdir, '%s.%s' % (ct, ext))))
        if first_only and len(lf) >= 1:
            lf = lf[0]
        return lf

    def read_para_ct(self, ct):
        """Lecture des paramètres d'un cas-test"""
        export = self.filename(ct, 'export')
        if not export:
            para = self.filename(ct, 'para')
            assert para, 'neither .export or .para found for %s' % ct
            return getpara(para, others=['liste_test'])
        pexp = AsterProfil(export, magic.run)
        dpara = {}
        for key in PARAMS:
            val = pexp[key][0]
            if type(val) is str and val.isdigit():
                dpara[key] = int(val)
            else:
                try:
                    dpara[key] = float(val)
                except ValueError:
                    dpara[key] = val
        # compatibility
        dpara['mem_job'] = dpara['memory_limit']
        dpara['tps_job'] = dpara['time_limit']
        return 0, dpara, ''

    def decode_cmde(self, txt0):
        """Retourne une expression régulière pour filtrer sur les commandes
        utilisées.
            txt = COMMANDE[/MOTCLEFACT[/MOTCLE[=VALEUR]]]
        """
        #txt = re.split('[/=]+', txt.strip())
        txt = txt0.strip().split('/')
        d = {
            'cmde' : txt.pop(0),
            'mcfact' : '',
            'mcsimp' : '',
            'valeur' : '',
        }
        if len(txt) > 0:
            dern = txt.pop()
            mcsimp = dern.split('=')
            d['mcsimp'] = '.*%s' % mcsimp.pop(0)
            if len(mcsimp) > 0:
                d['valeur'] = ' *=.*%s' % mcsimp.pop()
                assert len(txt) == 0, '>>> trop de valeurs : %s' % dern
        if len(txt) > 0:
            d['mcfact'] = '.*%s *= *_F *\(' % txt.pop()
        assert len(txt) == 0, '>>> trop de valeurs : %s' % txt0

        expr = '%(cmde)s *\(%(mcfact)s%(mcsimp)s%(valeur)s' % d
        return expr

    def add_filter(self, typ, *args):
        """Ajoute un ou plusieurs filtres.
            typ = 'regexp', 'para' ou 'user'.
        """
        if typ == 'command':
            assert len(args) == 1
            expr = self.decode_cmde(args[0])
            if expr is not None:
                self.filter.append(FILTER_REGEXP(expr))
        elif typ == 'regexp':
            assert len(args) == 1
            expr = args[0]
            if expr is not None:
                self.filter.append(FILTER_REGEXP(expr))
        elif typ == 'para':
            assert len(args) == 1
            self.filter.append(FILTER_PARA(args[0]))
        elif typ == 'user':
            assert len(args) == 1
            d = globals().copy()
            with open(args[0]) as f:
                exec(compile(f.read(), args[0], 'exec'), d)
            if 'user_filter' in d:
                if type(d['user_filter']) in (list, tuple):
                    l_filter = d['user_filter']
                else:
                    l_filter = [d['user_filter'],]
                for ff in l_filter:
                    assert isinstance(ff, FILTER)
                self.filter.extend(l_filter)
        else:
            print('>>> unknown filter type (%s) : ignored.' % typ)

    def build_list(self):
        """Applique les filtres et retourne la liste des cas-test obtenue.
        """
        l_type = [type(f) for f in self.filter]
        need_content = FILTER_REGEXP in l_type
        need_para    = FILTER_PARA in l_type
        ignored = set()
        if self.verbose:
            p = Progress(maxi=len(self.liste_ct), format='%5.1f %%',
                            msg='Analyse des cas-tests... ')
        n_ign = 0
        for i, ct in enumerate(self.liste_ct):
            if self.verbose:
                p.Update(i)
            # texte du jdc
            if need_content:
                l_content = []
                for fic in self.filename(ct, 'com*', first_only=False):
                    with open(fic, 'r') as f:
                        l_content.append(f.read())
                jdc = os.linesep.join(l_content)
            else:
                jdc = ''
            # paramètres du test
            if need_para:
                iret, d_para, err = self.read_para_ct(ct)
                if iret != 0:
                    n_ign += 1
                    if self.verbose:
                        print(err)
            else:
                d_para = {}
            # application des filtres
            for filter in self.filter:
                if not filter.check(jdc=jdc, para=d_para, test=self.filename(ct, '')):
                    ignored.add(ct)
                    break
        if self.verbose:
            p.End()
        res = list(set(self.liste_ct).difference(ignored))
        res.sort()
        if self.verbose:
            print('%6d tests analysés sur %d (%d ignorés)' \
                % (len(self.liste_ct) - n_ign, len(self.liste_ct), n_ign))
            print('%6d tests dans la liste' % len(res))
        return res


def TestList(run, *args):
    """Build a list of testcases.
    """
    if not run.get('aster_vers'):
        run.parser.error(_("You must define 'default_vers' in 'aster' configuration file or use '--vers' option."))
    REPREF = osp.join(aster_root, run['aster_vers'])
    fconf = run.get('config')
    if fconf:
        fconf = osp.abspath(fconf)
    conf = build_config_of_version(run, run['aster_vers'], fconf)

    l_ct = list(args)
    if len(l_ct) < 1 and not (run['all_test'] or run.get('test_list')):
        run.parser.error(
                _("'--%s' : you must give testcase names or use one of --all/--test_list option") \
                % run.current_action)
    if run.get('test_list'):
        iret, l_lue = get_list(run['test_list'])
        if iret == 0:
            l_ct.extend(l_lue)
        else:
            run.Mess(ufmt(_('error during reading file : %s'), run['test_list']), '<F>_ERROR')

    l_dirs = run.get('astest_dir', ','.join(conf['SRCTEST']))
    l_dirs = [osp.abspath(osp.join(REPREF, p.strip())) for p in l_dirs.split(',')]

    run.PrintExitCode = False
    if run['debug']:
        run.DBG('astest_dir', l_dirs)
        run.DBG('filter', run.get('filter'))
        run.DBG('command', run.get('command'))
        run.DBG('search', run.get('search'))

    filtre = LISTE_CT(astest_dir=l_dirs, all=run['all_test'], verbose=not run['silent'])
    filtre.add_ct(l_ct)
    res = []
    # add filters on parameters
    if run.get('filter'):
        for expr in run['filter']:
            filtre.add_filter('para', expr)
            if run['debug']:
                res.append('%% filter on parameter : %s' % expr)
    # add filters based on command used
    for expr in run.get('command', []):
        filtre.add_filter('command', expr)
        if run['debug']:
            res.append('%% filter on command : %s' % expr)
    # add filters based on regular expression
    for expr in run.get('search', []):
        filtre.add_filter('regexp', expr)
        if run['debug']:
            res.append('%% filter on regexp : %s' % expr)
    # add user filters
    if run.get('user_filter'):
        for f in run['user_filter']:
            filtre.add_filter('user', f)
            if run['debug']:
                res.append('%% user filter, file : %s' % f)

    res.extend(filtre.build_list())

    result = os.linesep.join(res)
    if run.get('output'):
        with open(run['output'], 'w') as f:
            f.write(result)
        print(ufmt(_('The results have been written into the file : %s'), run['output']))
    else:
        print(result)
