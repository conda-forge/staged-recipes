/* Writes plain.h5 (no filter) for h5repack, and checks a round trip through the filter linked as a library. */
#include <math.h>
#include <stdio.h>

#include "H5Z_SZ3.hpp"

#define NX 32
#define NY 64

static float data[NX][NY];
static float back[NX][NY];

static int write_file(const char *name, hid_t dcpl) {
    hsize_t dims[2] = {NX, NY};
    hid_t file = H5Fcreate(name, H5F_ACC_TRUNC, H5P_DEFAULT, H5P_DEFAULT);
    hid_t space = H5Screate_simple(2, dims, NULL);
    hid_t dset = H5Dcreate2(file, "data", H5T_NATIVE_FLOAT, space, H5P_DEFAULT, dcpl, H5P_DEFAULT);
    if (file < 0 || space < 0 || dset < 0) return 1;
    if (H5Dwrite(dset, H5T_NATIVE_FLOAT, H5S_ALL, H5S_ALL, H5P_DEFAULT, data) < 0) return 1;
    H5Dclose(dset);
    H5Sclose(space);
    return H5Fclose(file) < 0;
}

int main(void) {
    for (int i = 0; i < NX; ++i)
        for (int j = 0; j < NY; ++j) data[i][j] = 0.01f * (float)(i * j % 97);

    if (write_file("plain.h5", H5P_DEFAULT)) return 1;

    if (H5Zregister(H5PLget_plugin_info()) < 0) return 1;
    hsize_t chunk[2] = {NX, NY};
    hid_t dcpl = H5Pcreate(H5P_DATASET_CREATE);
    H5Pset_chunk(dcpl, 2, chunk);
    if (H5Pset_sz3(dcpl, H5Z_SZ3_ALGO_INTERP_LORENZO, H5Z_SZ3_EB_ABS, 1e-3, 0, 0, 0) < 0) return 1;
    if (write_file("linked.h5", dcpl)) return 1;
    H5Pclose(dcpl);

    /* Reopened, so the chunk is read through the filter and not HDF5's chunk cache. */
    hid_t file = H5Fopen("linked.h5", H5F_ACC_RDONLY, H5P_DEFAULT);
    hid_t dset = H5Dopen2(file, "data", H5P_DEFAULT);
    if (H5Dread(dset, H5T_NATIVE_FLOAT, H5S_ALL, H5S_ALL, H5P_DEFAULT, back) < 0) return 1;
    hid_t plist = H5Dget_create_plist(dset);
    int has_sz3 = H5Pget_filter_by_id2(plist, H5Z_FILTER_SZ3, NULL, NULL, NULL, 0, NULL, NULL) >= 0;
    H5Pclose(plist);
    H5Dclose(dset);
    H5Fclose(file);

    double max_err = 0;
    for (int i = 0; i < NX; ++i)
        for (int j = 0; j < NY; ++j) {
            double err = (double)data[i][j] - back[i][j];
            if (err < 0) err = -err;
            if (isnan(err) || err > max_err) max_err = err; /* a NaN stays and fails the check */
        }
    printf("H5Z-SZ3 linked: filter applied %d, max error %g\n", has_sz3, max_err);
    return !(has_sz3 && max_err <= 1e-3);
}
