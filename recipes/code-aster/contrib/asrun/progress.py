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
    Definition of the Progress class.
"""

import sys
import os


class Progress:
    """This class allows to easily follow the progress of a task.
    """
    def __init__(self, **kargs):
        """Initialization
        """
        self.msg   = kargs.get('msg', '')
        self.value = kargs.get('value', 0)
        self.maxi  = kargs.get('maxi', 100)
        if self.maxi == 0:
            self.maxi = 1
        self.form  = kargs.get('format', '%3d%%')
        self.file  = sys.stdout
        self.time  = kargs.get('time', True)

        self._write(self.msg)
        self._write(self.form % 0, update=True)
        # man 2 times
        st = os.times()
        self.utime = st[0]
        self.stime = st[1]
        self.elapsed = st[4]


    def _write(self, txt, update=False):
        """Print progress if in a terminal.
        """
        if hasattr(self.file, "isatty") and self.file.isatty():
            self.file.write(txt)
            self.file.flush()
        elif not update:
            self.file.write(txt.replace(chr(8), ''))


    def Update(self, value):
        """Set the progress indicator to 'value' and print it.
        """
        self.value = value
        percent = 100.*self.value/self.maxi
        s = self.form % percent
        self._write(len(self.msg+s)*chr(8) + self.msg + s, update=True)


    def End(self, string='100%\n'):
        """Write the end message.
        """
        st = os.times()
        self.utime = st[0] - self.utime
        self.stime = st[1] - self.stime
        self.elapsed = st[4] -  self.elapsed
        st = ''
        if self.time:
            st = ' (%.2f s user, %.2f s total)' % (self.utime, self.elapsed)
        val = 100
        if type(string) in (int, int):
            val = string
            string = "100%\n"
        if string[:4] == '100%':
            string = (self.form % val) + string[4:]
        if string[-1] == '\n':
            string = string[:-1] + st + string[-1]
        s = self.form % 0
        fin = len(self.msg+s)*chr(8) + self.msg
        self._write(fin, update=True)
        if string != '':
            self._write(string)


# exemple
if __name__ == '__main__':
    maxi = 25.
    p = Progress(maxi=maxi, format='%5.1f %%', msg='Iterations... ')
    nb = 1000
    for i in range(nb):
#      print (i+1)*maxi/nb
        p.Update((i+1)*maxi/nb)
        for j in range(1000):
            x = 2.**0.5
#   p.End('Completed\n')
    p.End()
