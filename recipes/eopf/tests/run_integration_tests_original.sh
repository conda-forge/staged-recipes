!/bin/bash

function cleanup {
    #echo "Cleaning up";
    (cd $TEST_DATA_FOLDER; ls | egrep "*\.zarr" | xargs -r rm -r;)
    (cd $TEST_DATA_FOLDER; ls | egrep "*\.cog" | xargs -r rm -r;)
    (cd $TEST_DATA_FOLDER; ls | egrep "*\.nc" | xargs -r rm -r;)
    (cd $TEST_DATA_FOLDER; cd tmp; ls | xargs -r rm -r;)
    #echo "Finished cleaning up";
}

# Prerequisites

if [[ ! -v TEST_DATA_FOLDER ]]; then
    echo "Do setup TEST_DATA_FOLDER ENV and retry";
    exit 1;
fi

results_folder=test_results
rm -r $results_folder || true
mkdir -m 777 $results_folder
mkdir -m 777 "$TEST_DATA_FOLDER/tmp" || true


# S1 products

## S1 L0

### S1 L0 IW safe to zarr
product_type=S1_L0_IW
source_store=safe
target_store=zarr
verbose_output="${results_folder}/${product_type}_${target_store}"
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
echo "Running prerequisites for ${product_type}"
python convert4tests.py "${product_type}" "${source_store}" "${target_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_compare_l0_products -k "S1_L0_IW and zarr" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

### S1 L0 IW zarr to safe
product_type=S1_L0_IW
source_store=zarr
target_store=safe
verbose_output="${results_folder}/${product_type}_${target_store}"
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
echo "Running prerequisites for ${product_type}"
python convert4tests.py "${product_type}" "${target_store}" "${source_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_convert_any_mapping -k "S1_L0_IW_ZARR" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

### S1 L0 EW safe to zarr
product_type=S1_L0_EW
source_store=safe
target_store=zarr
verbose_output="${results_folder}/${product_type}_${target_store}"
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
echo "Running prerequisites for ${product_type}"
python convert4tests.py "${product_type}" "${source_store}" "${target_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_compare_l0_products -k "S1_L0_EW and zarr" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

### S1 L0 EW zarr to safe
product_type=S1_L0_EW
source_store=zarr
target_store=safe
verbose_output="${results_folder}/${product_type}_${target_store}"
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
echo "Running prerequisites for ${product_type}"
python convert4tests.py "${product_type}" "${target_store}" "${source_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_convert_any_mapping -k "S1_L0_EW_ZARR" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

### S1 L0 SM safe to zarr
product_type=S1_L0_SM
source_store=safe
target_store=zarr
verbose_output="${results_folder}/${product_type}_${target_store}"
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
echo "Running prerequisites for ${product_type}"
python convert4tests.py "${product_type}" "${source_store}" "${target_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_compare_l0_products -k "S1_L0_SM and zarr" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

### S1 L0 SM zarr to safe
product_type=S1_L0_SM
source_store=zarr
target_store=safe
verbose_output="${results_folder}/${product_type}_${target_store}"
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
echo "Running prerequisites for ${product_type}"
python convert4tests.py "${product_type}" "${target_store}" "${source_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_convert_any_mapping -k "S1_L0_SM_ZARR" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

### S1 L0 WV safe to zarr
product_type=S1_L0_WV
source_store=safe
target_store=zarr
verbose_output="${results_folder}/${product_type}_${target_store}"
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
echo "Running prerequisites for ${product_type}"
python convert4tests.py "${product_type}" "${source_store}" "${target_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_compare_l0_products -k "S1_L0_WV and zarr" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

## S1 L0 WV zarr to safe
product_type=S1_L0_WV
source_store=zarr
target_store=safe
verbose_output="${results_folder}/${product_type}_${target_store}"
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
echo "Running prerequisites for ${product_type}"
python convert4tests.py "${product_type}" "${target_store}" "${source_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_convert_any_mapping -k "S1_L0_WV_ZARR" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup


## S1 L1

### S1 L1 GRD safe to zarr
product_type=S1_L1_GRD
source_store=safe
target_store=zarr
verbose_output="${results_folder}/${product_type}_${target_store}"
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
echo "Running prerequisites for ${product_type}"
python convert4tests.py "${product_type}" "${source_store}" "${target_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_compare_products -k "S1_L1_GRD_ZIP" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup


### S1 L1 SLC safe to zarr
product_type=S1_L1_SLC
source_store=safe
target_store=zarr
verbose_output="${results_folder}/${product_type}_${target_store}"
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
echo "Running prerequisites for ${product_type}"
python convert4tests.py "${product_type}" "${source_store}" "${target_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_compare_products -k "S1_L1_SLC_ZIP" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

### S1 L1 safe to cog

