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
Define classes representing an histor file from issues objects.
"""


import os
import re
import datetime
from xml.sax import saxutils
from types import StringType, FloatType, IntType, LongType, ListType, TupleType

from asrun.common.i18n import _
from asrun.mystring import indent, convert
from asrun.common.utils import now


NumberTypes = (FloatType, IntType, LongType)
EnumTypes = (ListType, TupleType)

french_date_fmt = '%d/%m/%Y'


class HistorError(Exception):
    """Exception for this module
    """


def date_inverse(date, sep='/'):
    """Reverse the representation of a date : dd/mm/YY <---> YY/mm/dd.
    """
    if isinstance(date, datetime.datetime) or type(date).__name__ == 'DateTime':
        return date.strftime(french_date_fmt)
    else:
        # suppose `date` is in mysql format
        l_d = str(date).split(sep)
        l_d.reverse()
        return sep.join(l_d)



class HISTOR:
    """Class representing a "standard" histor i.e. as a text file.
    """
    CR = os.linesep
    format = 'text'
    header = ''
    footer = ''
    separ = '-'*80+CR
    seprep = CR*2
    mask = CR + separ + """RESTITUTION FICHE %(id)06d DU %(date_emission)s
AUTEUR : %(person_in_charge)s
TYPE %(type_name)s concernant %(produit_name)s (VERSION %(version_name)s)
%(tma)sTITRE
    %(_title)s
FONCTIONNALITE
%(reponse)s
RESU_FAUX_VERSION_EXPLOITATION    :  %(_fauxVexpl)s
RESU_FAUX_VERSION_DEVELOPPEMENT   :  %(_fauxVdev)s
RESTITUTION_VERSION_EXPLOITATION  :  %(_corrVexpl)s
RESTITUTION_VERSION_DEVELOPPEMENT :  %(_corrVdev)s
IMPACT_DOCUMENTAIRE : %(_impactDoc)s
VALIDATION
    %(_validation)s
%(fix_in)s%(nbjours)s"""
    mask_nbjours = "NB_JOURS_TRAV  : %s" + CR
    mask_tma = 'TMA : %s' + CR
    mask_restit = "DEJA RESTITUE DANS : %s" + CR
    mask_user_begin = separ + \
    '--- AUTEUR %(_realname)-20s' + CR*2
    mask_user_end = separ + CR


    def __init__(self, **kargs):
        """Initialize histor object.
        """
        self.l_bloc = []


    def clean_dict(self, dico):
        """Keep only elements of dict of type string and number,
        and escape all HTML characters.
        """
        newd = {}
        for k, v in list(dico.items()):
            if k == 'CR' or type(v) is StringType or type(v) in NumberTypes:
                newd[k] = v
            elif v is None:
                newd[k] = ''
        return newd


    def DictIssue(self, issue, l_rep=None):
        """Represent an issue as a dict object.
        l_rep : list of the content of messages to include.
        """
        # 0. store issue infos
        dico = issue.values.copy()
        # _version is not always defined
        try:
            dico['version_name'] = issue['_version'].GetPrimValue()
        except AttributeError:
            dico['version_name'] = ''
        dico.update({
            'CR'            : self.CR,
            'type_name'     : issue['_type'].GetPrimValue(),
            'produit_name'  : issue['_produit'].GetPrimValue(),
            'reponse'       : '',
            'tma'           : '',
            'nbjours'       : '',
            'fix_in'        : '',
            'date_emission' : date_inverse(issue['_creation']),
            'person_in_charge' : '',
        })
        if issue['_assignedto']:
            dico['person_in_charge'] = issue['_assignedto']['_realname']

        # 1a. list of messages or last message
        if l_rep != None and len(l_rep) > 0:
            if not type(l_rep) in EnumTypes:
                l_rep = [l_rep]
            l_rep = [indent(convert(s), '   ') for s in l_rep]
            dico['reponse'] = self.seprep.join(l_rep)
        else:
            d_msg = issue.GetLinks()
            imsg = max(d_msg.keys())
            dico['reponse'] = d_msg[imsg]['_summary'] + '...'

        # 1b. text fields
        for k in ('_title', '_validation'):
            dico[k] = convert(dico[k])

        # 2. champs OUI/NON
        for key in ('_corrVdev', '_corrVexpl'):
            if dico[key] != None:
                dico[key] = 'OUI'
            else:
                dico[key] = 'NON'
        for key in ('_fauxVdev', '_fauxVexpl'):
            if dico[key] != None:
                dico[key] = 'OUI   DEPUIS : %s' % dico[key]
            else:
                dico[key] = 'NON'

        # 3. "pour le compte de" field
        if issue['_intervenant'] != None:
            dico['tma'] = self.mask_tma % issue['_intervenant'].GetPrimValue()

        # 4. show '_nbJours' field if no intervenant
        if issue['_intervenant'] == None:
            dico['nbjours'] = self.mask_nbjours % issue['_nbJours']

        # 5. fixed in...
        val = ""
        if issue['_verCorrVexpl'] != None:
            val += issue['_verCorrVexpl']
        if issue['_verCorrVdev'] != None:
            if val:
                val += ", "
            val += issue['_verCorrVdev']
        if val:
            dico['fix_in'] = self.mask_restit % val

        # 6. keep only strings
        dico = self.clean_dict(dico)

        return dico


    def AddIssue(self, issue, l_rep=None):
        """Add a bloc for an issue.
        """
        self.l_bloc.append(self.mask % self.DictIssue(issue, l_rep))


    def DictUser(self, user):
        """Represent an user as a dict object.
        """
        # required fields for formatting
        dico = {
            '_loginaster' : _("unknown"),
            '_realname'   : _("unknown"),
        }
        if hasattr(user, 'values'):
            dico = self.clean_dict(user.values.copy())

        dico['CR'] = self.CR
        return dico


    def BeginUser(self, user):
        """Start a bloc to identify the user who answers following issues.
        """
        self.l_bloc.append(self.mask_user_begin % self.DictUser(user))


    def EndUser(self, user):
        """End the bloc.
        """
        self.l_bloc.append(self.mask_user_end % self.DictUser(user))


    def __repr__(self):
        """Modify representation.
        """
        return self._getrepr()


    def _getrepr(self):
        """Representation of the histor object.
        """
        txt = [self.header]
        txt.extend(self.l_bloc)
        txt.append(self.footer)
        return ''.join([convert(s) for s in txt])



class HISTOR_HTML(HISTOR):
    """Class representing a histor in HTML format.
    """
    CR = '<br />'
    format = 'html'
    header = """<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8">
    <title>histor - Code_Aster</title>
