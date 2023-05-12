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
This module defines syntaxes to run command lines.
"""

from asrun.common.sysutils import on_linux

if on_linux():
    COMMAND = {
        'foreground' : '( %(cmd)s ) > /dev/null 2>&1',
        'background' : '( %(cmd)s ) > /dev/null 2>&1 &',
        'follow_with_stderr' : '( %(cmd)s ; echo %(var)s=$? ) 2>&1 | tee %(output)s',
        'follow_separ_stderr' : '( %(cmd)s ; echo %(var)s=$? ) 2> %(error)s | tee %(output)s',
        'not_follow_with_stderr' : '( %(cmd)s ) > %(output)s 2>&1',
        'not_follow_separ_stderr' : '( %(cmd)s ) > %(output)s 2> %(error)s',
        'rm_file' : '\\rm -f %(args)s',
        'rm_dirs' : '\\rm -rf %(args)s',
        'copy' : 'cp -L -r %(args)s',
        'ping' : 'ping -c 1 -W %(timeout)s %(host)s',
        'shell_cmd' : "bash -c",
        'file' : "file %(args)s",
        'hostid' : 'ifconfig',
    }
else:
    #TODO
    COMMAND = {
        'foreground' : 'start %(cmd)s',
        'background' : 'start %(cmd)s',
        'follow_with_stderr' : '( %(cmd)s ; echo %(var)s=%errorlevel% ) | tee %(output)s',
        'follow_separ_stderr' : '( %(cmd)s ; echo %(var)s=%errorlevel% ) | tee %(output)s',
        'not_follow_with_stderr' : '( %(cmd)s ) > %(output)s',
        'not_follow_separ_stderr' : '( %(cmd)s ) > %(output)s',
        'rm_file' : 'del /f %(args)s',
        'rm_dirs' : 'rd /f %(args)s',
        'copy' : 'copy %(args)s',
        'ping' : 'ping -n 1 -w %(timeout)s %(host)s',
        'shell_cmd' : "cmd.exe",
        'file' : "file %(args)s", #XXX
        'hostid' : 'ipconfig',
    }