#### S1 L1 GRD safe to cog
product_type=S1_L1_GRD
source_store=safe
target_store=cog
verbose_output="${results_folder}/${product_type}_${target_store}"
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_cog -k "EOSafeStore and S1_L1_GRD_ZIP" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

#### S1 L1 GRD zarr to cog
product_type=S1_L1_GRD
source_store=zarr
target_store=cog
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
echo "Running prerequisites for ${product_type}"
python convert4tests.py "${product_type}" "safe" "${source_store}"
verbose_output="${results_folder}/${product_type}_${source_store}_${target_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_cog -k "EOZarrStore and S1_L1_GRD_ZARR" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

#### S1 L1 SLC safe to cog
product_type=S1_L1_SLC
source_store=safe
target_store=cog
verbose_output="${results_folder}/${product_type}_${target_store}"
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_cog -k "EOSafeStore and S1_L1_SLC_ZIP" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

#### S1 L1 SLC  zarr to cog
product_type=S1_L1_SLC
source_store=zarr
target_store=cog
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
echo "Running prerequisites for ${product_type}"
python convert4tests.py "${product_type}" "safe" "${source_store}"
verbose_output="${results_folder}/${product_type}_${source_store}_${target_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_cog -k "EOZarrStore and S1_L1_SLC_ZARR" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

### S1 L1 zarr to safe
# TBD pending implementation

## S1 L2

### S1 L2 IW

#### S1 L2 IW safe to zarr
product_type=S1_L2_OCN_IW
source_store=safe
target_store=zarr
verbose_output="${results_folder}/${product_type}_${target_store}"
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_convert_safe_mapping -k "S1_IW_OCN_ZIP and zarr" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

#### S1 L2 IW safe to cog
product_type=S1_L2_OCN_IW
source_store=safe
target_store=cog
verbose_output="${results_folder}/${product_type}_${target_store}"
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_cog -k "EOSafeStore and S1_IW_OCN_ZIP" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

#### S1 L2 SM safe to nc
product_type=S1_L2_OCN_IW
source_store=safe
target_store=nc
verbose_output="${results_folder}/${product_type}_${target_store}"
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_convert_safe_mapping -k "S1_IW_OCN_ZIP and net" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

#### S1 L2 IW zarr to safe
product_type=S1_L2_OCN_IW
source_store=zarr
target_store=safe
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
echo "Running prerequisites for ${product_type}"
python convert4tests.py "${product_type}" "${target_store}" "${source_store}"
python convert4tests.py "${product_type}" "${source_store}" "${target_store}"
verbose_output="${results_folder}/${product_type}_${target_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_compare_products -k "S1_IW_OCN_ZIP" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

### S1 L2 SM

#### S1 L2 safe to zarr
product_type=S1_L2_OCN_SM
source_store=safe
target_store=zarr
verbose_output="${results_folder}/${product_type}_${target_store}"
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_convert_safe_mapping -k "S1_SM_OCN_ZIP and zarr" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

#### S1 L2 SM safe to cog
product_type=S1_L2_OCN_SM
source_store=safe
target_store=cog
verbose_output="${results_folder}/${product_type}_${target_store}"
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_cog -k "EOSafeStore and S1_SM_OCN_ZIP" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

#### S1 L2 SM safe to nc
product_type=S1_L2_OCN_SM
source_store=safe
target_store=nc
verbose_output="${results_folder}/${product_type}_${target_store}"
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_convert_safe_mapping -k "S1_SM_OCN_ZIP and net" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

#### S1 L2 SM zarr to safe
product_type=S1_L2_OCN_SM
source_store=zarr
target_store=safe
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
echo "Running prerequisites for ${product_type}"
python convert4tests.py "${product_type}" "${target_store}" "${source_store}"
python convert4tests.py "${product_type}" "${source_store}" "${target_store}"
verbose_output="${results_folder}/${product_type}_${target_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_compare_products -k "S1_SM_OCN_ZIP" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup


# S2 Products

## S2 L0

### S2 L0 safe to zarr
product_type=S2_L0
source_store=safe
target_store=zarr
verbose_output="${results_folder}/${product_type}_${target_store}"
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
echo "Running prerequisites for ${product_type}"
python convert4tests.py "${product_type}" "${source_store}" "${target_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_compare_l0_products -k "S2_L0 and zarr" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

## S2 L1C

### S1 L1C safe to zarr
product_type=S2_L1_C
source_store=safe
target_store=zarr
verbose_output="${results_folder}/${product_type}_${target_store}"
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_convert_safe_mapping -k "S2_MSIL1C_ZIP and zarr" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

### S2 MSIL1C safe to cog
product_type=S2_L1_C
source_store=safe
target_store=cog
verbose_output="${results_folder}/${product_type}_${target_store}"
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_cog -k "EOSafeStore and S2_MSIL1C_ZIP" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

