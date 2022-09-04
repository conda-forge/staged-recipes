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

"""Utilities on strings.
"""

import os
import os.path as osp

from asrun.common.utils import get_encoding
from asrun.core import magic

def ufmt(uformat, *args):
    """Helper function to format a string by converting all its arguments to unicode"""
    if type(uformat) is not str:
        uformat = to_unicode(uformat)
    nargs = []
    for arg in args:
        if type(arg) is str:
            nargs.append(to_unicode(arg))
        else:
            nargs.append(arg)
    return uformat % tuple(nargs)

def to_unicode(string):
    """Try to convert string into a unicode string
    """
    if type(string) is str:
        return string
    for encoding in ('utf-8', 'iso-8859-15', 'cp1252'):
        try:
            s = str(string, encoding)
#         print string[:80], ">>>>>", encoding
            return s
        except UnicodeDecodeError:
            pass
    return str(string, 'utf-8', 'replace')

def from_unicode(ustring, encoding, errors='replace'):
    """Try to encode a unicode string using encoding.
    """
    try:
        return ustring.encode(encoding)
    except UnicodeError:
        pass
    return ustring.encode(encoding, errors)

def convert(content, encoding=None, errors='replace'):
    """Convert content using encoding or default encoding if None."""
    if type(content) not in (str, str):
        content = str(content)
    if type(content) == str:
        content = to_unicode(content)
    return content

def convert_list(args):
    """Convert a list of strings."""
    return list(map(convert, args))

def indent(text, prefix):
    """Add `prefix` before each line of `text`.
    """
    l_s = [prefix+line for line in text.split(os.linesep)]
    return os.linesep.join(l_s)

def add_to_tail(dirname, line, filename='fort.6', **kwargs):
    """Add the given line at the end 'dirname/filename'."""
    if dirname == '':
        return
    fobj = open(osp.join(dirname, filename), 'a')
    print(line, file=fobj, **kwargs)
    fobj.flush()
    fobj.close()

def cut_long_lines(txt, maxlen, sep=os.linesep,
                   l_separ=(' ', ',', ';', '.', ':')):
    """Coupe les morceaux de `txt` (isolés avec `sep`) de plus de `maxlen`
    caractères.
    On utilise successivement les séparateurs de `l_separ`.
    """
    l_lines = txt.split(sep)
    newlines = []
    for line in l_lines:
        if len(line) > maxlen:
            l_sep = list(l_separ)
            if len(l_sep) == 0:
                newlines.extend(force_split(line, maxlen))
                continue
            else:
                line = cut_long_lines(line, maxlen, l_sep[0], l_sep[1:])
                line = maximize_lines(line, maxlen, l_sep[0])
            newlines.extend(line)
        else:
            newlines.append(line)
    # au plus haut niveau, on assemble le texte
    if sep == os.linesep:
        newlines = os.linesep.join(newlines)
    return newlines

def maximize_lines(l_fields, maxlen, sep):
    """Construit des lignes dont la longueur est au plus de `maxlen` caractères.
    Les champs sont assemblés avec le séparateur `sep`.
    """
    newlines = []
    if len(l_fields) == 0:
        return newlines
    # ceinture
    assert max([len(f) for f in l_fields]) <= maxlen, 'lignes trop longues : %s' % l_fields
    while len(l_fields) > 0:
        cur = []
        while len(l_fields) > 0 and len(sep.join(cur + [l_fields[0],])) <= maxlen:
            cur.append(l_fields.pop(0))
        # bretelle
        assert len(cur) > 0, l_fields
        newlines.append(sep.join(cur))
    newlines = [l for l in newlines if l != '']
    return newlines

def force_split(txt, maxlen):
    """Force le découpage de la ligne à 'maxlen' caractères.
    """
    l_res = []
    while len(txt) > maxlen:
        l_res.append(txt[:maxlen])
        txt = txt[maxlen:]
    l_res.append(txt)
    return l_res

def split_endlines(txt):
    """Split text using platform 'linesep',
    but try \n, \r if no 'linesep' was found.
    Differs from str.splitlines because it uses only one of these separators.
    """
    split_text = txt.split(os.linesep)
    if len(split_text) == 1:
        split_text = split_text[0].split('\n')
    if len(split_text) == 1:
        split_text = split_text[0].split('\r')
    return split_text

def cleanCR(content):
    """Clean the line terminators
    """
    # `os.linesep` the right line terminator on this platform.
    l_new = content.splitlines()
    s_new = os.linesep.join(l_new)
    if content.endswith('\n') or content.endswith('\r'):
        s_new += os.linesep
    return s_new

def file_cleanCR(filename):
    """Helper function to clean the line terminators in a file.
    """
    if not osp.isfile(filename):
        raise IOError('File not found : %s' % filename)
    elif not os.access(filename, os.W_OK):
        raise IOError('No write access to %s' % filename)
    # cleaning
    with open(filename, 'r') as f:
        content = f.read()
    with open(filename, 'w') as f:
        f.write(cleanCR(content))
