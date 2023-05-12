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
This module defines the default configuration to make
etc/codeaster/asrun file as empty as possible.
"""

import os
import os.path as osp

from asrun.installation import confdir


entries = (
    ("Section", "REMOTE SERVERS", None),
    ("http_server_ip", "www.code-aster.org",
        "Code_Aster web server (for updates)"),
    ("http_server_user", "anonymous",
        "User on Code_Aster web server (for updates)"),
    ("http_rep_maj", "/FICHIERS",
        "Repository of update files on the http server"),
    ("devel_server_ip", "aster.cla.edfgdf.fr",
        "EDF development server (only for intranet usage"),
    ("devel_server_user", "",
        "User on EDF development server should be set in ~/.astkrc/config"),
    ("local_rep_maj", os.environ.get("ASTER_TMPDIR", "/tmp"),
        "Local repository where update files can be downloaded before"),

    ("Section", "NETWORK CONFIGURATION", None),
    ("protocol_exec", "asrun.plugins.server.SSHServer",
        "The protocol the clients must used to connect this server."),
    ("protocol_copyto", "asrun.plugins.server.SCPServer",
        "The protocol the clients must used to copy data files onto this server."),
    ("protocol_copyfrom", "asrun.plugins.server.SCPServer",
        "The protocol the clients must used to download results files from this server."),
    ("proxy_dir", osp.join(os.environ.get("ASTER_TMPDIR", "/tmp"), "PROXY_DIR"),
        "Directory shared by all compute nodes and used as a proxy between "
        "then clients and the server : clients upload data files into this directory "
        "and download results files from it. For example : /export/tmp/PROXY_DIR..."),

    ("Section", "LOCAL CONFIGURATION", None),
    ("platform", None,
        "Code_Aster platform (one of LINUX, LINUX64, SOLARIS, SOLARIS64, TRU64, IRIX)"),
    ("rep_tmp", os.environ.get("ASTER_TMPDIR", "/tmp"),
        "root of temporary space for astk services"),
    ("rep_trav", os.environ.get("ASTER_TMPDIR", "/tmp"),
        "Temporary directory for Aster executions"),
    ("shared_tmp", os.environ.get("ASTER_TMPDIR", "/tmp"),
        "Temporary directory for Aster executions shared by all compute nodes"
        "(used by mpi executions). For example : /export/tmp, /home/tmp..."),
    ("motd", osp.join(confdir, "motd"),
        "Message of the day"),
    ("symlink", True,
        "Choose True to create symbolic links instead of copying executable and catalogs"),

    ("Section", "COMMAND LINES", None),
    ("ps_cpu", "/bin/ps -e --width=512 -ocputime -ocommand",
        "command line to query a process with its full command line"),
    ("ps_pid", "/bin/ps -e --width=512 -opid -ocommand",
        "command line to query a process with its pid"),
    ("editor", None,
        "text editor"),
    ("terminal", None,
        "terminal for interactive calculation following output "
        "@E will be remplaced by the command line"),

    ("Section", "COMPUTATIONAL NODES", None),
    ("node", None,
        "nodes of the cluster for interactive calculation or to call batch commands"),
    ("serv_as_node", True,
        "add frontal machine (which is astk server in GUI) as a compute node"),
    ("only_serv_as_node", False,
        "keep only this server (ignore 'node' list). "
        "This has no effect if serv_as_node is False."),

    ("Section", "BATCH MODE", "Only LSF, PBS and Sun Grid Engine are supported"),
    ("batch", "non",
        "Choose 'oui' if a batch scheduler is available"),
    ("batch_nom", "",
        "one of LSF, SunGE, PBS, Slurm"),
    ("batch_ini", "",
        "initialisation (shell script, sh/ksh syntax)"),

    ("batch_memmax", 9999999,
        "memory limit in batch mode (MB)"),
    ("batch_tpsmax", "9999:00:00",
        "cpu time limit in batch mode (hh:mm:ss)"),
    ("batch_nbpmax", 9999,
        "maximum number of processors in batch mode (OpenMP)"),
    ("batch_mpi_nbpmax", 9999,
        "maximum number of processors in batch mode (MPI)"),
    ("batch_queue_group", "",
        "groups of batch queues and the available queues in each group "
        "(batch_queue_'group name' must be defined for each group)"),
    ("batch_distrib_hostfile", osp.join(confdir, "batch_distrib_hostfile"),
        "default parameters for distributed calculations (parametric studies or testcases)"
        "in batch mode"),

    ("Section", "INTERACTIVE MODE", None),
    ("interactif", "oui",
        "Choose 'non' to prohibit interactive calculation"),
    ("interactif_memmax", 9999999,
        "memory limit in interactive mode (MB)"),
    ("interactif_tpsmax", "9999:00:00",
        "cpu time limit in interactive mode (hh:mm:ss)"),
    ("interactif_nbpmax", 9999,
        "maximum number of processors in interactive mode (OpenMP)"),
    ("interactif_mpi_nbpmax", 9999,
        "maximum number of processors in interactive mode (MPI)"),
    ("interactif_distrib_hostfile", osp.join(confdir, "interactif_distrib_hostfile"),
        "default parameters for distributed calculations (parametric studies or testcases) "
        "in interactive mode"),

    ("Section", "MPI",
        "MPI commands and parameters\n"
        "Python string formatting is allowed with these keywords (see examples above) : "
        "mpi_hostfile, mpi_nbnoeud, mpi_nbcpu\n"
        "\n"
        "Example for OpenMPI :\n"
        "mpirun_cmd : mpirun -np %(mpi_nbcpu)s --hostfile %(mpi_hostfile)s %(program)s\n"
        "mpi_get_procid_cmd : echo $OMPI_MCA_ns_nds_vpid    for OpenMPI 1.2\n"
        "mpi_get_procid_cmd : echo $OMPI_MCA_orte_ess_vpid  for OpenMPI 1.3\n"
        "\n"
        "Example for Mpich2 :\n"
        "mpi_ini : mpdboot --totalnum=%(mpi_nbnoeud)s --file=%(mpi_hostfile)s ; sleep 10\n"
        "mpi_get_procid_cmd : echo $PMI_RANK\n"
        "\n"
        "Example for LAM/MPI :\n"
        "mpi_get_procid_cmd : echo $LAMRANK\n"),
    ("mpirun_cmd", "",
        "mpirun command line"),
    ("mpi_hostfile", osp.join(confdir, "aster-mpihosts"),
        "file which contains list of hosts (REQUIRED even if it is not used in mpirun_cmd)"),
    ("mpi_ini", "",
        "command called to initialize MPI environment"),
    ("mpi_end", "",
        "command called to close the MPI session"),
    ("mpi_get_procid_cmd", "echo $PMI_RANK",
        "shell command to get processor id"),

    ("Section", "DEBUG",
        "debug commands\n"
        "@E will be remplaced by the name of the executable\n"
        "@C will be remplaced by the name of the corefile\n"
        "@D will be remplaced by the filename which contains 'where+quit'\n"
        "@d will be remplaced by the string 'where ; quit'\n"),
    ("cmd_post", "gdb -batch --command=@D @E @C",
        "perform a post-mortem analysis"),
    ("cmd_dbg", "ddd --debugger gdb --command=@D @E @C",
        "run a debuger interactively"),

    ("Section", "USER COMMANDS",
        "command lines for 'exectool' (see Options menu in astk/codeaster-gui)\n"
        "Example to run memcheck tool of valgrind:\n"
        "memcheck : valgrind --tool=memcheck --error-limit=no --leak-check=full"),

    ("Section", "BUILD", None),
    ("ctags_style", "exuberant",
        "style of ctags version used (valid values are 'exuberant' or 'emacs')"),

)