### S2 MSIL1C safe to nc
product_type=S2_L1_C
source_store=safe
target_store=nc
verbose_output="${results_folder}/${product_type}_${target_store}"
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_convert_safe_mapping -k "S2_MSIL1C_ZIP and net" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

### S2 MSIL1C zarr to safe
product_type=S2_L1_C
source_store=zarr
target_store=safe
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
echo "Running prerequisites for ${product_type}"
python convert4tests.py "${product_type}" "${target_store}" "${source_store}"
verbose_output="${results_folder}/${product_type}_${target_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_subset_of_product -k "S2_MSIL1C_ZARR" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

## S2 MSIL1C zarr to nc
product_type=S2_L1_C
source_store=zarr
target_store=nc
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
echo "Running prerequisites for ${product_type}"
python convert4tests.py "${product_type}" "safe" "${source_store}"
verbose_output="${results_folder}/${product_type}_${source_store}_${target_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_convert_any_mapping -k "S2_MSIL1C_ZARR and nc" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

## S2 MSIL1C zarr to cog
product_type=S2_L1_C
source_store=zarr
target_store=cog
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
echo "Running prerequisites for ${product_type}"
python convert4tests.py "${product_type}" "safe" "${source_store}"
verbose_output="${results_folder}/${product_type}_${source_store}_${target_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_cog -k "EOZarrStore and S2_MSIL1C_ZARR" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

## S2 MSIL1C eop to zarr
product_type=S2_L1_C
source_store=eop
target_store=zarr
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
verbose_output="${results_folder}/${product_type}_${source_store}_${target_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_eop_write -k "S2_MSIL1C_ZIP and zarr" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

## S2 MSIL1C eop to nc
product_type=S2_L1_C
source_store=eop
target_store=nc
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
verbose_output="${results_folder}/${product_type}_${source_store}_${target_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_eop_write -k "S2_MSIL1C_ZIP and nc" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

## S2 L2A

### S2 L2A safe to zarr
product_type=S2_L2_A
source_store=safe
target_store=zarr
verbose_output="${results_folder}/${product_type}_${target_store}"
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_convert_safe_mapping -k "S2_MSIL2A_ZIP and zarr" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

### S2 MSIL2A safe to cog
product_type=S2_L2_A
source_store=safe
target_store=cog
verbose_output="${results_folder}/${product_type}_${target_store}"
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_cog -k "EOSafeStore and S2_MSIL2A_ZIP" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

### S2 MSIL2A safe to nc
product_type=S2_L2_A
source_store=safe
target_store=nc
verbose_output="${results_folder}/${product_type}_${target_store}"
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_convert_safe_mapping -k "S2_MSIL2A_ZIP and net" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

### S2 MSIL2A zarr to safe
product_type=S2_L2_A
source_store=zarr
target_store=safe
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
echo "Running prerequisites for ${product_type}"
python convert4tests.py "${product_type}" "${target_store}" "${source_store}"
verbose_output="${results_folder}/${product_type}_${target_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_subset_of_product -k "S2_MSIL2A_ZARR" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

## S2 MSIL2A zarr to nc
product_type=S2_L2_A
source_store=zarr
target_store=nc
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
echo "Running prerequisites for ${product_type}"
python convert4tests.py "${product_type}" "safe" "${source_store}"
verbose_output="${results_folder}/${product_type}_${source_store}_${target_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_convert_any_mapping -k "S2_MSIL2A_ZARR and nc" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

## S2 MSIL2A zarr to cog
product_type=S2_L2_A
source_store=zarr
target_store=cog
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
echo "Running prerequisites for ${product_type}"
python convert4tests.py "${product_type}" "safe" "${source_store}"
verbose_output="${results_folder}/${product_type}_${source_store}_${target_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_cog -k "EOZarrStore and S2_MSIL2A_ZARR" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

## S2 MSIL2A eop to zarr
product_type=S2_L2_A
source_store=eop
target_store=zarr
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
verbose_output="${results_folder}/${product_type}_${source_store}_${target_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_eop_write -k "S2_MSIL2A_ZIP and zarr" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

## S2 MSIL1C eop to nc
product_type=S2_L2_A
source_store=eop
target_store=nc
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
verbose_output="${results_folder}/${product_type}_${source_store}_${target_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_eop_write -k "S2_MSIL2A_ZIP and nc" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup


# S3 Products

## S3 L0

### S3 L0 OL

#### S3 L0 OL to zarr
product_type=S3_L0_OL
source_store=safe
target_store=zarr
verbose_output="${results_folder}/${product_type}_${target_store}"
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
echo "Running prerequisites for ${product_type}"
python convert4tests.py "${product_type}" "${source_store}" "${target_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_compare_l0_products -k "S3_L0_OL and zarr" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

