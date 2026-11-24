#!/usr/bin/env bash
set -euxo pipefail

for tool in \
    check_mask combine-ncc decompress-ncc fregrid is-compressed \
    make_coupler_mosaic make_hgrid make_land_domain make_quick_mosaic \
    make_regional_mosaic make_remap_file make_solo_mosaic make_topog \
    make_vgrid mppnccombine mppncscatter ncexists remap_land river_regrid \
    runoff_regrid scatter-ncc transfer_to_mosaic_grid \
    combine_restarts iceberg_comb.sh list_ncvars.sh list_ncvars.csh \
    plevel.sh split_ncvars.pl timavg timavg.csh make_simple_hydrog.csh; do
    test -x "${PREFIX}/bin/${tool}"
done

ncgen -o sample.nc <<'EOF'
netcdf sample {
dimensions:
    x = 2 ;
variables:
    float temperature(x) ;
data:
    temperature = 280, 281 ;
}
EOF

test "$(ncexists -f sample.nc -v temperature)" -eq 1
test "$(ncexists -f sample.nc -v missing)" -eq 0

# Exercise the shell wrapper and its installed Fortran helper.
test "$(list_ncvars.sh -s -1 sample.nc | tr -d '[:space:]')" = temperature
test "$(list_ncvars.csh -s -1 sample.nc | tr -d '[:space:]')" = temperature
split_ncvars.pl --help

make_hgrid --grid_type gnomonic_ed --nlon 8 --grid_name test_grid
for tile in 1 2 3 4 5 6; do
    test -s "test_grid.tile${tile}.nc"
    test "$(ncexists -f "test_grid.tile${tile}.nc" -v x)" -eq 1
    test "$(ncexists -f "test_grid.tile${tile}.nc" -v area)" -eq 1
done