</head>
    <style type="text/css">
        body {
            font-family: monospace;
            text-align: justify;
        }
        .fiche {
            font-style: normal;
            line-height: 1.5em ;
        }
        .par {
            margin-left: 50px ;
            line-height: 1.3em ;
        }
        .enteteuser {
            font-weight: bold;
            text-align: center;
        }
    </style>
<body>
"""
    footer = """</body>
</html>
"""
    separ = '<hr />'
    mask = separ + """

<!-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ -->
<div class="fiche">
RESTITUTION FICHE <a href="%(url_issue)s">%(id)06d</a> DU %(date_emission)s%(CR)s
AUTEUR : %(person_in_charge)s
TYPE %(type_name)s concernant %(produit_name)s (VERSION %(version_name)s)%(CR)s
%(tma)s%(CR)sTITRE
<div class="par">
    %(_title)s
</div>
FONCTIONNALITE
<div class="par">
    %(reponse)s
</div>
RESU_FAUX_VERSION_EXPLOITATION&nbsp;&nbsp;&nbsp;&nbsp;:  %(_fauxVexpl)s%(CR)s
RESU_FAUX_VERSION_DEVELOPPEMENT&nbsp;&nbsp;&nbsp;:  %(_fauxVdev)s%(CR)s
RESTITUTION_VERSION_EXPLOITATION&nbsp;&nbsp;:  %(_corrVexpl)s%(CR)s
RESTITUTION_VERSION_DEVELOPPEMENT&nbsp;:  %(_corrVdev)s%(CR)s
IMPACT_DOCUMENTAIRE : %(_impactDoc)s%(CR)s
VALIDATION
<div class="par">
    %(_validation)s
</div>
%(fix_in)s%(CR)s%(nbjours)s%(CR)s</div>
"""
    mask_user_begin = """
<!-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ -->
%(CR)s
<p class="enteteuser">
    AUTEUR %(_loginaster)s %(_realname)s &nbsp;&nbsp;&nbsp;&nbsp;
</p>
"""
    mask_nbjours = "NB_JOURS_TRAV  : %s"
    mask_tma = 'TMA : %s'
    mask_restit = "DEJA RESTITUE DANS : %s"
    mask_user_end = separ + CR


    def __init__(self, **kargs):
        """Initialize histor object.
        """
        HISTOR.__init__(self)

        # specific arguments
        self.server_url = kargs.get('url', None)
        self.fmt_url_issue = '%s/issue%%s' % saxutils.escape(self.server_url)


    def clean_dict(self, dico):
        """Keep only elements of dict of type string and number,
        and escape all HTML characters.
        """
        newd = {}
        for k, v in list(dico.items()):
            if k == 'CR' or type(v) in NumberTypes:
                newd[k] = v
            elif type(v) is StringType:
                newd[k] = saxutils.escape(str(v))
            elif v is None:
                newd[k] = ''
        return newd


    def DictIssue(self, issue, l_rep=None):
        """Represent an issue as a dict object.
        """
        dico = HISTOR.DictIssue(self, issue, l_rep)

        # specific fields
        dico['url_issue'] = self.fmt_url_issue % issue['id']

        # multi-lines fields
        for k in ('reponse',):
            dico[k] = dico[k].replace(os.linesep, self.CR)

        return dico


class HISTOR_FSQ(HISTOR):
    """Class representing issues for quality purpose.
    """
    CR = os.linesep
    format = 'fsq'
    separ = CR
    mask = separ + """Fiche %(id)d : %(_title)s

%(reponse)s

Risque de résultats faux depuis la version : %(_fauxVexpl)s %(_fauxVdev)s

"""
    mask_user_begin = ""
    mask_user_end = ""


    def DictIssue(self, issue, l_rep=None):
        """Represent an issue as a dict object.
        """
        dico = HISTOR.DictIssue(self, issue, l_rep)

        # clean response
        for k in ('reponse',):
            dico[k] = re.sub(' +', ' ', dico[k])
            dico[k] = dico[k].strip()

        return dico



def InitHistor(format='text', **kargs):
    """Return a histor object according to `format`.
    """
    if format == 'text':
        return HISTOR(**kargs)
    elif format == 'html':
        return HISTOR_HTML(**kargs)
    elif format == 'fsq':
        return HISTOR_FSQ(**kargs)
    else:
        raise HistorError(_('Unknown histor format : %s') % str(format))