#### S3 L0 OL zarr to safe
product_type=S3_L0_OL
source_store=zarr
target_store=safe
verbose_output="${results_folder}/${product_type}_${target_store}"
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
echo "Running prerequisites for ${product_type}"
python convert4tests.py "${product_type}" "${target_store}" "${source_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_convert_any_mapping -k "S3_OL_0_ZARR" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

### S3 L0 SL

#### S3 L0 SL to zarr
product_type=S3_L0_SL
source_store=safe
target_store=zarr
verbose_output="${results_folder}/${product_type}_${target_store}"
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
echo "Running prerequisites for ${product_type}"
python convert4tests.py "${product_type}" "${source_store}" "${target_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_compare_l0_products -k "S3_L0_SL and zarr" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

#### S3 L0 SL zarr to safe
product_type=S3_L0_SL
source_store=zarr
target_store=safe
verbose_output="${results_folder}/${product_type}_${target_store}"
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
echo "Running prerequisites for ${product_type}"
python convert4tests.py "${product_type}" "${target_store}" "${source_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_convert_any_mapping -k "S3_SL_0_ZARR" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

### S3 L0 MW

#### S3 L0 MW to zarr
product_type=S3_L0_MW
source_store=safe
target_store=zarr
verbose_output="${results_folder}/${product_type}_${target_store}"
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
echo "Running prerequisites for ${product_type}"
python convert4tests.py "${product_type}" "${source_store}" "${target_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_compare_l0_products -k "S3_L0_MW and zarr" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

#### S3 L0 MW zarr to safe
product_type=S3_L0_MW
source_store=zarr
target_store=safe
verbose_output="${results_folder}/${product_type}_${target_store}"
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
echo "Running prerequisites for ${product_type}"
python convert4tests.py "${product_type}" "${target_store}" "${source_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_convert_any_mapping -k "S3_L0_MW_ZARR" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

### S3 L0 SR

#### S3 L0 SR to zarr
product_type=S3_L0_SR
source_store=safe
target_store=zarr
verbose_output="${results_folder}/${product_type}_${target_store}"
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
echo "Running prerequisites for ${product_type}"
python convert4tests.py "${product_type}" "${source_store}" "${target_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_compare_l0_products -k "S3_L0_SR and zarr" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

#### S3 L0 SR zarr to safe
product_type=S3_L0_SR
source_store=zarr
target_store=safe
verbose_output="${results_folder}/${product_type}_${target_store}"
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
echo "Running prerequisites for ${product_type}"
python convert4tests.py "${product_type}" "${target_store}" "${source_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_convert_any_mapping -k "S3_SR_0_ZARR" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

## S3 L1

## S3 L1 OL

#### ERR

#### S3 L1 OL safe to zarr
product_type=S3OLCERR
source_store=safe
target_store=zarr
verbose_output="${results_folder}/${product_type}_${target_store}"
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_convert_safe_mapping -k "S3OLCERR_ZIP and zarr" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

#### S3 L1 OL safe to cog
product_type=S3OLCERR
source_store=safe
target_store=cog
verbose_output="${results_folder}/${product_type}_${target_store}"
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_cog -k "EOSafeStore and S3OLCERR_ZIP" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

#### S3 L0 OL safe to nc
product_type=S3OLCERR
source_store=safe
target_store=nc
verbose_output="${results_folder}/${product_type}_${target_store}"
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_convert_safe_mapping -k "S3OLCERR_ZIP and net" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

#### S3 L1 OL zarr to safe
product_type=S3OLCERR
source_store=zarr
target_store=safe
verbose_output="${results_folder}/${product_type}_${target_store}"
echo "Running test for ${product_type} from ${target_store} to ${source_store}"
echo "Running prerequisites for ${product_type}"
python convert4tests.py "${product_type}" "${target_store}" "${source_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_convert_any_mapping -k "S3OLCERR_ZARR" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

### S3 L1 OL zarr to nc
product_type=S3OLCERR
source_store=zarr
target_store=nc
verbose_output="${results_folder}/${product_type}_${source_store}_${target_store}"
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
echo "Running prerequisites for ${product_type}"
python convert4tests.py "${product_type}" "safe" "${source_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_convert_any_mapping -k "S3OLCERR_ZARR and nc" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

### S3 L1 OL zarr to cog
product_type=S3OLCERR
source_store=zarr
target_store=cog
verbose_output="${results_folder}/${product_type}_${source_store}_${target_store}"
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
echo "Running prerequisites for ${product_type}"
python convert4tests.py "${product_type}" "safe" "${source_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_cog -k "EOZarrStore and S3OLCERR_ZARR" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

## S3 L1 OL eop to zarr
product_type=S3OLCERR
source_store=eop
target_store=zarr
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
verbose_output="${results_folder}/${product_type}_${source_store}_${target_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_eop_write -k "S3OLCERR_ZIP and zarr" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

