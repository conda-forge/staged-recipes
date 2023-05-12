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
Tools for developpers :
    - search messages
"""


import os
import os.path as osp
import re
import pickle
import time
from glob import glob

from asrun.common.i18n import _
from asrun.mystring     import ufmt
from asrun.config       import AsterConfig, build_config_of_version
from asrun.build        import AsterBuild, unigest2dict
from asrun.progress     import Progress


class CataMessageError(Exception):
    """Error with a catalog of messages."""

    def __init__(self, fcata, reason):
        self.reason = reason
        self.fcata = fcata

    def __str__(self):
        return ufmt(_("%s: %s, error: %s"),
            self.__class__.__name__, self.fcata, self.reason)


class MessageError(Exception):
    """Error on a message."""

    def __init__(self, msgid, reason):
        self.reason = reason
        self.msgid = msgid

    def __str__(self):
        return "%s: %s, error: %s" \
            % (self.__class__.__name__, self.msgid, self.reason)


class MESSAGE_MANAGER(object):
    """Classe pour récupérer des informations sur le catalogue de messages.
    """
    def __init__(self, repref,
                 fort=('bibfor', 'bibf90'),
                 pyt='bibpyt',
                 capy='catapy',
                 cache_dict=None, verbose=True, force=False,
                 ignore_comments=True, debug=False,
                 surch_fort=[], surch_pyt=[], unig=None):
        """Initialisations."""
        if type(fort) not in (list, tuple):
            fort = [fort,]
        if type(surch_fort) not in (list, tuple):
            surch_fort = [surch_fort,]
        if type(surch_pyt) not in (list, tuple):
            surch_pyt = [surch_pyt,]
        self.repref          = repref
        self.fort            = [osp.join(repref, rep) for rep in fort]
        self.pyt             = osp.join(repref, pyt)
        self.capy            = osp.join(repref, capy)
        self.surch_fort      = [osp.abspath(d) for d in surch_fort]
        self.surch_pyt       = [osp.abspath(d) for d in surch_pyt]
        self.verbose         = verbose
        self.debug           = debug
        self.force           = force
        self.message_dir     = 'Messages'
        self.cache_dict      = cache_dict or osp.join('/tmp', 'messages_dicts.pick')
        self.ignore_comments = ignore_comments
        self.wrk_fort        = osp.join(os.getcwd(), 'F')
        self.wrk_pyt         = osp.join(os.getcwd(), 'PY')

        self.unig            = unig
        # init AsterConfig, AsterBuild objects
        fconf = osp.join(self.repref, 'config.txt')
        self.conf_obj  = AsterConfig(fconf, run=None)
        self.build_obj = AsterBuild(run=None, conf=self.conf_obj)
        if unig:
            # use with_fordepla=False not to mark moved files as removed
            self.unig = unigest2dict(unig, self.conf_obj, with_fordepla=True)

        if self.verbose:
            print('Repertoires :\n   REF=%s\n   FORTRAN=%s\n   PYTHON=%s\n   CAPY=%s' \
                % (self.repref, self.fort, self.pyt, self.capy))

        self.l_cata            = self._get_list_cata()
        self.l_src, self.l_pyt = self._get_list_src()
#      self._build_regexp()

    def read_cata(self):
        """Read all catalogues"""
        self._build_dict()
        self.print_stats()


    def _filename_cata(self, cata):
        """Retourne le nom du fichier associé à un catalogue."""
        name = osp.join(self.pyt, self.message_dir, cata + '.py')
        return name


    def _id2filename(self, msgid):
        """Retourne modelisa5 à partir de MODELISA5_46"""
        mat = re.search('([A-Z]+[0-9]*)_([0-9]+)', msgid)
        if mat == None:
            raise MessageError(msgid, _('invalid message id'))
        cata, num = mat.groups()
        return self._filename_cata(cata.lower()), int(num)


    def _filename2id(self, fcata, num):
        """Retourne MODELISA5_46 à partir de modelisa5"""
        return '%s_%d' % (osp.splitext(osp.basename(fcata))[0].upper(), num)


    def makedirs(self):
        """Crée les répertoires pour les fichiers modifiés
        """
        for d in (self.wrk_fort, self.wrk_pyt):
            if not osp.isdir(d):
                os.makedirs(d)


    def _get_list_cata(self):
        """Retourne la liste des catalogues de messages.
        """
        re_mess = re.compile('#@.*Messages')
        s_cata = set(glob(osp.join(self.pyt, self.message_dir, '*.py')))
        s_suppr = set()
        l_surch = []
        # ajouter la surcharge et retirer le catalogue d'origine
        for dsrc in self.surch_pyt:
            for f in glob(osp.join(dsrc, '*.py')) + glob(osp.join(dsrc, '*', '*.py')):
                with open(f, 'r') as f:
                    txt = f.read()
                if re_mess.search(txt):
                    l_surch.append(osp.abspath(f))
                    fsup = osp.join(self.pyt, self.message_dir, osp.basename(f))
                    if osp.exists(fsup):
                        s_suppr.add(fsup)
        s_cata.update(l_surch)
        if len(l_surch) > 0:
            print('%5d catalogues en surcharge : ' % len(l_surch))
            print(os.linesep.join(l_surch))

        s_cata = set([osp.abspath(f) for f in s_cata \
                if not osp.basename(f) in ['__init__.py', 'context_info.py', 'fermetur.py']])
        l_suppr = []
        if self.unig and len(self.unig['py']) > 0:
            l_suppr = [osp.abspath(osp.join(self.repref, f)) \
                                            for f in self.unig['py'] if f.find(self.message_dir) > -1]
            s_suppr.update(l_suppr)
        l_suppr = list(s_suppr)
        l_suppr.sort()
        if len(l_suppr) > 0:
            print('%5d catalogue(s) supprime(s) :' % len(l_suppr))
            if self.verbose: print(os.linesep.join(l_suppr))
        l_cata = list(s_cata.difference(s_suppr))
        l_cata.sort()
        return l_cata


    def check_cata(self):
        """Vérifie les catalogues.
        """
        if self.verbose:
            print('%5d catalogues dans %s + %s' \
                % (len(self.l_cata), self.pyt, self.surch_pyt))
        all_msg = []
        error_occurs = False
        for f in self.l_cata:
            try:
                cata = CATA(f)
                cata.check()
                all_msg.extend([self._filename2id(f, i) for i in cata])
                if self.verbose:
                    print(cata)
            except CataMessageError as msg:
                error_occurs = True
                print(msg)
                self.l_cata.remove(f)
        if error_occurs:
            raise CataMessageError(_("global"), _("errors occurred!"))
        all_msg = set(all_msg)

        # messages jamais appelés
        used = set(self.d_msg_call.keys())
        unused =  list(all_msg.difference(used))
        unused.sort()

        union = used.union(all_msg)
        not_found = list(used.difference(all_msg))
        not_found.sort()
        if self.verbose:
            print('%6d messages dans les catalogues' % len(all_msg))
            print('dont %6d messages appeles presents dans les catalogues' % (len(used) - len(not_found)))
            print('  et %6d messages inutilises' % len(unused))
            print('   + %6d messages appeles absents des catalogues' % len(not_found))
        #print '%6d messages total (union pour verif)' % len(union)
        return unused, not_found


    def _build_regexp(self):
        """Construit la liste des expressions régulières pour la recherche des messages.
        """
        l_regexp = []
        for cata in self.l_cata:
            cata = osp.splitext(osp.basename(cata))[0]
            l_regexp.append('%s_[0-9]+' % cata.upper())
        self.regexp = re.compile('|'.join(l_regexp))


    def _get_list_src(self):
        """Retourne la liste des routines fortran et python.
        """
        l_f   = self._get_list_fort()
        l_pyt = self._get_list_python()
        if self.verbose:
            print('%5d routines fortran dans %s + %s' % (len(l_f), self.fort, self.surch_fort))
            print('%5d modules python   dans %s + %s' % (len(l_pyt), self.pyt, self.surch_pyt))
        return l_f, l_pyt


    def _get_list_fort(self):
        """Retourne la liste des fichiers sources fortran/fortran90."""
        s_f = set()
        for dsrc in self.fort:
            s_f.update(glob(osp.join(dsrc, '*.f')))
            s_f.update(glob(osp.join(dsrc, '*', '*.f')))
            s_f.update(glob(osp.join(dsrc, '*.F')))
            s_f.update(glob(osp.join(dsrc, '*', '*.F')))
            s_f.update(glob(osp.join(dsrc, '*.F90')))
            s_f.update(glob(osp.join(dsrc, '*', '*.F90')))
        if self.build_obj.support('waf'):
            l_f = [osp.abspath(f) for f in s_f]
            l_f.sort()
            return l_f
        d_f = {}
        for f in s_f:
            assert d_f.get(osp.basename(f)) is None, 'ERROR : %s  (old : %s)' % (f, d_f[osp.basename(f)])
            d_f[osp.basename(f)] = f
        # surcharge
        s_surch = set()
        for dsrc in self.surch_fort:
            s_surch.update(glob(osp.join(dsrc, '*.f')))
            s_surch.update(glob(osp.join(dsrc, '*', '*.f')))
            s_surch.update(glob(osp.join(dsrc, '*.F')))
            s_surch.update(glob(osp.join(dsrc, '*', '*.F')))
        if len(s_surch) > 0:
            l_surch = list(s_surch)
            l_surch.sort()
            print('%5d sources en surcharge : ' % len(l_surch))
            print(os.linesep.join(l_surch))
        # retirer des sources originaux ceux de la surcharge...
        s_suppr = set()
        for f in s_surch:
            fexist = d_f.get(osp.basename(f))
            if fexist:
                s_suppr.add(fexist)
                if self.verbose: print('suppression :', fexist)
        # ... et ceux de l'unigest
        if self.unig:
            iunig = 0
            for f in self.unig['f'] + self.unig['f90']:
                iunig += 1
                s_suppr.add(d_f.get(osp.basename(f), ''))
                if self.verbose: print('suppression :', f)
            if iunig > 0:
                print('%5d source(s) supprime(s).' % iunig)

        s_f.difference_update(s_suppr)
        s_f.update(s_surch)
        l_f = [osp.abspath(f) for f in s_f]
        l_f.sort()
        return l_f


    def _get_list_python(self):
        """Retourne la liste des fichiers python
        """
        s_pyt = set()
        s_pyt.update(glob(osp.join(self.pyt, '*.py')))
        s_pyt.update(glob(osp.join(self.pyt, '*', '*.py')))
        s_pyt.update(glob(osp.join(self.capy, '*.capy')))
        s_pyt.update(glob(osp.join(self.capy, '*', '*.capy')))
        if self.build_obj.support('waf'):
            l_pyt = [osp.abspath(f) for f in s_pyt]
            l_pyt.sort()
            return l_pyt
        d_py = {}
        for f in s_pyt:
            typ = osp.splitext(f)[-1][1:]
            key = self.build_obj.GetCModif(typ, f)
            assert d_py.get(key) is None, 'ERROR : %s  (old : %s)' % (key, d_py[key])
            d_py[key] = f
        # surcharge
        s_surch = set()
        for dsrc in self.surch_pyt:
            s_surch.update(glob(osp.join(dsrc, '*.py')))
            s_surch.update(glob(osp.join(dsrc, '*', '*.py')))
            s_surch.update(glob(osp.join(dsrc, '*.capy')))
            s_surch.update(glob(osp.join(dsrc, '*', '*.capy')))
        if len(s_surch) > 0:
            l_surch = list(s_surch)
            l_surch.sort()
            print('%5d module(s) python en surcharge : ' % len(l_surch))
            print(os.linesep.join(l_surch))
        # retirer des sources originaux ceux de la surcharge...
        s_suppr = set()
        for f in s_surch:
            typ = osp.splitext(f)[-1][1:]
            key = self.build_obj.GetCModif(typ, f)
            fexist = d_py.get(key)
            if fexist:
                s_suppr.add(fexist)
                if self.verbose: print('suppression :', fexist)
        # ... et ceux de l'unigest
        if self.unig:
            iunig = 0
            for typ in ('py', 'capy'):
                for f in self.unig[typ]:
                    iunig += 1
                    fabs = osp.abspath(osp.join(self.repref, f))
                    key = self.build_obj.GetCModif(typ, fabs)
                    s_suppr.add(d_py.get(key, ''))
                    if self.verbose: print('suppression :', fabs)
            if iunig > 0:
                print('%5d module(s) python supprime(s).' % iunig)

        s_pyt.difference_update(s_suppr)
        s_pyt.update(s_surch)
        l_pyt = [osp.abspath(f) for f in s_pyt]
        l_pyt.sort()
        return l_pyt


    def search_message(self, fich):
        """Retourne les messages utilisés dans 'fich'.
        """
        try:
            with open(fich, 'r') as f:
                txt = f.read()
        except IOError as msg:
            print(_('Error with file %s : %s') % (fich, msg))
            return []
        ext = osp.splitext(fich)[-1]
        txt = clean_source(txt, ext, ignore_comments=self.ignore_comments, wrap=True)

        if osp.splitext(fich)[-1] not in ('.py', '.capy'):
            expr = (r'CALL\s+(U2MES.|UTEXC[MP]+|UTPRIN|UTMESS|UTMESS_CORE)\s*'
                    r'\(([^,]*?), *[\'\"]+(.*?)[\'\"]+ *[,\)]+')
        else:
            expr = (r'[\s\.:]+(UTMESS|GetText)\s*\(([^,]*?), *'
                    r'[\'\"]+(.*?)[\'\"]+ *[,\)]+')
        all_msg = re.findall(expr, txt, flags=re.I)
        l_msg = []
        for found in all_msg:
            sub, typ, msg = found
            if msg.startswith('FERMETUR_'):
                pass
            elif re.search('^[A-Z0-9]+_[0-9]+$', msg) is None:
                print("Invalid message id ('%s') in file %s (%s)" % (msg, fich, sub))
            else:
                mattyp = re.search(r'[\'\" ]+(.*?)[\+\'\" ]+', typ)
                # variables and numbers (for exception) are allowed
                if mattyp is not None and \
                   mattyp.group(1) not in ('', 'A', 'I', 'E', 'S', 'F', 'M', 'D'):
                   # may be '' for example STY//'+'
                    print("Invalid message type (%s) for message '%s' in file %s" \
                        % (mattyp.group(1), msg, fich))
                    print("type = %s" % typ)
                else:
                    l_msg.append(msg)
#      l_msg = self.regexp.findall(txt)

        # verif
        l_res = []
        for msg in l_msg:
            spl = msg.split('_')
            assert len(spl) == 2, 'ERROR invalid : %s' % msg
            msg = '%s_%d' % (spl[0], int(spl[1]))
            l_res.append(msg)

        return l_res


    def _build_dict(self):
        """Construit les dictionnaires :
            fichier source : liste des messsages appelés
            message : liste des fichiers appelant ce message
        """
        # est-ce dans le cache ?
        if not self.force and osp.isfile(self.cache_dict) \
                                and os.stat(self.cache_dict).st_size > 0:
            if self.verbose:
                print('Load dicts from cache (%s)...' % self.cache_dict)
            with open(self.cache_dict, 'rb') as pick:
                self.d_msg_used = pickle.load(pick)
                self.d_msg_call = pickle.load(pick)

        else:
            self.d_msg_used = {}
            self.d_msg_call = {}
            l_all = self.l_src + self.l_pyt
            if self.verbose:
                p = Progress(maxi=len(l_all), format='%5.1f %%',
                                msg='Analyse des sources... ')
            for i, f in enumerate(l_all):
                if self.verbose:
                    p.Update(i)
#             key = f.replace(self.repref, '')
                key = re.sub('^%s/*', '', f)
                lm = self.search_message(f)
                if len(lm) > 0:
                    self.d_msg_used[key] = lm
                    for msg in lm:
                        self.d_msg_call[msg] = self.d_msg_call.get(msg, []) + [key,]

            if self.verbose:
                p.End()
                #pprint.pprint(self.d_msg_used)

            with open(self.cache_dict, 'wb') as pick:
                pickle.dump(self.d_msg_used, pick)
                pickle.dump(self.d_msg_call, pick)


    def print_stats(self):
        """Affiche les stats sur les données lues/construites
        """
        if self.verbose:
            print('%6d messages appelés dans les sources' % len(list(self.d_msg_call.keys())))
            print('%6d fichiers sources appellent le catalogue de messages' % len(list(self.d_msg_used.keys())))


    def move(self, oldid, dest, reuse_hole=True):
        """Déplace le message 'oldid' dans le catalogue 'dest'.
        """
        if self.verbose:
            print('--- moving "%s" into "%s"' % (oldid, dest))
        # catalogue objects
        old_f, old_num = self._id2filename(oldid)
        new_f = self._filename_cata(dest.lower())

        # have these catalogues been already changed ?
        fmod = osp.join(self.wrk_pyt, osp.basename(old_f))
        if osp.isfile(fmod):
            print('from %s' % fmod)
            old_f = fmod
        fmod = osp.join(self.wrk_pyt, osp.basename(new_f))
        if osp.isfile(fmod):
            print('from %s' % fmod)
            new_f = fmod

        old_cata = CATA(old_f)
        new_cata = CATA(new_f)
        if self.verbose:
            print(old_cata)
            print(new_cata)
        new_num = new_cata.get_new_id(reuse_hole)
        if new_num < 0:
            raise CataMessageError(new_f, _('no message id available in this catalog'))
        newid = self._filename2id(new_f, new_num)

        # check message existence
        if old_cata[old_num] == None:
            raise MessageError(oldid, _('unknown message'))

        new_cata[new_num] = old_cata[old_num]
        del old_cata[old_num]

        # write modified catalogues
        self.makedirs()
        fout = osp.join(self.wrk_pyt, osp.basename(old_f))
        content = old_cata.get_content()
        with open(fout, 'w') as f:
            f.write(content)
        fout = osp.join(self.wrk_pyt, osp.basename(new_f))
        content = new_cata.get_content()
        with open(fout, 'w') as f:
            f.write(content)
        print('Nouveau fichier : %s' % fout)

        # modify source using 'oldid' message
        l_src = self.d_msg_call.get(oldid, [])
        for f in l_src:
            ext = osp.splitext(f)[-1]
            rdest = self.wrk_fort
            if ext == '.py':
                rdest = self.wrk_pyt
            # already changed ?
            fmod = osp.join(rdest, osp.basename(f))
            if osp.isfile(fmod):
                print('from %s' % fmod)
                f = fmod
            with open(osp.join(self.repref, f), 'r') as f:
                txt = f.read()
            new = re.sub('%s([\'\"]+)' % oldid, newid + r'\1', txt)
            fout = osp.join(rdest, osp.basename(f))
            with open(fout, 'w') as f:
                f.write(new)
            print('Nouveau fichier : %s' % fout)


    def who_use(self, msg):
        """Qui utilise le message 'msg' ?
        """
        return tuple(self.d_msg_call.get(msg.upper(), []))


    def get_key(self, sub):
        """Retourne la clé dans d_msg_used correspondant à 'sub'.
        Seule la première est retournée si jamais il y en avait plusieurs.
        """
        l_allsub = list(self.d_msg_used.keys())
        l_sub = [f for f in l_allsub if f.split(os.sep)[-1] == sub]
        if len(l_sub) > 1:
            print('Plusieurs routines correspondent : %s' % ', '.join(l_sub))
            print('On utilise la première valeur.')
        if len(l_sub) == 0:
            result = None
        else:
            result = l_sub[0]
        return result


    def which_msg(self, sub):
        """Quels sont les messages utilisés par la routine 'sub' ?
        """
        key = self.get_key(sub)
        return tuple(self.d_msg_used.get(key, []))


template_cata_header = """# -*- coding: utf-8 -*-
# ======================================================================
# COPYRIGHT (C) 1991 - %s  EDF R&D                  WWW.CODE-ASTER.ORG
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
# ======================================================================

