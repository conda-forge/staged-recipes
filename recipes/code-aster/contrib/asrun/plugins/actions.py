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
This module defines the default scheme.
"""
# all actions must accept an optional keyword argument print_output
# to disable totally all printing.

ACTIONS = {
    'serv' : {  # --serv .export
        'export_position' : 0,
        'min_args' : 1,
        'max_args' : 1,
        'default_schema' : "asrun.plugins.default.serv",
        # Returns : exit_code, output
    },
    'sendmail' : {  # --sendmail .export filename
        'export_position' : 0,
        'min_args' : 2,
        'max_args' : 2,
        'default_schema' : "asrun.plugins.default.sendmail",
        # Returns : exit_code
    },
    'info' : {  # --info .export
        'export_position' : 0,
        'min_args' : 1,
        'max_args' : 1,
        'default_schema' : "asrun.plugins.default.info",
        # Returns : exit_code, output
    },
    'actu' : {  # --actu .export
        'export_position' : 0,
        'min_args' : 1,
        'max_args' : 1,
        'default_schema' : "asrun.plugins.default.actu",
        # Returns : exit_code, output
    },
    'del' : {  # --del .export
        'export_position' : 0,
        'min_args' : 1,
        'max_args' : 1,
        'default_schema' : "asrun.plugins.default.stop_del",
        # Returns : exit_code
    },
    'purge_flash' : {  # --purge_flash .export job_number [job_number2 [...]]
        'export_position' : 0,
        'min_args' : 2,
        'max_args' : 999999,
        'default_schema' : "asrun.plugins.default.purge_flash",
        # Returns : exit_code
    },
    'tail' : {  # --tail .export
        'export_position' : 0,
        'min_args' : 1,
        'max_args' : 1,
        'default_schema' : "asrun.plugins.default.tail",
        # Returns : exit_code, output
    },
    'edit' : {  # --edit .export
        'export_position' : 0,
        'min_args' : 1,
        'max_args' : 1,
        'default_schema' : "asrun.plugins.default.edit",
        # Returns : exit_code
    },
    'get_results' : {   # --get_results .export
        'export_position' : 0,
        'min_args' : 1,
        'max_args' : 1,
        'default_schema' : "asrun.plugins.default.get_results",
        # Returns : exit_code
    },
    'get_export' : {   # --get_export .export testcase
        'export_position' : 0,
        'min_args' : 2,
        'max_args' : 2,
        'default_schema' : "asrun.plugins.default.get_export",
        # Returns : exit_code, output
    },
    'create_issue' : {   # --create_issue issue_file .export
        'export_position' : 1,
        'min_args' : 2,
        'max_args' : 2,
        'default_schema' : "asrun.plugins.default.create_issue",
        # Returns : exit_code
    },
    'insert_in_db' : {   # --insert_in_db .export
        'export_position' : 0,
        'min_args' : 1,
        'max_args' : 2,
        'default_schema' : "asrun.plugins.default.insert_in_db",
        # Returns : exit_code
    },
    'profile_modifier' : {
        # Not an action. Can not be overridden by --schema option.
        # Arguments : AsterProfil object and a boolean 'on_client_side'
        # Returns : a service name, and an AsterProfil object.
        # called from profile_modifier.py
    },
    'calcul' : {
        # Not an action. Can not be overridden by --schema option.
        # Argument : AsterCalcul object.
        # Returns : AsterProfil object.
        # called from calcul.py
    },
    'execute' : {
        # Not an action. Can not be overridden by --schema option.
        # Argument : AsterProfil object.
        # Returns : a class derivated from Runner.
        # called from execute.py
    },
    'tail_exec' : {
        # Not an action. Can not be overridden by --schema option.
        # Arguments : See asrun.job.Func_tail.
        # Returns : status, success, output.
        # called from job.py
    },
}