## S3 L1 OL eop to nc
product_type=S3OLCERR
source_store=eop
target_store=nc
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
verbose_output="${results_folder}/${product_type}_${source_store}_${target_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_eop_write -k "S3OLCERR_ZIP and nc" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

#### EFR

#### S3 L1 OL safe to zarr
product_type=S3_L1_OL
source_store=safe
target_store=zarr
verbose_output="${results_folder}/${product_type}_${target_store}"
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_convert_safe_mapping -k "S3_OL_1_ZIP and zarr" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

#### S3 L1 OL safe to cog
product_type=S3_L1_OL
source_store=safe
target_store=cog
verbose_output="${results_folder}/${product_type}_${target_store}"
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_cog -k "EOSafeStore and S3_OL_1_ZIP" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

#### S3 L0 OL safe to nc
product_type=S3_L1_OL
source_store=safe
target_store=nc
verbose_output="${results_folder}/${product_type}_${target_store}"
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_convert_safe_mapping -k "S3_OL_1_ZIP and net" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

#### S3 L1 OL zarr to safe
product_type=S3_L1_OL
source_store=zarr
target_store=safe
verbose_output="${results_folder}/${product_type}_${target_store}"
echo "Running test for ${product_type} from ${target_store} to ${source_store}"
echo "Running prerequisites for ${product_type}"
python convert4tests.py "${product_type}" "${target_store}" "${source_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_convert_any_mapping -k "S3_OL_1_ZARR" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

### S3 L1 OL zarr to nc
product_type=S3_L1_OL
source_store=zarr
target_store=nc
verbose_output="${results_folder}/${product_type}_${source_store}_${target_store}"
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
echo "Running prerequisites for ${product_type}"
python convert4tests.py "${product_type}" "safe" "${source_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_convert_any_mapping -k "S3_OL_1_ZARR and nc" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

### S3 L1 OL zarr to cog
product_type=S3_L1_OL
source_store=zarr
target_store=cog
verbose_output="${results_folder}/${product_type}_${source_store}_${target_store}"
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
echo "Running prerequisites for ${product_type}"
python convert4tests.py "${product_type}" "safe" "${source_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_cog -k "EOZarrStore and S3_OL_1_ZARR" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

## S3 L1 OL eop to zarr
product_type=S3_L1_OL
source_store=eop
target_store=zarr
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
verbose_output="${results_folder}/${product_type}_${source_store}_${target_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_eop_write -k "S3_OL_1_ZIP and zarr" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

## S3 L1 OL eop to nc
product_type=S3_L1_OL
source_store=eop
target_store=nc
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
verbose_output="${results_folder}/${product_type}_${source_store}_${target_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_eop_write -k "S3_OL_1_ZIP and nc" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

## S3 L1 SL

### S3 L1 SL safe to zarr
product_type=S3_L1_SL
source_store=safe
target_store=zarr
verbose_output="${results_folder}/${product_type}_${target_store}"
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_convert_safe_mapping -k "S3_SL_1_RBT_ZIP and zarr" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

### S3 L1 SL safe to cog
product_type=S3_L1_SL
source_store=safe
target_store=cog
verbose_output="${results_folder}/${product_type}_${target_store}"
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_cog -k "EOSafeStore and S3_SL_1_RBT_ZIP" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

### S3 L1 SL safe to nc
product_type=S3_L1_SL
source_store=safe
target_store=nc
verbose_output="${results_folder}/${product_type}_${target_store}"
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_convert_safe_mapping -k "S3_SL_1_RBT_ZIP and net" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

### S3 L1 SL zarr to safe
product_type=S3_L1_SL
source_store=zarr
target_store=safe
verbose_output="${results_folder}/${product_type}_${target_store}"
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
echo "Running prerequisites for ${product_type}"
python convert4tests.py "${product_type}" "${target_store}" "${source_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_convert_any_mapping -k "S3_SL_1_ZARR and EOSafeStore" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup


## S3 L1 SL zarr to nc
product_type=S3_L1_SL
source_store=zarr
target_store=nc
verbose_output="${results_folder}/${product_type}_${source_store}_${target_store}"
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
echo "Running prerequisites for ${product_type}"
python convert4tests.py "${product_type}" "safe" "${source_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_convert_any_mapping -k "S3_SL_1_ZARR and nc" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

## S3 L1 SL zarr to cog
product_type=S3_L1_SL
source_store=zarr
target_store=cog
verbose_output="${results_folder}/${product_type}_${source_store}_${target_store}"
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
echo "Running prerequisites for ${product_type}"
python convert4tests.py "${product_type}" "safe" "${source_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_cog -k "EOZarrStore and S3_SL_1_ZARR" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

# S3 L1 SL eop to zarr
product_type=S3_L1_SL
source_store=eop
target_store=zarr
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
verbose_output="${results_folder}/${product_type}_${source_store}_${target_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_eop_write -k "S3_SL_1_RBT_ZIP and zarr" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

