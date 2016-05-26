#
# files.py (c) Stuart B. Wilkins 2010
#
# $Id$
# $HeadURL$
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# Part of the "pyspec" package
#

import numpy
import time
import struct


__version__   = "$Revision$"
__author__    = "Stuart B. Wilkins <stuwilkins@mac.com>"
__date__      = "$LastChangedDate$"
__id__        = "$Id$"


def LCLSdataformat(iname, dataFormat = "142500f"):
    """function to read LCLS data.  no headers in this"""
    FH = open(iname, "rb")
    data = numpy.array(struct.unpack(dataFormat, FH.read()))
    FH.close()
    return data

    
class PrincetonSPEFile():
    """Class to read SPE files from Princeton CCD cameras"""

    TEXTCOMMENTMAX = 80
    DATASTART = 4100
    NCOMMENTS = 5
    DATEMAX = 10
    TIMEMAX = 7
    
    def __init__(self, fname = None, fid = None):
        """Initialize class.
        Parameters:
           fname = Filename of SPE file
           fid = File ID of open stream

        This function initializes the class and, if either a filename or fid is
        provided opens the datafile and reads the contents"""
        
        self._fid = None
        self.fname = fname
        if fname is not None:
            self.openFile(fname)
        elif fid is not None:
            self._fid = fid

        if self._fid:
            self.readData()

    def __str__(self):
        """Provide a text representation of the file."""
        s =  "Filename      : %s\n" % self.fname
        s += "Data size     : %d x %d x %d\n" % (self._size[::-1])
        s += "CCD Chip Size : %d x %d\n" % self._chipSize[::-1]
        s += "File date     : %s\n" % time.asctime(self._filedate)
        s += "Exposure Time : %f\n" % self.Exposure
        s += "Num ROI       : %d\n" % self.NumROI
        s += "Num ROI Exp   : %d\n" % self.NumROIExperiment
        s += "Contoller Ver.: %d\n" % self.ControllerVersion
        s += "Logic Output  : %d\n" % self.LogicOutput
        #self.AppHiCapLowNoise = self._readInt(4)
        s += "Timing Mode   : %d\n" % self.TimingMode
        s += "Det. Temp     : %d\n" % self.DetTemperature
        s += "Det. Type     : %d\n" % self.DetectorType
        s += "Trigger Diode : %d\n" % self.TriggerDiode
        s += "Delay Time    : %d\n" % self.DelayTime
        s += "Shutter Cont. : %d\n" % self.ShutterControl
        s += "Absorb Live   : %d\n" % self.AbsorbLive
        s += "Absorb Mode   : %d\n" % self.AbsorbMode
        s += "Virtual Chip  : %d\n" % self.CanDoVirtualChip
        s += "Thresh. Min L : %d\n" % self.ThresholdMinLive
        s += "Thresh. Min   : %d\n" % self.ThresholdMin
        s += "Thresh. Max L : %d\n" % self.ThresholdMaxLive
        s += "Thresh. Max   : %d\n" % self.ThresholdMax
        s += "Geometric Op  : %d\n" % self.GeometricOps
        s += "ADC Offset    : %d\n" % self.ADCOffset
        s += "ADC Rate      : %d\n" % self.ADCRate
        s += "ADC Type      : %d\n" % self.ADCType
        s += "ADC Resol.    : %d\n" % self.ADCRes
        s += "ADC Bit. Adj. : %d\n" % self.ADCBitAdj
        s += "ADC Gain      : %d\n" % self.Gain
        
        i = 0
        for roi in self.allROI:
            s += "ROI %-4d      : %-5d %-5d %-5d %-5d %-5d %-5d\n" % (i,roi[0], roi[1], roi[2],
                                                                  roi[3], roi[4], roi[5])
            i += 1
        
        s += "\nComments :\n"
        i = 0
        for c in self._comments:
            s += "%-3d : " % i
            i += 1
            s += c
            s += "\n"
        return s

    def __getitem__(self, n):
        """Return the array with zdimension n

        This method can be used to quickly obtain a 2-D array of the data"""
        return self._array[n]

    def getData(self):
        """Return the array of data"""
        return self._array

    def getBinnedData(self):
        """Return the binned (sum of all frames) data"""
        return self._array.sum(0)

    def readData(self):
        """Read all the data into the class"""
        self._readHeader()
        self._readSize()
        self._readComments()
        self._readAllROI()
        self._readDate()
        self._readArray()

    def openFile(self, fname):
        """Open a SPE file"""
        self._fname = fname
        self._fid = open(fname, "rb")

    def getSize(self):
        """Return a tuple of the size of the data array"""
        return self._size
    def getChipSize(self):
        """Return a tuple of the size of the CCD chip"""
        return self._chipSize
    def getVirtualChipSize(self):
        """Return the virtual chip size"""
        return self._vChipSize

    def getComment(self, n = None):
        """Return the comments in the data file

        If n is not provided then all the comments are returned as a list of
        string values. If n is provided then the n'th comment is returned"""
        
        if n is None:
            return self._comments
        else:
            return self._comments[n]

    def _readAtNumpy(self, pos, size, ntype):
        if pos is not None:
            self._fid.seek(pos)
        return numpy.fromfile(self._fid, ntype, size)

    def _readAtString(self, pos, size):
        if pos is not None:
            self._fid.seek(pos)
        return self._fid.read(size).rstrip(chr(0))

    def _readInt(self, pos):
        return self._readAtNumpy(pos, 1, numpy.int16)[0]
    
    def _readFloat(self, pos):
        return self._readAtNumpy(pos, 1, numpy.float32)[0]

    def _readHeader(self):
        """This routine contains all other information"""
        self.ControllerVersion = self._readInt(0)
        self.LogicOutput = self._readInt(2)
        self.AppHiCapLowNoise = self._readInt(4)
        self.TimingMode = self._readInt(8)
        self.Exposure = self._readFloat(10)
        self.DetTemperature = self._readFloat(36)
        self.DetectorType = self._readInt(40)
        self.TriggerDiode = self._readInt(44)
        self.DelayTime = self._readFloat(46)
        self.ShutterControl = self._readInt(50)
        self.AbsorbLive = self._readInt(52)
        self.AbsorbMode = self._readInt(54)
        self.CanDoVirtualChip = self._readInt(56)
        self.ThresholdMinLive = self._readInt(58)
        self.ThresholdMin = self._readFloat(60)
        self.ThresholdMaxLive = self._readInt(64)
        self.ThresholdMax = self._readFloat(66)
        self.ADCOffset = self._readInt(188)
        self.ADCRate = self._readInt(190)
        self.ADCType = self._readInt(192)
        self.ADCRes = self._readInt(194)
        self.ADCBitAdj = self._readInt(196)
        self.Gain = self._readInt(198)
        self.GeometricOps = self._readInt(600)

    def _readAllROI(self):
        self.allROI = self._readAtNumpy(1512, 60, numpy.int16).reshape(-1,6)
        self.NumROI = self._readAtNumpy(1510, 1, numpy.int16)[0]
        self.NumROIExperiment = self._readAtNumpy(1488, 1, numpy.int16)[0]
        if self.NumROI == 0:
            self.NumROI = 1
        if self.NumROIExperiment == 0:
            self.NumROIExperiment = 1
    
    def _readDate(self):
        _date = self._readAtString(20, self.DATEMAX)
        _time = self._readAtString(172, self.TIMEMAX)
        self._filedate = time.strptime(_date + _time, "%d%b%Y%H%M%S")
        
    def _readSize(self):
        xdim = self._readAtNumpy(42, 1, numpy.int16)[0]
        ydim = self._readAtNumpy(656, 1, numpy.int16)[0]
        zdim = self._readAtNumpy(1446, 1, numpy.uint32)[0]
        dxdim = self._readAtNumpy(6, 1, numpy.int16)[0]
        dydim = self._readAtNumpy(18, 1, numpy.int16)[0]
        vxdim = self._readAtNumpy(14, 1, numpy.int16)[0]
        vydim = self._readAtNumpy(16, 1, numpy.int16)[0]
        dt = numpy.int16(self._readAtNumpy(108, 1, numpy.int16)[0])
        data_types = (numpy.float32, numpy.int32, numpy.int16, numpy.uint16)
        if (dt > 3) or (dt < 0):
            raise Exception("Unknown data type")
        self._dataType = data_types[dt]
        self._size = (zdim, ydim, xdim)
        self._chipSize = (dydim, dxdim)
        self._vChipSize = (vydim, vxdim)
        
    def _readComments(self):
        self._comments = []
        for n in range(5):
            self._comments.append(
                self._readAtString(200 + (n * self.TEXTCOMMENTMAX), self.TEXTCOMMENTMAX))

    def _readArray(self):
        self._fid.seek(self.DATASTART)
        self._array = numpy.fromfile(self._fid, dtype = self._dataType, count = -1)
        self._array = self._array.reshape(self._size)