def _(x) : return x

cata_msg = {""" % time.strftime('%Y')

template_cata_footer = """
}
"""

template_cata_msg = '''
%(msgid)s : _(u"""%(text)s"""),'''


class CATA:
    """Classe représentant un catalogue de messages.
    Méthodes attendues :
        - nombre de messages,
        - indice du dernier messages,
        - indice libre,
        - ajouter/supprimer un message,
        - ...
    """
    def __init__(self, fcata):
        """Initialisation
        """
        self.fcata = fcata
        self.cata_msg = {}
        try:
            d = { '_' : lambda x: x, }
            with open(fcata) as f:
                exec(compile(f.read(), fcata, 'exec'), d)
            self.cata_msg = d['cata_msg']
        except Exception as msg:
            print('-'*80+'\n', msg, '\n'+'-'*80)
            raise CataMessageError(self.fcata, _('unable to import the file'))


    def get_nb_msg(self):
        """Nombre de messages.
        """
        return len(self.cata_msg)


    def get_last_id(self):
        """Indice du dernier message.
        """
        return max(list(self.cata_msg.keys()) or [0,])


    def get_new_id(self, reuse_hole=True):
        """Indice libre. Si 'end', on prend systématiquement à la fin,
        sinon on cherche aussi dans les trous.
        """
        if not reuse_hole:
            start = self.get_last_id()
        else:
            start = 1
        all = set(range(start, 100))
        free = all.difference(list(self.cata_msg.keys()))
        if len(free) == 0:
            new = -1
        else:
            new = min(free)
        return new


    def __getitem__(self, key):
        """Retourne le contenu du message ou None.
        """
        return self.cata_msg.get(key, None)


    def __setitem__(self, key, msg):
        """Ajoute le message 'msg' à l'indice 'key'.
        """
        if self[key] != None:
            raise MessageError(key, _('message already exists !'))
        self.cata_msg[key] = msg


    def __delitem__(self, key):
        """Supprime le message d'indice 'key'.
        """
        if self[key] == None:
            raise MessageError(key, _('this message does not exist !'))
        del self.cata_msg[key]


    def __repr__(self):
        """Résumé du catalogue.
        """
        return ufmt(_('%3d messages (last=%3d, next=%3d) in %s'),
                self.get_nb_msg(), self.get_last_id(), self.get_new_id(), self.fcata)


    def __iter__(self):
        """Itération sur les id des messages.
        """
        return iter(self.cata_msg)


    def check(self):
        """Vérifie le texte des messages."""
        def_args = {}
        for i in range(1,100):
            def_args['i%d' % i] = 99999999
            def_args['r%d' % i] = 1.234e16   # not too big to avoid python issue1742669
            def_args['k%d' % i] = 'xxxxxx'
        def_args['ktout'] = "all strings !"
        error = []
        for num, msg in list(self.cata_msg.items()):
            if type(msg) is dict:
                msg = msg['message']
            try:
                txt = msg % def_args
            except:
                error.append(ufmt(_('message #%s invalid : %s'), num, msg))
        if len(error) > 0:
            raise CataMessageError(self.fcata, os.linesep.join(error))


    def get_cmodif(self):
        """Retourne la carte MODIF.
        """
        cmodif = None
        fobj = open(self.fcata, 'r')
        for line in fobj:
            if re.search('#@ +MODIF|#@ +AJOUT', line):
                cmodif = line.replace(os.linesep, '')
                break
        fobj.close()
        if cmodif == None:
            raise CataMessageError(self.fcata, _('invalid header "#@ MODIF/AJOUT..."'))
        return cmodif


    def get_content(self):
        """Contenu du catalogue "reconstruit".
        """
        txt = [self.get_cmodif(),]
        txt.append(template_cata_header)
        l_ind = list(self.cata_msg.keys())
        l_ind.sort()
        for msgid in l_ind:
            txt.append(template_cata_msg % {'msgid' : msgid, 'text' : self.cata_msg[msgid]})
        txt.append(template_cata_footer)
        return os.linesep.join(txt)


def clean_source(content, ext, ignore_comments, wrap):
    """Nettoie un fichier source.
    """
    if ignore_comments:
        assert ext in ('.f', '.F', '.F90', '.py', '.capy'), 'unknown type : %s' % str(ext)
        if ext in ('.f', '.F'):
            reg_ign = re.compile('(^[A-Z!#].*$)', re.MULTILINE)
        elif ext in ('.F90'):
            reg_ign = re.compile('(^[!#].*$)', re.MULTILINE)
        elif ext in ('.py', '.capy'):
            reg_ign = re.compile('(#.*$)', re.MULTILINE)
        content = reg_ign.sub('', content).expandtabs()
        if wrap and ext in ('.f', '.F'):
            content = ''.join([lin[6:] for lin in content.splitlines()])
    return content


def GetMessageInfo(run, *args):
    """Return info about Code_Aster messages.
    """
    if not run.get('aster_vers'):
        run.parser.error(_("You must define 'default_vers' in 'aster' configuration file or use '--vers' option."))
    REPREF = run.get_version_path(run['aster_vers'])
    fconf = run.get('config')
    if fconf:
        fconf = osp.abspath(fconf)
    conf = build_config_of_version(run, run['aster_vers'], fconf)

    if run['nolocal']:
        run.Mess(_('This operation only works on local source files. "--nolocal" option ignored'))

    bibfor = [conf['SRCFOR'][0],]
    if conf['SRCF90'][0] != '':
        bibfor.append(conf['SRCF90'][0])

    args = list(args)
    named_actions = ('check', 'move',)
    action = None

    if len(args) > 0 and args[0] in named_actions:
        action = args.pop(0)
    elif len(args) == 0:
        run.Mess(_('You must choose an operation from %s or give a subroutine name or a message ID') \
                % repr(named_actions), '<F>_INVALID_ARGUMENT')

    # surcharge
    surch_fort = run.get('surch_fort', [])
    if surch_fort:
        surch_fort = surch_fort.split(',')
    surch_pyt = run.get('surch_pyt', [])
    if surch_pyt:
        surch_pyt = surch_pyt.split(',')

    pick_cache = 'messages_dicts.%s.pick' % (run['aster_vers'].replace(os.sep, '_'))
    msgman = MESSAGE_MANAGER(repref=REPREF,
                             fort=bibfor,
                             pyt=conf['SRCPY'][0],
                             capy=conf['SRCCAPY'][0],
                             cache_dict=osp.join(run['cache_dir'], pick_cache),
                             force=run['force'], verbose=run['verbose'],
                             debug=run['debug'],
                             surch_fort=surch_fort,
                             surch_pyt =surch_pyt,
                             unig      =run.get('unigest', None),
                             )
    msgman.read_cata()

    if action == 'check':
        try:
            unused, not_found = msgman.check_cata()
        except CataMessageError as msg:
            run.Sortie(4)
        if not run['silent']:
            print('Messages inutilises :')
            print(' '.join(unused))
            print('Messages inexistants :')
            print(' '.join(not_found))
        if len(unused) + len(not_found) > 0:
            run.Sortie(4)

    elif action == 'move':
        if len(args) != 2:
            run.parser.error(
                    _("'--%s %s' requires 2 arguments") % (run.current_action, action))
        msgman.move(*args)

    else:
        print()
        fmt = '%12s : %s'
        for obj in args:
            l_msg = list(set(msgman.which_msg(obj)))
            if len(l_msg) > 0:
                l_msg.sort()
                print(fmt % (obj, l_msg))
            l_sub = list(set(msgman.who_use(obj)))
            if len(l_sub) > 0:
                l_sub.sort()
                print(fmt % (obj, l_sub))