# S3 L1 SL eop to nc
product_type=S3_L1_SL
source_store=eop
target_store=nc
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
verbose_output="${results_folder}/${product_type}_${source_store}_${target_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_eop_write -k "S3_SL_1_RBT_ZIP and nc" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup


### S3 L1 SL zarr to nc
product_type=S3_L1_SL
source_store=zarr
target_store=nc
verbose_output="${results_folder}/${product_type}_${source_store}_${target_store}"
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
echo "Running prerequisites for ${product_type}"
python convert4tests.py "${product_type}" "safe" "${source_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_convert_any_mapping -k "S3_SL_1_ZARR and nc" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

### S3 L1 SL zarr to cog
product_type=S3_L1_SL
source_store=zarr
target_store=cog
verbose_output="${results_folder}/${product_type}_${source_store}_${target_store}"
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
echo "Running prerequisites for ${product_type}"
python convert4tests.py "${product_type}" "safe" "${source_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_cog -k "EOZarrStore and S3_SL_1_ZARR" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

## S3 L1 SL eop to zarr
product_type=S3_L1_SL
source_store=eop
target_store=zarr
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
verbose_output="${results_folder}/${product_type}_${source_store}_${target_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_eop_write -k "S3_SL_1_ZIP and zarr" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

## S3 L1 SL eop to nc
product_type=S3_L1_SL
source_store=eop
target_store=nc
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
verbose_output="${results_folder}/${product_type}_${source_store}_${target_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_eop_write -k "S3_SL_1_ZIP and nc" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

### S3 L1 SR

#### S3 L1 SR safe to zarr
product_type=S3_L1_SR
source_store=safe
target_store=zarr
verbose_output="${results_folder}/${product_type}_${target_store}"
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_convert_safe_mapping -k "S3_SR_1_SRA_ZIP and zarr" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

#### S3 L1 SR safe to nc
product_type=S3_L1_SR
source_store=safe
target_store=nc
verbose_output="${results_folder}/${product_type}_${target_store}"
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_convert_safe_mapping -k "S3_SR_1_SRA_ZIP and net" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

#### S3 L1 SR zarr to safe
product_type=S3_L1_SR
source_store=zarr
target_store=safe
verbose_output="${results_folder}/${product_type}_${target_store}"
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
echo "Running prerequisites for ${product_type}"
python convert4tests.py "${product_type}" "${target_store}" "${source_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_convert_any_mapping -k "S3_SR_1_ZARR" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"

### S3 L1 SR zarr to nc
product_type=S3_L1_SR
source_store=zarr
target_store=nc
verbose_output="${results_folder}/${product_type}_${source_store}_${target_store}"
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
echo "Running prerequisites for ${product_type}"
python convert4tests.py "${product_type}" "safe" "${source_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_convert_any_mapping -k "S3_SR_1_ZARR and nc" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup


## S3 L2

### S3 L2 OL

#### S3 L2 OL safe to zarr
product_type=S3_L2_OL
source_store=safe
target_store=zarr
verbose_output="${results_folder}/${product_type}_${target_store}"
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_convert_safe_mapping -k "S3_OL_2_ZIP and zarr" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

#### S3 L2 OL safe to cog
product_type=S3_L2_OL
source_store=safe
target_store=cog
verbose_output="${results_folder}/${product_type}_${target_store}"
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_cog -k "EOSafeStore and S3_OL_2_ZIP" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

#### S3 L2 OL safe to nc
product_type=S3_L2_OL
source_store=safe
target_store=nc
verbose_output="${results_folder}/${product_type}_${target_store}"
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_convert_safe_mapping -k "S3_OL_2_ZIP and net" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

#### S3 L2 OL zarr to safe
product_type=S3_L2_OL
source_store=zarr
target_store=safe
verbose_output="${results_folder}/${product_type}_${target_store}"
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
echo "Running prerequisites for ${product_type}"
python convert4tests.py "${product_type}" "${target_store}" "${source_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_convert_any_mapping -k "S3_OL_2_ZARR" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

### S3 L2 OL zarr to nc
product_type=S3_L2_OL
source_store=zarr
target_store=nc
verbose_output="${results_folder}/${product_type}_${source_store}_${target_store}"
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
echo "Running prerequisites for ${product_type}"
python convert4tests.py "${product_type}" "safe" "${source_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_convert_any_mapping -k "S3_OL_2_ZARR and nc" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

### S3 L2 OL zarr to cog
product_type=S3_L2_OL
source_store=zarr
target_store=cog
verbose_output="${results_folder}/${product_type}_${source_store}_${target_store}"
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
echo "Running prerequisites for ${product_type}"
python convert4tests.py "${product_type}" "safe" "${source_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_cog -k "EOZarrStore and S3_OL_2_ZARR" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

