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
This module defines simple classes about status.
Example : job status.
"""

class JobInfo(object):
    """Store some informations of a job."""
    all_attrs = (
        'jobid', 'jobname',
        'state', 'diag', 'node', 'cputime', 'wrkdir', 'queue'
    )
    __slots__ = all_attrs

    def __init__(self):
        pass

    def dict_values(self):
        """Return a dict containing the value of all the attributes."""
        dicv = {}
        for attr in self.all_attrs:
            dicv[attr] = getattr(self, attr, "")
        return dicv

    def as_func_actu_result(self):
        """Returns a tuple as expected by the FuncActu function."""
        attrs = ('state', 'diag', 'node', 'cputime', 'wrkdir', 'queue')
        out = []
        for attr in attrs:
            out.append(getattr(self, attr, None) or '_')
        return tuple(out)


if __name__ == '__main__':
    jobinf = JobInfo()
    jobinf.jobname = 'nomjob'
    jobinf.jobid = 123456
    jobinf.state = 'RUN'
    print(jobinf.dict_values())
    print(jobinf.as_func_actu_result())
