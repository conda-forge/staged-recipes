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
This module encapsulates access to MySQL databases.
"""

__all__ = ['CONNECT', 'MySQLError']


import os
from types import ListType, TupleType, LongType
EnumTypes = (ListType, TupleType)

import traceback
import MySQLdb

from asrun.common.i18n import _
from asrun.common.sysutils import get_home_directory


class MySQLError(Exception):
    """Error during MySQLdb commands.
    """


class CONNECT:
    """Open a MySQL connection using parameters defined in the file
    `rcdir`/.mysql_connect_`db` where `db` and `rcdir` is given
    through __init__.

    Attributes :
        cursor : Cursor to the active connection.

    Methods :
        exe :   Execute a SQL query
    """
    def __init__(self, db, **kargs):
        """Open the connection.
        """
        # optional arguments
        self.verbose    = kargs.get('verbose', True)
        self.debug      = kargs.get('debug', False)
        self.autocommit = kargs.get('autocommit', True)
        rcdir           = kargs.get('rcdir', get_home_directory())
        mydict = kargs.get('db_params')
        self.connection = None
        
        if mydict is None:
            fic = os.path.join(rcdir, '.mysql_connect_'+db)
            if not os.path.exists(fic):
                raise IOError(_('No such file or directory : %s') % fic)

            mydict = dict()
            try:
                with open(fic) as f:
                    exec(compile(f.read(), fic, 'exec'), mydict)
            except:
                raise MySQLError(_('Can not read connection parameters'))
        try:
            # set charset='utf8' not applied because of a bug in MySQLdb 1.2.x
            # with charset='utf8', "SELECT * FROM _msg WHERE id=85929;" fails!
            self.connection = MySQLdb.connect(host=mydict['host'], user=mydict['user'],
                    passwd=mydict['passwd'], db=mydict['db'])
        except:
            raise MySQLError(_('Connection failed to %s for user %s (and password)') \
                % (mydict['host'], mydict['user']))
        # if autocommit doesn't exist hope it's on by default !
        if self.autocommit and hasattr(self.connection, 'autocommit'):
            self.connection.autocommit(self.autocommit)
        self.cursor = self.connection.cursor()
        if self.verbose:
            print(_("""Connection to '%(host)s' on '%(db)s' database.""") % mydict)

    def __del__(self):
        """Close the connection on deletion.
        """
        if self.connection is not None:
            self.connection.close()

    def exe(self, query):
        """Execute the SQL 'query' using the active connection.
        Return result lines (as list).
        """
        if self.debug:
            print('### Query : %s%s--> not executed.' % (query, os.linesep))
            return []
        if not hasattr(self.cursor, 'fetchone'):
            print(_('Connection not opened.'))
            return []
        try:
            nb = self.cursor.execute(query)
        except:
            traceback.print_exc()
            raise MySQLError('ERROR query = %s' % query)
        if self.verbose:
            print('### Query : %s%s--> %d lines returned.' % (query, os.linesep, nb))
        tab = []
        for lig in self.cursor.fetchall():
            tab.append(lig)
        return tab

    def showtab(self):
        """Return tables of the database (as list).
        """
        res = self.exe("""SHOW TABLES;""")
        li  = []
        for c in res:
            li.append(c[0])
        return li

    def showcol(self, table):
        """Return names of the columns of the 'table' (as list).
        """
        res = self.exe("""SHOW COLUMNS FROM %s;""" % table)
        li  = []
        for c in res:
            li.append(c[0])
        return li

    def select_all(self, table):
        """Return all lines of the 'table' (as list).
        """
        return self.exe("""SELECT * FROM %s;""" % table)

    def insert(self, table, lines):
        """Insert 'lines' (as a list of dict "column:value") into the 'table'.
        Return the number of added lines.
        """
        nb = 0
        if not hasattr(self.cursor, 'fetchone'):
            print(_('Connection not opened.'))
            return nb
        if not type(lines) in EnumTypes:
            lines = [lines, ]
        for line in lines:
            query = ['INSERT INTO %s SET' % table]
            lset  = []
            for k, v in list(line.items()):
                if v != None:
                    if type(v) is LongType:
                        v = '%d' % v
                    lset.append('%s=%s' % (k, repr(v)))
            query.append(', '.join(lset))
            query.append(';')
            if self.verbose:
                print('### Query : %s' % (' '.join(query)))
            try:
                nb += self.cursor.execute(' '.join(query))
            except:
                traceback.print_exc()
                raise MySQLError('ERROR query = %s' % (' '.join(query)))
        if self.verbose:
            print(_('--> %d lines added.') % nb)
        if nb != len(lines):
            print(_('ERROR : not all lines have been added.'))
        return nb

    def update(self, table, line, cond):
        """Update 'line' (as a list of dict "column:value") into the 'table'
        where 'cond' is respected.
        Return the number of updated lines.
        """
        if not hasattr(self.cursor, 'fetchone'):
            print(_('Connection not opened.'))
            return 0
        query = ['UPDATE %s SET' % table]
        lset  = []
        for k, v in list(line.items()):
            if v != None:
                if type(v) is LongType:
                    v = '%d' % v
                lset.append('%s=%s' % (k, repr(v)))
        query.append(', '.join(lset))
        query.append('WHERE')
        lwh = []
        for k, v in list(cond.items()):
            if v != None:
                if type(v) is LongType:
                    v = '%d' % v
                lwh.append('%s=%s' % (k, repr(v)))
        query.append(' AND '.join(lwh))
        query.append(';')
        if self.verbose:
            print('### Query : %s' % (' '.join(query)))
        try:
            nb = self.cursor.execute(' '.join(query))
        except:
            traceback.print_exc()
            raise MySQLError('ERROR query = %s' % (' '.join(query)))
        return nb