## S3 L2 OL eop to zarr
product_type=S3_L2_OL
source_store=eop
target_store=zarr
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
verbose_output="${results_folder}/${product_type}_${source_store}_${target_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_eop_write -k "S3_OL_2_ZIP and zarr" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

## S3 L1 OL eop to nc
product_type=S3_L1_OL
source_store=eop
target_store=nc
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
verbose_output="${results_folder}/${product_type}_${source_store}_${target_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_eop_write -k "S3_OL_1_ZIP and nc" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup


## S3 L2 SL

### S3 L2 SL safe to zarr
product_type=S3SLSFRP
source_store=safe
target_store=zarr
verbose_output="${results_folder}/${product_type}_${target_store}"
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_convert_safe_mapping -k "S3SLSFRP_ZIP and zarr" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

### S3 L2 SL safe to cog
product_type=S3SLSFRP
source_store=safe
target_store=cog
verbose_output="${results_folder}/${product_type}_${target_store}"
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_cog -k "EOSafeStore and S3SLSFRP_ZIP" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

### S3 L2 SL safe to nc
product_type=S3SLSFRP
source_store=safe
target_store=nc
verbose_output="${results_folder}/${product_type}_${target_store}"
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_convert_safe_mapping -k "S3SLSFRP_ZIP and net" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

### S3 L2 SL zarr to safe
product_type=S3SLSFRP
source_store=zarr
target_store=safe
verbose_output="${results_folder}/${product_type}_${target_store}"
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
echo "Running prerequisites for ${product_type}"
python convert4tests.py "${product_type}" "${target_store}" "${source_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_convert_any_mapping -k "S3SLSFRP_ZARR and EOSafeStore" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup


### S3 L2 SL zarr to nc
product_type=S3SLSFRP
source_store=zarr
target_store=nc
verbose_output="${results_folder}/${product_type}_${source_store}_${target_store}"
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
echo "Running prerequisites for ${product_type}"
python convert4tests.py "${product_type}" "safe" "${source_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_convert_any_mapping -k "S3SLSFRP_ZARR and nc" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

### S3 L2 SL zarr to cog
product_type=S3SLSFRP
source_store=zarr
target_store=cog
verbose_output="${results_folder}/${product_type}_${source_store}_${target_store}"
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
echo "Running prerequisites for ${product_type}"
python convert4tests.py "${product_type}" "safe" "${source_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_cog -k "EOZarrStore and S3SLSFRP_ZARR" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

### S3 L2 SL eop to zarr
product_type=S3SLSFRP
source_store=eop
target_store=zarr
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
verbose_output="${results_folder}/${product_type}_${source_store}_${target_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_eop_write -k "S3SLSFRP_ZIP and zarr" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

### S3 L2 SL eop to nc
product_type=S3SLSFRP
source_store=eop
target_store=nc
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
verbose_output="${results_folder}/${product_type}_${source_store}_${target_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_eop_write -k "S3SLSFRP_ZIP and nc" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup


## S3 L2 SL

### S3 L2 SL safe to zarr
product_type=S3_L2_SL
source_store=safe
target_store=zarr
verbose_output="${results_folder}/${product_type}_${target_store}"
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_convert_safe_mapping -k "S3_SL_2_LST_ZIP and zarr" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

### S3 L2 SL safe to cog
product_type=S3_L2_SL
source_store=safe
target_store=cog
verbose_output="${results_folder}/${product_type}_${target_store}"
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_cog -k "EOSafeStore and S3_SL_2_LST_ZIP" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

### S3 L2 SL safe to nc
product_type=S3_L2_SL
source_store=safe
target_store=nc
verbose_output="${results_folder}/${product_type}_${target_store}"
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_convert_safe_mapping -k "S3_SL_2_LST_ZIP and net" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

### S3 L2 SL zarr to safe
product_type=S3_L2_SL
source_store=zarr
target_store=safe
verbose_output="${results_folder}/${product_type}_${target_store}"
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
echo "Running prerequisites for ${product_type}"
python convert4tests.py "${product_type}" "${target_store}" "${source_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_convert_any_mapping -k "S3_SL_2_ZARR and EOSafeStore" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup


### S3 L2 SL zarr to nc
product_type=S3_L2_SL
source_store=zarr
target_store=nc
verbose_output="${results_folder}/${product_type}_${source_store}_${target_store}"
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
echo "Running prerequisites for ${product_type}"
python convert4tests.py "${product_type}" "safe" "${source_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_convert_any_mapping -k "S3_SL_2_ZARR and nc" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

### S3 L2 SL zarr to cog
product_type=S3_L2_SL
source_store=zarr
target_store=cog
verbose_output="${results_folder}/${product_type}_${source_store}_${target_store}"
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
echo "Running prerequisites for ${product_type}"
python convert4tests.py "${product_type}" "safe" "${source_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_cog -k "EOZarrStore and S3_SL_2_ZARR" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

