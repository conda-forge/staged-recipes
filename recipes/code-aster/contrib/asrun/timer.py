#@ MODIF as_timer Utilitai  DATE 07/04/2008   AUTEUR COURTOIS M.COURTOIS
# -*- coding: utf-8 -*-
# ======================================================================
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
# ======================================================================
# RESPONSABLE

"""
Definition of AsterTimer class.
"""


import os
import time
from hashlib import sha1

from asrun.common.i18n import _
from asrun.mystring import convert
from asrun.common.sysutils import on_windows

from asrun.backward_compatibility import bwc_deprecate_class

# os.times : On windows, only the first two items are filled, the others are zero
_id_cpu = 0
_id_sys = 1
if on_windows():
    _id_cpu = 1
    _id_sys = 0

def _dtimes():
    """Return a dict of cpu, system and total times.
    """
    l_t = os.times()
    t4 = time.time()
    return { 'cpu'   : (l_t[_id_cpu], l_t[2]),
             'sys'   : (l_t[_id_sys], l_t[3]),
             'tot'   : t4, }


def _conv_hms(t):
    """Convert a number of seconds in hours, minutes, seconds.
    """
    h = int(t / 3600)
    m = int(t % 3600) // 60
    s = (t % 3600) % 60
    return h, m, s


class AsterTimer:
    """This class provides methods to easily measure time spent during
    different steps.
    Methods :
        Start : start a timer in mode 'INIT' ([re]start from 0) or 'CONT'
            (restart from last value).
        Stop  : stop a timer
    Attributes :
        timers : dict {
            timer_id : {
                'name'   : timer legend (=timer_id by default),
                'state'  : state,
                'cpu_t0' : initial cpu time,
                'cpu_dt' : spent cpu time,
                'sys_t0' : initial system time,
                'sys_dt' : spent system time,
                'tot_t0' : start time,
                'tot_dt' : total spent time,
                'num'    : timer number (to print timers in order of creation),
                'hide'   : boolean,
            },
            ...
        }
            state is one of 'start', 'stop'
    """
    MaxNumTimer = 9999999
    MaxSize = 500

    def __init__(self, add_total=True, format='as_run', maxlabel=None):
        """Constructor
        """
        # ----- initialisation
        self.timers = {}
        self.add_total = add_total
        self.comment = ''
        self._comment_seen = {}
        self._oversize = False
        self._oversize_name = maxlabel or _("after %d timers")
        try:
            self._oversize_name = self._oversize_name % self.MaxSize
        except TypeError:
            pass
        if not format in ('as_run', 'aster'):
            format = 'as_run'

        if format == 'as_run':
            self.mintitr = 33
            self._fmtlig = '   %%(name)-%(adjtitr)ds  %%(cpu_dt)9.2f  %%(sys_dt)9.2f  %%(cpu_sys)9.2f  %%(tot_dt)9.2f'
            self._fmtstr = '   %%(title)-%(adjtitr)ds  %%(cpu)9s  %%(sys)9s  %%(cpu+sys)9s  %%(elapsed)9s'
            self._sepa   = ' ' + '-'*81
            self.TotalKey = 'Total'  # DO NOT translate this label because it will be "grep'ed" by AsterCalcul
            self.d_labels = {
                'title'   : '',
                'cpu'     : _('cpu'),
                'sys'     : _('system'),
                'cpu+sys' : _('cpu+sys'),
                'elapsed' : _('elapsed'),
            }
        elif format == 'aster':
            self.mintitr = 24
            self._fmtlig = ' * %%(name)-%(adjtitr)ds : %%(cpu_dt)10.2f : %%(sys_dt)10.2f : %%(cpu_sys)10.2f : %%(tot_dt)10.2f *'
            self._fmtstr = ' * %%(title)-%(adjtitr)ds : %%(cpu)10s : %%(sys)10s : %%(cpu+sys)10s : %%(elapsed)10s *'
            self._sepa   = ' ' + '*'*80
            self.TotalKey = 'TOTAL_JOB'
            self.d_labels = {
                'title'   : 'COMMAND',
                'cpu'     : 'USER',
                'sys'     : 'SYSTEM',
                'cpu+sys' : 'USER+SYS',
                'elapsed' : 'ELAPSED',
            }

        self.adjust_format()
        self.total_key = id(self)
        if self.add_total:
            self.Start(self.total_key, name=self.TotalKey, num=self.MaxNumTimer)

    def Start(self, timer, mode='CONT', num=None, hide=None, name=None):
        """Start a new timer or restart one
        """
        if len(self.timers) > self.MaxSize and name != self._oversize_name:
            if not self._oversize:
                self._oversize = True
                self.Start(self._oversize_name, num=1.e6, name=self._oversize_name)
            return
        name = name or timer
        isnew = self.timers.get(timer) is None
        if not num:
            num = len(self.timers)
        if mode == 'INIT':
            num = self.timers[timer]['num']
        dico = _dtimes()
        if isnew or mode == 'INIT':
            self.timers[timer] = {
                'name'   : name,
                'state'  : 'start',
                'cpu_t0' : dico['cpu'],
                'cpu_dt' : 0.,
                'sys_t0' : dico['sys'],
                'sys_dt' : 0.,
                'tot_t0' : dico['tot'],
                'tot_dt' : 0.,
                'num'    : num,
                'hide'   : hide,
            }
        elif mode == 'CONT' and self.timers[timer]['state'] == 'stop':
            self.timers[timer].update({
                'state'  : 'start',
                'cpu_t0' : dico['cpu'],
                'sys_t0' : dico['sys'],
                'tot_t0' : dico['tot'],
            })


    def Add(self, timer, cpu_dt=0., sys_dt=0., to_total=False):
        """Add dt values (hidden to os.times, for example under mpirun) to a timer.
        """
        if len(self.timers) > self.MaxSize:
            return
        if self.timers.get(timer) is not None:
            self.timers[timer]['cpu_dt'] += cpu_dt
            self.timers[timer]['sys_dt'] += sys_dt
        if to_total and timer != self.total_key:
            self.Add(self.total_key, cpu_dt, sys_dt)


    def Stop(self, timer, hide=None):
        """Stop a timer
        """
        if self.timers.get(timer) is None:
            if len(self.timers) > self.MaxSize:
                return
            self.timers[timer] = {
                'name'   : timer,
                'hide'   : hide,
                'state'  : 'stop',
                'cpu_t0' : 0.,
                'cpu_dt' : 0.,
                'sys_t0' : 0.,
                'sys_dt' : 0.,
                'tot_t0' : 0.,
                'tot_dt' : 0.,
                'num': len(self.timers),
            }
        elif self.timers[timer]['state'] == 'start':
            dico = _dtimes()
            self.timers[timer]['state'] = 'stop'
            for i in range(len(dico['cpu'])):
                self.timers[timer]['cpu_dt'] += \
                    dico['cpu'][i] - self.timers[timer]['cpu_t0'][i]
            self.timers[timer]['cpu_t0'] = dico['cpu']
            for i in range(len(dico['sys'])):
                self.timers[timer]['sys_dt'] += \
                    dico['sys'][i] - self.timers[timer]['sys_t0'][i]
            self.timers[timer]['sys_t0'] = dico['sys']
            self.timers[timer]['tot_dt'] = self.timers[timer]['tot_dt'] + \
                    dico['tot'] - self.timers[timer]['tot_t0']
            self.timers[timer]['tot_t0'] = dico['tot']
            if hide is not None:
                self.timers[timer]['hide'] = hide


    def StopAndGet(self, timer, *args, **kwargs):
        """Stop a timer and return "delta" values.
        """
        self.Stop(timer, *args, **kwargs)
        if self.timers.get(timer) is None:
            return 0., 0., 0.
        cpu_dt  = self.timers[timer]['cpu_dt']
        sys_dt  = self.timers[timer]['sys_dt']
        tot_dt  = self.timers[timer]['tot_dt']
        return cpu_dt, sys_dt, tot_dt


    def StopAndGetTotal(self):
        """Stop the timer and return total "delta" values.
        """
        return self.StopAndGet(self.total_key)


    def getsortedtimers(self):
        """Return timers list sorted by timer number.
        """
        lnum = [[timer['num'], timer] for timer in list(self.timers.values()) if timer['hide'] is not True]
        lnum.sort()
        return lnum


    def StopAll(self):
        """Stop all timers
        """
        lk = list(self.timers.keys())
        if self.add_total:
            lk.remove(self.total_key)
        for timer in lk:
            self.Stop(timer)


    def AddComment(self, txt, init=False):
        """Add a comment to the result table.
        """
        sign = sha1(convert(txt).encode()).hexdigest()
        if self._comment_seen.get(sign):
            return
        self._comment_seen[sign] = True
        if init:
            self.comment = ''
        lines = self.comment.splitlines()
        lines.append(txt)
        self.comment = os.linesep.join(["   %s" % line for line in lines])


    def adjust_format(self):
        """Adjust width of title column.
        """
        larg_max = max([0,] + [len(timer['name']) for timer in list(self.timers.values()) \
                             if timer['hide'] is not True])
        new_width = max([self.mintitr, larg_max])
        self.fmtlig = self._fmtlig % { 'adjtitr' : new_width }
        self.fmtstr = self._fmtstr % { 'adjtitr' : new_width }
        self.sepa = self._sepa + '-'*(new_width - self.mintitr)


    def __repr__(self):
        """Pretty print content of the timer.
        NB : call automatically StopAll
        """
        self.StopAll()
        if self.add_total:
            self.Stop(self.total_key)

        self.adjust_format()
        labels = self.fmtstr % self.d_labels
        out = ['']
        # get timers list and sort by 'num'
        lnum = self.getsortedtimers()
        if lnum:
            out.append(self.sepa)
            if self.add_total and labels:
                out.append(labels)
                out.append(self.sepa)
        for num, timer in lnum:
            d_info = timer.copy()
            d_info['cpu_sys'] = d_info['cpu_dt'] + d_info['sys_dt']
            if self.add_total and num == self.MaxNumTimer and len(lnum)>1:
                out.append(self.sepa)
            out.append(self.fmtlig % d_info)
        if lnum:
            out.append(self.sepa)
        if self.comment:
            out.append(self.comment)
        out.append('')
        string = os.linesep.join(out)
        return string

ASTER_TIMER = bwc_deprecate_class('ASTER_TIMER', AsterTimer)
