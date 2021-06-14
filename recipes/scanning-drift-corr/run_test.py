import numpy as np
import scanning_drift_corr.api as sdc

if __name__ == '__main__':
    scanAngles = (10, 100)

    n = 9
    im1 = np.ones((n,n))
    im2 = np.ones((n,n))
    im1[4,6] = 10
    im1[2,3] = 10
    im2[5,2] = 10
    im2[2,4] = 10

    sm = sdc.SPmerge01linear(scanAngles, im1, im2)
    sm = sdc.SPmerge02(sm, 8, 8)
    imageFinal, signalArray, densityArray = sdc.SPmerge03(sm)