### S3 L2 SL eop to zarr
product_type=S3_L2_SL
source_store=eop
target_store=zarr
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
verbose_output="${results_folder}/${product_type}_${source_store}_${target_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_eop_write -k "S3_SL_2_LST_ZIP and zarr" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

### S3 L2 SL eop to nc
product_type=S3_L2_SL
source_store=eop
target_store=nc
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
verbose_output="${results_folder}/${product_type}_${source_store}_${target_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_eop_write -k "S3_SL_2_LST_ZIP and nc" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup


### S3 L2 SR

#### S3 L2 SR safe to zarr
product_type=S3_L2_SR
source_store=safe
target_store=zarr
verbose_output="${results_folder}/${product_type}_${target_store}"
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
echo "Running prerequisites for ${product_type}"
python convert4tests.py "${product_type}" "${source_store}" "${target_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_compare_products -k "S3_SR_2_LAN_HY_ZIP and zarr" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

#### S3 L2 SR safe to nc
product_type=S3_L2_SR
source_store=safe
target_store=nc
verbose_output="${results_folder}/${product_type}_${target_store}"
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
echo "Running prerequisites for ${product_type}"
python convert4tests.py "${product_type}" "${source_store}" "${target_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_compare_products -k "S3_SR_2_LAN_HY_ZIP and net" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

#### S3 L1 SR zarr to safe
product_type=S3_L2_SR
source_store=zarr
target_store=safe
verbose_output="${results_folder}/${product_type}_${target_store}"
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
echo "Running prerequisites for ${product_type}"
python convert4tests.py "${product_type}" "${target_store}" "${source_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_convert_any_mapping -k "S3_SR_2_ZARR" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"


### S3 L2 SR zarr to nc
product_type=S3_L2_SR
source_store=zarr
target_store=nc
verbose_output="${results_folder}/${product_type}_${source_store}_${target_store}"
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
echo "Running prerequisites for ${product_type}"
python convert4tests.py "${product_type}" "safe" "${source_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_convert_any_mapping -k "S3_SR_2_ZARR and nc" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

### S3 L2 SY

#### S3 L2 SY safe to zarr
product_type=S3_L2_SY
source_store=safe
target_store=zarr
verbose_output="${results_folder}/${product_type}_${target_store}"
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_convert_safe_mapping -k "S3_SY_2_SYN_ZIP and zarr" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

#### S3 L2 SY safe to cog
product_type=S3_L2_SY
source_store=safe
target_store=cog
verbose_output="${results_folder}/${product_type}_${target_store}"
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_cog -k "EOSafeStore and S3_SY_2_SYN_ZIP" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

#### S3 L2 SY safe to nc
product_type=S3_L2_SY
source_store=safe
target_store=nc
verbose_output="${results_folder}/${product_type}_${target_store}"
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_convert_safe_mapping -k "S3_SY_2_SYN_ZIP and net" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

#### S3 L1 SY zarr to safe
product_type=S3_L2_SYN
source_store=zarr
target_store=safe
verbose_output="${results_folder}/${product_type}_${target_store}"
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
echo "Running prerequisites for ${product_type}"
python convert4tests.py "${product_type}" "${target_store}" "${source_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_convert_any_mapping -k "S3_SY_2_ZARR" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

### S3 L2 SY zarr to nc
product_type=S3_L2_SYN
source_store=zarr
target_store=nc
verbose_output="${results_folder}/${product_type}_${source_store}_${target_store}"
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
echo "Running prerequisites for ${product_type}"
python convert4tests.py "${product_type}" "safe" "${source_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_convert_any_mapping -k "S3_SY_2_ZARR and nc" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

### S3 L2 SY zarr to cog
product_type=S3_L2_SYN
source_store=zarr
target_store=cog
verbose_output="${results_folder}/${product_type}_${source_store}_${target_store}"
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
echo "Running prerequisites for ${product_type}"
python convert4tests.py "${product_type}" "safe" "${source_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_cog -k "EOZarrStore and S3_SY_2_ZARR" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

## S3 L2 SYN eop to zarr
product_type=S3_L2_SYN
source_store=eop
target_store=zarr
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
verbose_output="${results_folder}/${product_type}_${source_store}_${target_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_eop_write -k "S3_SY_2_SYN_ZIP and zarr" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup

## S3 L2 SYN eop to nc
product_type=S3_L2_SYN
source_store=eop
target_store=nc
echo "Running test for ${product_type} from ${source_store} to ${target_store}"
verbose_output="${results_folder}/${product_type}_${source_store}_${target_store}"
python -m pytest -v store/test_safe_store_mappings.py::test_eop_write -k "S3_SY_2_SYN_ZIP and nc" > "${verbose_output}"
echo "See verbose output at ${verbose_output}"
tail -1 "${verbose_output}"
cleanup
