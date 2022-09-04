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
Helper to read/write resources files :
    - config files : etc/codeaster/{asrun,aster,agla,config_nodename}
    - user files   : ~/.astkrc/{config_serveurs,prefs}
"""
# should only use standard python modules

import os
import os.path as osp
import re
import configparser as CP
from asrun.common.sysutils import unexpandvars as unexpandvars_func


def read_rcfile(ficrc, destdict, mcfact_key=None, mcsimp=None,
                replacement={}, expandvars=True):
    """Read a ressource file and store variables into 'destdict'.
    'replacement' defines a dict to replace the read value by another
    (exemple _VIDE to '')."""
    f = open(ficrc, 'r')
    dcur = destdict
    iocc = -1
    for line in f:
        if not re.search('^[ ]*#', line):
            try:
                key, value = decode_config_line(line)
                if expandvars and type(value) in (str, str):
                    value = osp.expandvars(value)
                # mot-cle "facteur"
                if mcfact_key and key == mcfact_key:
                    iocc += 1
                    destdict[value] = { '__id__' : iocc }
                    dcur = destdict[value]
                    continue
                # mot-cle simp repetable ?
                if mcsimp and key in mcsimp and key in dcur:
                    if str(value) not in str(dcur[key]).split():
                        value = str(dcur[key]) + ' ' + str(value)
                    else:
                        value = str(dcur[key])
                dcur[key] = value
                d_repl = replacement.get(key) or replacement.get('__all__')
                if d_repl is not None and d_repl.get(value) is not None:
                    dcur[key] = d_repl[value]
            except:
                pass
    f.close()

def write_rcfile(ficrc, fromdict, mcfact_key=None, mcsimp=None,
                replacement={}, unexpandvars=True):
    """Write a ressource file reading the values from 'fromdict'."""
    def fline(key, value):
        return "%s : %s" % (key, value)

    def written_value(key, value):
        if unexpandvars:
            value = unexpandvars_func(value)
        d_repl = replacement.get(key) or replacement.get('__all__')
        if d_repl is not None and d_repl.get(value) is not None:
            value = d_repl[value]
        return value

    rcvers = fromdict.pop('astkrc_version', 1.1)
    txt = [ "# AUTOMATICALLY GENERATED - DO NOT EDIT !",
            fline("astkrc_version", "%.1f" % rcvers),
            "#" ]
    nodict, mcfact = [], []
    for key, value in list(fromdict.items()):
        if type(value) is dict:
            num = value.get('__id__', len(mcfact))
            mcfact.append((num, key))
            assert mcfact_key is not None, "mcfact key required"
        else:
            nodict.append(key)
    nodict.sort()
    for key in nodict:
        if key.startswith('__'):
            continue
        value = written_value(key, fromdict[key])
        txt.append(fline(key, value))
    txt.append("#")
    mcfact.sort()
    for _, occ in mcfact:
        txt.append(fline(mcfact_key, occ))
        lkeys = list(fromdict[occ].keys())
        lkeys.sort()
        for key in lkeys:
            ocval = fromdict[occ][key]
            if key.startswith('__'):
                continue
            if mcsimp and key in mcsimp:
                ocval = ocval.split(' ')
            else:
                ocval = [ocval, ]
            for value in ocval:
                value = written_value(key, value)
                txt.append(fline(key, value))
        txt.append("#")
    txt.append("")
    text = os.linesep.join(txt)
    with open(ficrc, "w") as f:
        f.write(text)

def get_nodepara(nodename, para, default):
    """Return of `para` from config_`nodename` file if exists, or
    default if not."""
    from asrun.installation import confdir
    val = default
    fcn = osp.join(confdir, 'config_%s' % nodename)
    if osp.isfile(fcn):
        mdict = {}
        read_rcfile(fcn, mdict)
        val = mdict.get(para, val)
    return val


def decode_config_line(line):
    """Read a line
    """
    mc, val = re.search('([-a-z_A-Z0-9]+) *: *(.*)', line.strip()).groups()
#   print line, ">>>", mc, val
    val = convert_number_bool(val)
    return mc, val


def time_to_seconds(val):
    """Convert 'hh:mm:ss' in seconds
    """
    mattps = re.search('([0-9]*):([0-9]*):([0-9]+)', val)
    if mattps is None:
        mattps = re.search('([0-9]*):([0-9]+)', val)
        if mattps is not None:
            mm, ss = [int(v) for v in mattps.groups()]
            val = mm*60 + ss
    else:
        hh, mm, ss = [int(v) for v in mattps.groups()]
        val = hh*3600 + mm*60 + ss
    return val


def convert_number_bool(value):
    """Try to convert numbers and boolean values from string
    """
    if type(value) in (str, str) and value == '_VIDE':
        value = ''
    try:
        if value.isdigit():
            value = int(value)
        else:
            value = float(value)
    except ValueError:
        if value in ('True', 'False'):
            value = eval(value)
    return value


def parse_config(filename, dict_default={}, raw=False):
    """Return a dict of the content of 'filename'.
    """
    content = {}
    if raw:
        config = CP.RawConfigParser()
    else:
        config = CP.SafeConfigParser()
    try:
        with open(filename) as f:
            config.readfp(f)
    except CP.ParsingError:
        return content
    # add defaults
    for option, value in list(dict_default.items()):
        config.set('DEFAULT', option, value)

    l_sect = config.sections()
    for title in l_sect:
        d = { }
        for opt in config.options(title):
            try:
                v = config.getint(title, opt)
            except ValueError:
                try:
                    v = config.getfloat(title, opt)
                except ValueError:
                    v = config.get(title, opt)
            d[opt] = v
        content[title] = d
    return content
