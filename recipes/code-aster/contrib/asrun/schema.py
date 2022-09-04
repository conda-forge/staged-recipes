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
Definition of ITEM class representing a MySQL item.
"""


import os
import time
import datetime
import re
from hashlib import sha1

from asrun.myconnect    import MySQLError
from asrun.common.i18n import _
from asrun.mystring     import convert, to_unicode


__verbose__ = False
__all__ = ['ITEM', 'ReadDB', 'USER', 'INTERVENANT', 'MSG', 'PRODUIT', 'VERSION',
           'PROJET', 'STATUS', 'TYPE', 'ISSUE',
           'PRODUIT_VERSION', 'ISSUE_MESSAGES', 'ISSUE_NOSY', 'YES', 'NO',
           'ReadDBError', 'WriteDBError', 'ConnectDBError']

mysql_date_fmt = '%Y-%m-%d %H:%M:%S'
now = time.strftime(mysql_date_fmt, time.gmtime())

# boolean values
YES = 1
NO  = 0


def transpose(liste):
    """Convert a such list ((x1, x2, ..., xn), (y1, y2, ..., yn), ...)
                      into ((x1, y1, ...), (x2, y2, ...), ..., (xn, yn, ...))
    """
    n = list(range(len(liste[0])))
    m = list(range(len(liste)))
    liste_t = [[] for i in n]
    for i in n :
        for j in m :
            liste_t[i].append(liste[j][i])
    return liste_t

fmt_val = '%-20s = %s'
fmt_vr  = '%-20s = %s (@)'
fmt_id  = "<--- item référencé dans '%s' avec id = %s"
fmt_fin = "     --->"
fmt_i   = '%8d'
fmt_date = '%d/%m/%Y'
# regexp associée à mysql_date_fmt
re_date  = '([0-9]{4}\-[0-9]{2}\-[0-9]{2}) [0-9]{2}:[0-9]{2}:[0-9]{2}'


class ConnectDBError(Exception):
    """Error with MySQL database connection.
    """

class ReadDBError(Exception):
    """Error when reading items from database.
    """

class WriteDBError(Exception):
    """Error when writing items to database.
    """



class ITEM:
    """Enregistrement d'une table avec éventuellement des références à
    des enregistrements d'autres tables.
    (Je pense que hyperdb de Roundup pourrait être utilisée, mais je n'ai pas
    trouvé comment...!).
    Attributs :
        table    : nom de la table associée à ce type d'enregistrement
        c        : connexion MySQL
        refs     : dictionnaire indiquant la sous-classe des ITEMs référencés
        idkey    : vaut 'id' sauf pour les tables multi-link où il vaut 'linkid'
        primkeys : liste des clés "primaires" (permettant de retrouver un item)
        values   : dictionnaire des champs
        default  : contenu d'item par défaut
        inDB     : True si on a vérifié que l'enregistrement est dans la base
        lu       : True si on a déjà lu l'enregistrement dans la base
        cols     : (cache) ordre des colonnes dans la table (pour SELECT * par ex)

        link_class : table où sont stockés les "multi-link"
        parent_class : la classe "parent"

    A priori, tant que lu=False, on n'est pas assuré que les champs qui font
    référence à un autre enregistrement contienne l'ITEM référencé, ils peuvent
    contenir que l'id.
    """
    table = None
    link_class = None
    parent_class = None
    default = {}
    refs = {}
    primkeys = ['id']
    idkey = 'id'
    db_encoding  = 'utf-8'
    # this is used for Roundup schema where max ids are store in 'ids' table.
    tab_idmax = 'ids'

    def __init__(self, dini=None, c=None):
        """Initialisation avec dini qui est :
            - soit le dictionnaire des valeurs des champs de l'enregistrement,
            - soit la valeur du champ "primaire".
        Sont équivalents (en supposant que 'id' est la clé primaire):
            ITEM({'id' : num}, c) et ITEM(num, c)
        """
        toread = False
        if dini == None:
            dini = {}
        elif not type(dini) is dict:
            dini = { self.idkey : dini }
            toread = True
        self.c      = c
        self.values = self.default.copy()
        self.values.update(dini)
        self.inDB   = False
        self.lu     = False
        self.cols   = None
        if toread:
            self.read()

    def __setitem__(self, key, value):
        """Positionne un champ de l'enregistrement
        """
        self.values[key] = value

    def __getitem__(self, key):
        """Retourne la valeur d'un champ de l'enregistrement
        """
        return self.values[key]

    def __setid(self, value):
        """Positionne le champ idkey de l'objet
        """
        if not self.idkey in self.refs:
            self.values[self.idkey] = value
        elif __verbose__:
            print('Warning <setid>: %s is an ITEM object.' % repr(self.idkey))

    def __getid(self):
        """Retourne la valeur du champ idkey de l'objet
        """
        value = self.values[self.idkey]
        if not self.idkey in self.refs or not isinstance(value, ITEM):
            return value
        else:
            if __verbose__:
                print('Warning <getid>: %s is an ITEM object.' % repr(self.idkey))
            return value.get(value.idkey)

    def get(self, key, default=None):
        """Retourne la valeur d'un champ de l'enregistrement ou default
        """
        return self.values.get(key, default)

    def getrepr(self, refs=True):
        """Affichage. Si 'refs'=False, on n'imprime pas les sous-items.
        """
        txt = []
        for k, v in list(self.values.items()):
            if k in list(self.refs.keys()):
                item = None
                if isinstance(self[k], ITEM):
                    item = v
                    idref = v.get(v.idkey)
                else:
                    item = eval('%s(%s)' % (self.refs[k], 'c=self.c'))
                    try:
                        item.read({item.idkey:v})
                        idref = v
                    except (ConnectDBError, ReadDBError) as msg:
                        item = None
                        if __verbose__:
                            print(msg)
                if item != None and (item.__class__.__name__ != self.__class__.__name__\
                               or idref != self.get(self.idkey)):
                    if not refs:
                        txt.append(fmt_vr % (k, idref))
                    else:
                        txt.append(fmt_id % (k, idref))
                        txt.append(os.linesep.join(['      > %s' \
                                % l for l in repr(item).split(os.linesep)]))
                        txt.append(fmt_fin)
                else:
                    txt.append(fmt_vr % (k, v))
            else:
                if type(v) == str:
                    v = to_unicode(v)
                txt.append(fmt_val % (k, v))
        return convert(os.linesep.join(txt))

    def __repr__(self):
        """Affichage
        """
        return self.getrepr()

    def repr(self, refs=False):
        """Affichage
        """
        print(self.getrepr(refs))

    def prim_crit(self):
        """Critères suffisants pour retrouver l'id d'un enregistrement,
        construit à partir des primkeys.
        """
        d = {}
        for k in self.primkeys:
            if isinstance(self[k], ITEM):
                d[k] = self[k].get(self[k].idkey)
            else:
                d[k] = self[k]
        return d

    def GetPrimValue(self):
        """Return the value of `primkeys` field.
        Return None if there was more than one primary keys.
        """
        if len(self.primkeys) != 1:
            value = None
        else:
            value = self.get(self.primkeys[0], None)
        return value

    def isinDB(self, dcrit=None):
        """Retourne True si l'enregistrement est présent dans la base.
        """
        if not self.inDB:
            try:
                idv = self.__getid_from_db(dcrit)
                self.inDB = True
            except ReadDBError:
                pass
        return self.inDB

    def read(self, dcrit=None, force=False):
        """Lit l'enregistrement dans la base à partir de prim_crit() ou du
        critère fourni sous forme de dict, il faut donc au moins initialiser les
        champs qui servent au critère (sinon KeyError).
        Si force=True, on ne tient pas compte de l'attrbut lu.
        """
        if self.c == None:
            raise ConnectDBError(_('no database connection'))
        elif force or not self.lu:
            self.__cachecols()
            if dcrit == None:
                dcrit = self.prim_crit()
            criteres = ' AND '.join([
                "%s='%s'" % (k, v) for k, v in list(dcrit.items()) ])
            query = """SELECT * FROM %s WHERE %s;""" % (self.table, criteres)
            res = self.c.exe(query)
            if len(res) != 1:
                raise ReadDBError(_('only one result expected for "%s"') % query)
            else:
                self.lu = True
                self.inDB = True
                lkv = transpose([self.cols, res[0]])
                # effacer le contenu si force=True
                if force:
                    self.values = self.default.copy()
                # il faut lire l'id des références avant de les traiter
                for k, v in lkv:
                    if isinstance(v, datetime.datetime) or isinstance(v, datetime.date) \
                            or type(v).__name__ == 'DateTime':
                        v = v.strftime(mysql_date_fmt)
                    self[k] = v
                self.__decode_string_fromDB()
                # traitement des références
                for k, v in [[k, v] for k, v in lkv if k in list(self.refs.keys())]:
                    if self.refs[k] == self.__class__.__name__ and self.__getid() == v:
                        #print "Warning: %s avec id=%s s'auto-référence." \
                        #   % (self.refs[k], v)
                        pass
                    # s'il n'y a pas de référence
                    elif v != None:
                        self[k] = eval('%s(%s)' % (self.refs[k], 'c=self.c'))
                        self[k].read({self[k].idkey:v})

    def write(self, force=False, force_recursive=False):
        """Ecrit l'enregistrement dans la base.
        """
        if force_recursive:
            force = True
        if self.c == None:
            raise ConnectDBError(_('no database connection'))
        elif self.isinDB() and not force:
            criteres = ' AND '.join([
                "%s='%s'" % (k, v) for k, v in list(self.prim_crit().items()) ])
            if __verbose__:
                print("Warning: %s with id=%s is already in database %s (%s)." \
                    % (self.__class__.__name__, self.__getid(), self.table, criteres))
        else:
            self.__cachecols()
            new = False
            if not self.isinDB():
                new = True
                if self.get(self.idkey) == None:
                    self.__setid(self.__getmaxid()+1)
            dins = self.__encode_string_toDB()
            # écrire les items référencés et les remplacer par leur id
            for k in list(self.refs.keys()):
                if isinstance(self[k], ITEM):
                    self[k].write(force_recursive=force_recursive)
                    idref = self[k].__getid()
                else:
                    if self[k] != None:
                        item = eval('%s(%s)' % (self.refs[k], 'c=self.c'))
                        item.read({item.idkey:self[k]})
                    idref = self[k]
                dins[k] = idref
            # dater la modification (activity)
            if '_activity' in dins:
                dins['_activity'] = now
            try:
                if new:
                    nb = self.c.insert(self.table, dins)
                    self.__setmaxid(self.__getid())
                else:
                    nb = self.c.update(self.table, dins, {self.idkey:self.__getid()})
            except MySQLError:
                raise WriteDBError(_('error occurs during writing in database'))
            # positionne l'id
            idv = self.__getid_from_db()
            criteres = ' AND '.join([
                "%s='%s'" % (k, v) for k, v in list(self.prim_crit().items()) ])
            if __verbose__:
                print("%s with id=%s written in database %s (%s)." \
                    % (self.__class__.__name__, self.__getid(), self.table, criteres))
            # c'est comme si on l'avait lu
            self.lu = True

    def __encode_string_toDB(self):
        """Convert all strings to DB encoding.
        """
        return self.__convert_string(self.db_encoding, True)

    def __decode_string_fromDB(self):
        """Convert all strings from DB encoding (to default encoding).
        """
        self.__convert_string(None, False)

    def __convert_string(self, out_encoding, copy):
        """Convert all strings to `out_encoding`.
        If 'copy' is True a copy of `.values` is returned,
        if 'copy' is False `.values` is modified in place.
        """
        if copy:
            dico = self.values.copy()
        else:
            dico = self.values
        dico = self.values
        for k, v in list(dico.items()):
            if type(v) in (str, str):
                dico[k] = convert(v, out_encoding)
        if copy:
            return dico

    def __getid_from_db(self, dcrit=None):
        """Retourne l'id de l'enregistrement répondant aux critères fournis
        et positionne le champ id.
        """
        if self.c == None:
            raise ConnectDBError(_('no database connection'))
        else:
            if dcrit == None:
                dcrit = self.prim_crit()
            criteres = ' AND '.join(["%s='%s'" % (k, v) for k, v in list(dcrit.items())])
            query = """SELECT %s FROM %s WHERE %s;""" \
                    % (self.idkey, self.table, criteres)
            res = self.c.exe(query)
            if len(res) == 0:
                raise ReadDBError(_('no item found for %s') % criteres)
            elif len(res)>1:
                lid = [l[0] for l in res]
                raise ReadDBError(_('more than one item for %s : %s') \
                    % (criteres, repr(lid)))
            else:
                self.__setid(res[0][0])
                return self.__getid()

    def __getmaxid(self):
        """Retourne l'id max de la table.
        """
        if self.c == None:
            raise ConnectDBError(_('no database connection'))
        else:
            query = """SELECT max(%s) FROM %s;""" % (self.idkey, self.table)
            res = self.c.exe(query)
            maxi = res[0][0]
            if maxi == None:
                maxi = 0
            try:
                maxi = int(maxi)
            except ValueError:
                raise ReadDBError(_("field '%s' should be numeric") % repr(self.idkey))
            return maxi

    def __setmaxid(self, maxi):
        """Set the max id + 1 in the 'ids' table (for Roundup-style databases).
        """
        if not hasattr(self, 'tab_idmax'):
            return
        if self.c == None:
            raise ConnectDBError(_('no database connection'))
        else:
            try:
                self.c.update(self.tab_idmax, {'num' : maxi + 1},
                                                        {'name' : re.sub('^[_]+', '', self.table)})
            except MySQLError:
                raise WriteDBError(_('error occurs during writing in database'))

    def __cachecols(self):
        """Remplit .cols, devrait être appelé par toute méthode l'utilisant.
        """
        # Si pas déjà rempli
        if self.cols == None:
            if self.c == None:
                raise ConnectDBError(_('no database connection'))
            else:
                self.cols = self.c.showcol(self.table)

    def GetLinks(self):
        """Return a list of the items linked to this item (list of versions
        for a product, list of messages for an issue).
        """
        l_items = []
        # ITEM with multi-link
        if self.link_class == None or self.c == None:
            return l_items
        link_table = eval("%s.table" % self.link_class)
        linked_classname = eval("%s.refs['linkid']" % self.link_class)
        linked_class = eval(linked_classname)
        idkey = linked_class.idkey
        query = """SELECT linkid FROM %s WHERE nodeid=%s;""" \
              % (link_table, self.get(self.idkey))
        try:
            res = self.c.exe(query)
        except MySQLError:
            return l_items
        res = [i[0] for i in res]
        if len(res) > 0:
            crit = ' OR '.join(["%s=%s" % (idkey, i) for i in res])
            l_items = ReadDB(linked_class, c=self.c, crit=crit)
        return l_items

    def GetParent(self):
        """Return the parent of this item (a product for a version, an issue for
        a message).
        """
        parent = None
        if self.parent_class == None:
            return parent
        pclass = eval(self.parent_class)
        parent_table = pclass.table
        link_table = eval("%s.table" % pclass.link_class)
        query = """SELECT nodeid FROM %s WHERE linkid=%s;""" \
              % (link_table, self.get(self.idkey))
        try:
            numf = self.c.exe(query)[0][0]
        except (MySQLError, IndexError):
            return parent
        parent = pclass({pclass.idkey : numf}, self.c)
        parent.read()
        return parent

    def AsDict(self):
        """Retourne un dictionnaire avec toutes les valeurs, valeurs du champ
        "primaire" pour les sous-items.
        """
        def repr_val(val):
            v = val
            if type(val) in (str, str):
                mat = re.search(re_date, val)
                if mat != None:
                    v = mat.group(1)
            return v

        dico = {}
        for k, v in list(self.values.items()):
            if k.startswith('__'):
                continue
            if k in list(self.refs.keys()):
                item = None
                if isinstance(self[k], ITEM):
                    item = v
                    idref = v.get(v.idkey)
                else:
                    item = eval('%s(%s)' % (self.refs[k], 'c=self.c'))
                    try:
                        item.read({item.idkey:v})
                        idref = v
                    except (ConnectDBError, ReadDBError) as msg:
                        item = None
                        if __verbose__:
                            print(msg)
                if item != None and (item.__class__.__name__ != self.__class__.__name__\
                               or idref != self.get(self.idkey)):
                    dico[k] = repr_val(item.GetPrimValue())
            elif not v is None:
                dico[k] = repr_val(v)
        return dico



def ReadDB(subclass, c, crit=None, verbose=False):
    """Fonction pour lire tous les items de la table associée à subclass.
    """
    if len(subclass.primkeys)<1:
        raise AttributeError(_("no primary keys defined for '%s'") % subclass.__name__)
    if crit == None:
        crit = '1'
    query = """SELECT %s FROM %s WHERE %s;""" % \
        (','.join(subclass.primkeys), subclass.table, crit)
    res = c.exe(query)
    ditem = {}
    for lig in res:
        dini = {}
        lkv = transpose([subclass.primkeys, lig])
        for k, v in lkv:
            dini[k] = v
        item = subclass(dini, c=c)
        item.read()
        ditem[lig[0]] = item
    if verbose:
        print('%6d items read from %s' % (len(list(ditem.keys())), subclass.table))
    return ditem



class USER(ITEM):
    """Enregistrement de la table _user
    """
    table = '_user'
    default = {
        '_activity'       : now,
        '_actor'          : 1,
        '_address'        : None,
        '_creation'       : now,
        '_creator'        : 1,              # id de admin
        '_loginaster'     : None,
        '_organisation'   : None,
        '_password'       : ('{SHA}' +
                             sha1('mot de passe par defaut'.encode())
                                .hexdigest()),
        '_phone'          : None,
        '_realname'       : None,
        '_roles'          : None,
        '_timezone'       : None,
        '_username'       : None,
        '__retired__'     : 0,
    }
    refs = {}  # pas d'intérêt de mettre _creator car toujours admin, id=1
    primkeys = ['_username', ]

class INTERVENANT(ITEM):
    """Enregistrement de la table _intervenant
    """
    table = '_intervenant'
    default = {
        '_activity'       : now,
        '_actor'          : 1,
        '_creation'       : now,
        '_creator'        : 1,              # id de admin
        '_name'           : None,
        '_order'          : None,
        '__retired__'     : 0,
    }
    refs = {}
    primkeys = ['_name', ]

class MSG(ITEM):
    """Enregistrement de la table _msg
    """
    table = '_msg'
    parent_class = 'ISSUE'
    default = {
        'id'              : None,
        '_activity'       : now,
        '_actor'          : 1,
        '_author'         : None,
        '_creation'       : now,
        '_creator'        : None,
        '_date'           : now,
        '_inreplyto'      : None,
        '_messageid'      : None,
        '_summary'        : None,  # 255 premiers caractères du message
        '__retired__'     : 0,
    }
    refs = {'_author':'USER', '_creator':'USER', }
    primkeys = ['id', ]

class PRODUIT(ITEM):
    """Enregistrement de la table _produit
    """
    table = '_produit'
    link_class = 'PRODUIT_VERSION'
    default = {
        '_activity'       : now,
        '_actor'          : 1,
        '_creation'       : now,
        '_creator'        : 1,
        '_name'           : None,
        '_order'          : None,
        '__retired__'     : 0,
    }
    refs = {}
    primkeys = ['_name', ]

class VERSION(ITEM):
    """Enregistrement de la table _version
    """
    table = '_version'
    parent_class = 'PRODUIT'
    default = {
        '_activity'       : now,
        '_actor'          : 1,
        '_creation'       : now,
        '_creator'        : 1,
        '_name'           : None,
        '_order'          : None,
        '__retired__'     : 0,
    }
    refs = {}
    primkeys = ['_name', ]

class PRODUIT_VERSION(ITEM):
    """Enregistrement de la table produit_version
    """
    table = 'produit_version'
    default = {
        'linkid'          : None,
        'nodeid'          : None,
    }
    refs = {'linkid':'VERSION', 'nodeid':'PRODUIT'}
    primkeys = ['linkid', ]
    idkey = 'linkid'

class PROJET(ITEM):
    """Enregistrement de la table _projet
    """
    table = '_projet'
    default = {
        '_activity'       : now,
        '_actor'          : 1,
        '_creation'       : now,
        '_creator'        : 1,
        '_name'           : None,
        '_order'          : None,
        '__retired__'     : 0,
    }
    refs = {}
    primkeys = ['_name', ]

class STATUS(ITEM):
    """Enregistrement de la table _status
    """
    table = '_status'
    default = {
        '_activity'       : now,
        '_actor'          : 1,
        '_creation'       : now,
        '_creator'        : 1,
        '_modifier'       : 1,
        '_name'           : None,
        '_order'          : None,
        '_transition'     : None,
        '__retired__'     : 0,
    }
    refs = {}
    primkeys = ['_name', ]

class TYPE(ITEM):
    """Enregistrement de la table _type
    """
    table = '_type'
    default = {
        '_activity'       : now,
        '_actor'          : 1,
        '_creation'       : now,
        '_creator'        : 1,
        '_name'           : None,
        '_order'          : None,
        '__retired__'     : 0,
    }
    refs = {}
    primkeys = ['_name', ]

class ISSUE(ITEM):
    """Enregistrement de la table _issue
    """
    table = '_issue'
    link_class = 'ISSUE_MESSAGES'
    default = {
        'id'              : None,
        '_activity'       : now,
        '_actor'          : 1,
        '_assignedto'     : None,
        '_chiffrageCharge': None,
        '_chiffrageDelai' : None,
        '_corrVdev'       : None,
        '_corrVexpl'      : None,
        '_creation'       : now,
        '_creator'        : None,
        '_etatIntervenant': None,
        '_fauxVdev'       : None,
        '_fauxVexpl'      : None,
        '_fichetude'      : None,
        '_impactDoc'      : None,
        '_intervenant'    : None,
        '_nbJours'        : None,
        '_produit'        : None,
        '_projet'         : None,
        '_realiseCharge'  : None,
        '_realiseDelai'   : None,
        '_status'         : None,
        '_title'          : None,
        '_type'           : None,
        '_validReal'      : None,
        '_validation'     : None,
        '_verCorrVdev'    : None,
        '_verCorrVexpl'   : None,
        '_versCible'      : None,
        '_version'        : None,
        '__retired__'     : 0,
    }
    refs = {'_assignedto':'USER', '_creator':'USER',  '_intervenant':'INTERVENANT',
            '_produit':'PRODUIT', '_projet':'PROJET',
            '_status':'STATUS',   '_type':'TYPE',     '_version':'VERSION',
            '_versCible':'VERSION'}
    primkeys = ['id', ]

class ISSUE_MESSAGES(ITEM):
    """Enregistrement de la table issue_messages
    """
    table = 'issue_messages'
    default = {
        'linkid'          : None,
        'nodeid'          : None,
    }
    refs = {'linkid':'MSG', 'nodeid':'ISSUE'}
    primkeys = ['linkid', ]
    idkey = 'linkid'

class ISSUE_NOSY(ITEM):
    """Enregistrement de la table issue_nosy
    """
    table = 'issue_nosy'
    default = {
        'linkid'          : None,
        'nodeid'          : None,
    }
    refs = {'linkid':'USER', 'nodeid':'ISSUE'}
    primkeys = []
    idkey = 'linkid'

    def write(self, force=False, force_recursive=False):
        """Ecrit l'enregistrement dans la base.
        force, force_recursive sans effet car pas de clé primaire.
        """
        if self.c == None:
            raise ConnectDBError(_('no database connection'))
        try:
            self.c.insert(self.table, self.values)
        except MySQLError:
            raise WriteDBError(_('error occurs during writing in database'))
