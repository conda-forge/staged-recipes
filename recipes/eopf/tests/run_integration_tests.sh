#!/bin/bash

set -o pipefail

if [[ ! -v TEST_DATA_FOLDER ]]; then
    echo "Do setup TEST_DATA_FOLDER ENV and retry";
    exit 1;
fi


function cleanup {
    echo "Cleaning up";
    (cd $TEST_DATA_FOLDER; ls | egrep "*\.zarr" | xargs -r rm -r;)
    (cd $TEST_DATA_FOLDER; ls | egrep "*\.cog" | xargs -r rm -r;)
    (cd $TEST_DATA_FOLDER; ls | egrep "*\.nc" | xargs -r rm -r;)
    (cd $TEST_DATA_FOLDER; cd tmp; ls | xargs -r rm -r;)
    echo "Finished cleaning up";
}


results_folder=test_results
if [[ ! -d "$results_folder" ]]; then
    mkdir -m 777 $results_folder
fi


run_test() {

    if [ $# -lt 6 ];then
	      echo "run_test product_type source_store target_store need_convert mode pytest_select"
	      echo "need_convert: prerequired conversion"
	      echo "              CONVERT - convert from source to target"
	      echo "              NOCONVERT - no pre-convert before test"
	      echo "              INVCONVERT - convert from target to source"
        echo "              SAFECONVERT - convert from safe to source"
        echo "mode:         Testing mode"
        echo "              COMPARE_L0 - compare two L0s"
        echo "              COMPARE - compare two product"
        echo "              CONVERT_ANY - convert from source to target"
        echo "              CONVERT_SAFE - convert from safe to target"
        echo "              COG - convert from source to cog"
        echo "              SUBSET - extract a subset"
        echo "              EOP_WRITE - write an eop product"
        echo "pytest select:  pytest selection pattern"
        return 1
    fi

    product_type=$1
    source_store=$2
    target_store=$3
    agglomerated="${product_type}_${source_store}_${target_store}"
    if [ "${agglomerated#"$SELECTOR"}" != "${agglomerated}" ] || [ "$SELECTOR" == "ANY" ]; then
      need_convert=$4
      mode=$5
      pytest_select=$6
      verbose_output="${results_folder}/${product_type}_${source_store}_${target_store}"
      verbose_output_pre="${results_folder}/${product_type}_${source_store}_${target_store}_pre"
      if [ -e "${verbose_output}" ];then
          rm ${verbose_output}
      fi
      if [ -e "${verbose_output_pre}" ];then
          rm ${verbose_output_pre}
      fi

      echo "Running test for ${product_type} from ${source_store} to ${target_store}"
      if [ "${need_convert}" == "CONVERT" ]; then
          echo "Converting ${product_type} from ${source_store} to ${target_store}"
          echo "python convert4tests.py ${product_type} ${source_store} ${target_store} | tee ${verbose_output_pre}"
          python convert4tests.py "${product_type}" "${source_store}" "${target_store}" | tee "${verbose_output_pre}"
          ret=$?
          if [ $ret -ne 0 ]; then
            echo "Error while launching : python convert4tests.py ${product_type} ${source_store} ${target_store}" | tee -a "${verbose_output_pre}"
            cleanup
            return 1
          fi
          echo "Done converting"
      fi
      if [ "${need_convert}" == "INVCONVERT" ]; then
          echo "InvConverting ${product_type} from ${target_store} to ${source_store}"
          echo "python convert4tests.py ${product_type} ${target_store} ${source_store} | tee ${verbose_output_pre}"
	  python convert4tests.py "${product_type}" "${target_store}" "${source_store}" | tee "${verbose_output_pre}"
          ret=$?
          if [ $ret -ne 0 ]; then
            echo "Error while launching : python convert4tests.py ${product_type} ${target_store} ${source_store}" | tee -a "${verbose_output_pre}"
            cleanup
            return 1
          fi
          echo "Done back converting"
      fi
      if [ "${need_convert}" == "SAFECONVERT" ]; then
          echo "SafeConverting ${product_type} from safe to ${source_store}"
          echo "python convert4tests.py ${product_type} safe ${source_store} | tee ${verbose_output_pre}"
	  python convert4tests.py "${product_type}" "safe" "${source_store}" | tee "${verbose_output_pre}"
          ret=$?
          if [ $ret -ne 0 ]; then
            echo "Error while launching : python convert4tests.py ${product_type} safe ${source_store}" | tee -a "${verbose_output_pre}"
            cleanup
            return 1
          fi
          echo "Done safe converting"
      fi
      echo "Starting tests"
      if [ "$mode" == "COMPARE_L0" ];then
          python -m pytest -v store/test_safe_store_mappings.py::test_compare_l0_products -k "${pytest_select}" > "${verbose_output}"
      fi
      if [ "$mode" == "COMPARE" ];then
          python -m pytest -v store/test_safe_store_mappings.py::test_compare_products -k "${pytest_select}" > "${verbose_output}"
      fi
      if [ "$mode" == "CONVERT_ANY" ];then
          python -m pytest -v store/test_safe_store_mappings.py::test_convert_any_mapping -k "${pytest_select}" > "${verbose_output}"
      fi
      if [ "$mode" == "CONVERT_SAFE" ];then
          python -m pytest -v store/test_safe_store_mappings.py::test_convert_safe_mapping -k "${pytest_select}" > "${verbose_output}"
      fi
      if [ "$mode" == "COG" ];then
          python -m pytest -v store/test_safe_store_mappings.py::test_cog -k "${pytest_select}" > "${verbose_output}"
      fi
      if [ "$mode" == "SUBSET" ];then
          python -m pytest -v store/test_safe_store_mappings.py::test_subset_of_product -k "${pytest_select}" > "${verbose_output}"
      fi
      if [ "$mode" == "EOP_WRITE" ];then
          python -m pytest -v store/test_safe_store_mappings.py::test_eop_write -k "${pytest_select}" > "${verbose_output}"
      fi

      echo "See verbose output at ${verbose_output}"
      tail -1 "${verbose_output}"
      cleanup
    fi
}


# Prerequisites
if [[ ! -d "$TEST_DATA_FOLDER/tmp" ]]; then
    mkdir -m 777 "$TEST_DATA_FOLDER/tmp" || true
fi

SELECTOR="ANY"

if [ $# -eq 1 ];then
    SELECTOR=$1
fi

echo "SELECTOR : $SELECTOR"

# S1 products
CURRENT="S1"
if [ "${SELECTOR#"$CURRENT"}" != "$SELECTOR" -o "$SELECTOR" == "ANY" ]; then
    echo "Doing $CURRENT"
    ## S1 L0
    SUBCURRENT="S1_L0"
    if [ "${SELECTOR#"$SUBCURRENT"}" != "$SELECTOR" -o "$SELECTOR" == "ANY" -o "$SELECTOR" == "$CURRENT" ]; then
	echo "Doing $SUBCURRENT"

	### S1 L0 IW safe to zarr
	run_test "S1_L0_IW" "safe" "zarr" "CONVERT" "COMPARE_L0" "S1_L0_IW and zarr"

	### S1 L0 EW safe to zarr
	run_test "S1_L0_EW" "safe" "zarr" "CONVERT" "COMPARE_L0" "S1_L0_EW and zarr"

	### S1 L0 EW zarr to safe
	run_test "S1_L0_EW" "zarr" "safe" "INVCONVERT" "CONVERT_ANY" "S1_L0_EW_ZARR"

	### S1 L0 SM safe to zarr
	run_test "S1_L0_SM" "safe" "zarr" "CONVERT" "COMPARE_L0" "S1_L0_SM and zarr"

	### S1 L0 SM zarr to safe
	run_test "S1_L0_SM" "zarr" "safe" "INVCONVERT" "CONVERT_ANY" "S1_L0_SM_ZARR"

	### S1 L0 WV safe to zarr
	run_test "S1_L0_WV" "safe" "zarr" "CONVERT" "COMPARE_L0" "S1_L0_WV and zarr"

	## S1 L0 WV zarr to safe
	run_test "S1_L0_WV" "zarr" "safe" "INVCONVERT" "CONVERT_ANY" "S1_L0_WV_ZARR"
    fi
    ## S1 L1
    SUBCURRENT="S1_L1"
    if [ "${SELECTOR#"$SUBCURRENT"}" != "$SELECTOR" -o "$SELECTOR" == "ANY" -o "$SELECTOR" == "$CURRENT" ]; then
	echo "Doing $SUBCURRENT"

	### S1 L1 GRD safe to zarr
	run_test "S1_L1_GRD" "safe" "zarr" "CONVERT" "COMPARE" "S1_L1_GRD_ZIP"

	### S1 L1 SLC safe to zarr
	run_test "S1_L1_SLC" "safe" "zarr" "CONVERT" "COMPARE" "S1_L1_SLC_ZIP"

	### S1 L1 safe to cog

	#### S1 L1 GRD safe to cog
	run_test "S1_L1_GRD" "safe" "cog" "NOCONVERT" "COG" "EOSafeStore and S1_L1_GRD_ZIP"

	#### S1 L1 GRD zarr to cog
	run_test "S1_L1_GRD" "zarr" "cog" "SAFECONVERT" "COG" "EOSafeStore and S1_L1_GRD_ZARR"

	#### S1 L1 SLC safe to cog
	run_test "S1_L1_SLC" "safe" "cog" "NOCONVERT" "COG" "EOSafeStore and S1_L1_SLC_ZIP"

	#### S1 L1 SLC  zarr to cog
	run_test "S1_L1_SLC" "zarr" "cog" "SAFECONVERT" "COG" "EOZarrStore and S1_L1_SLC_ZARR"

	### S1 L1 zarr to safe
	# TBD pending implementation
    fi
    ## S1 L2
    SUBCURRENT="S1_L2"
    if [ "${SELECTOR#"$SUBCURRENT"}" != "$SELECTOR" -o "$SELECTOR" == "ANY" -o "$SELECTOR" == "$CURRENT" ]; then
	echo "Doing $SUBCURRENT"

	### S1 L2 IW

	#### S1 L2 IW safe to zarr
	run_test "S1_L2_OCN_IW" "safe" "zarr" "NOCONVERT" "CONVERT_SAFE" "S1_IW_OCN_ZIP and zarr"

	#### S1 L2 IW safe to cog
	run_test "S1_L2_OCN_IW" "safe" "cog" "NOCONVERT" "COG" "EOSafeStore and S1_IW_OCN_ZIP"

	#### S1 L2 IW safe to nc
	run_test "S1_L2_OCN_IW" "safe" "nc" "NOCONVERT" "CONVERT_SAFE" "S1_IW_OCN_ZIP and net"

	#### S1 L2 IW zarr to safe
	run_test "S1_L2_OCN_IW" "zarr" "safe" "INVCONVERT" "COMPARE" "S1_IW_OCN_ZIP"


	### S1 L2 SM

	#### S1 L2 safe to zarr
	run_test "S1_L2_OCN_SM" "safe" "zarr" "NOCONVERT" "CONVERT_SAFE" "S1_SM_OCN_ZIP and zarr"

	#### S1 L2 SM safe to cog
	run_test "S1_L2_OCN_SM" "safe" "cog" "NOCONVERT" "COG" "S1_SM_OCN_ZIP"

	#### S1 L2 SM safe to nc
	run_test "S1_L2_OCN_SM" "safe" "nc" "NOCONVERT" "CONVERT_SAFE" "S1_SM_OCN_ZIP"

	#### S1 L2 SM zarr to safe
	run_test "S1_L2_OCN_SM" "zarr" "safe" "INVCONVERT" "COMPARE" "S1_SM_OCN_ZIP"
    fi

fi

# S2 Products
CURRENT="S2"
if [ "${SELECTOR#"$CURRENT"}" != "$SELECTOR" -o "$SELECTOR" == "ANY" ]; then
    echo "Doing $CURRENT"
    ## S2 L0
    SUBCURRENT="S2_L0"
    if [ "${SELECTOR#"$SUBCURRENT"}" != "$SELECTOR" -o "$SELECTOR" == "ANY" -o "$SELECTOR" == "$CURRENT" ]; then
	echo "Doing $SUBCURRENT"

	### S2 L0 safe to zarr
	run_test "S2_L0" "safe" "zarr" "CONVERT" "COMPARE_L0" "S2_L0 and zarr"
    fi
    ## S2 L1C
    SUBCURRENT="S2_L1"
    if [ "${SELECTOR#"$SUBCURRENT"}" != "$SELECTOR" -o "$SELECTOR" == "ANY" -o "$SELECTOR" == "$CURRENT" ]; then
	echo "Doing $SUBCURRENT"

	### S1 L1C safe to zarr
	run_test "S2_L1_C" "safe" "zarr" "NOCONVERT" "CONVERT_SAFE" "S2_MSIL1C_ZIP and zarr"

	### S2 MSIL1C safe to cog
	run_test "S2_L1_C" "safe" "cog" "NOCONVERT" "COG" "S2_MSIL1C_ZIP"

	### S2 MSIL1C safe to nc
	run_test "S2_L1_C" "safe" "nc" "NOCONVERT" "CONVERT_SAFE" "S2_MSIL1C_ZIP and net"

	### S2 MSIL1C zarr to safe
	run_test "S2_L1_C" "zarr" "safe" "INVCONVERT" "SUBSET" "S2_MSIL1C_ZARR"


	## S2 MSIL1C zarr to nc
	run_test "S2_L1_C" "zarr" "nc" "SAFECONVERT" "CONVERT_ANY" "S2_MSIL1C_ZARR and nc"

	## S2 MSIL1C zarr to cog
	run_test "S2_L1_C" "zarr" "cog" "SAFECONVERT" "COG" "EOZarrStore and S2_MSIL1C_ZARR"

	## S2 MSIL1C eop to zarr
	run_test "S2_L1_C" "eop" "zarr" "NOCONVERT" "EOP_WRITE" "S2_MSIL1C_ZIP and zarr"

	## S2 MSIL1C eop to nc
	run_test "S2_L1_C" "eop" "nc" "NOCONVERT" "EOP_WRITE" "S2_MSIL1C_ZIP and nc"
    fi
    ## S2 L2A
    SUBCURRENT="S2_L2"
    if [ "${SELECTOR#"$SUBCURRENT"}" != "$SELECTOR" -o "$SELECTOR" == "ANY" -o "$SELECTOR" == "$CURRENT" ]; then
	echo "Doing $SUBCURRENT"

	### S2 L2A safe to zarr
	run_test "S2_L2_A" "safe" "zarr" "NOCONVERT" "CONVERT_SAFE" "S2_MSIL2A_ZIP and zarr"

	### S2 MSIL2A safe to cog
	run_test "S2_L2_A" "safe" "cog" "NOCONVERT" "COG" "EOSafeStore and S2_MSIL2A_ZIP"




	### S2 MSIL2A safe to nc
	run_test "S2_L2_A" "safe" "nc" "NOCONVERT" "CONVERT_SAFE" "S2_MSIL2A_ZIP and net"

	### S2 MSIL2A zarr to safe
	run_test "S2_L2_A" "zarr" "safe" "INVCONVERT" "SUBSET" "S2_MSIL2A_ZARR"

	## S2 MSIL2A zarr to nc
	run_test "S2_L2_A" "zarr" "nc" "SAFECONVERT" "CONVERT_ANY" "S2_MSIL2A_ZARR and nc"

	## S2 MSIL2A zarr to cog
	run_test "S2_L2_A" "zarr" "cog" "SAFECONVERT" "COG" "EOZarrStore and S2_MSIL2A_ZARR"

	## S2 MSIL2A eop to zarr
	run_test "S2_L2_A" "eop" "zarr" "NOCONVERT" "EOP_WRITE" "S2_MSIL2A_ZIP and zarr"

	## S2 MSIL2A eop to nc
	run_test "S2_L2_A" "eop" "nc" "NOCONVERT" "EOP_WRITE" "S2_MSIL2A_ZIP and nc"
    fi
fi
# S3 Products
CURRENT="S3"
if [ "${SELECTOR#"$CURRENT"}" != "$SELECTOR" -o "$SELECTOR" == "ANY" ]; then
    echo "Doing $CURRENT"
    ## S3 L0
    SUBCURRENT="S3_L0"
    if [ "${SELECTOR#"$SUBCURRENT"}" != "$SELECTOR" -o "$SELECTOR" == "ANY" -o "$SELECTOR" == "$CURRENT" ]; then
	echo "Doing $SUBCURRENT"
	### S3 L0 OL

	#### S3 L0 OL to zarr
	run_test "S3_L0_OL" "safe" "zarr" "CONVERT" "COMPARE_L0" "S3_L0_OL and zarr"

	#### S3 L0 OL zarr to safe
	run_test "S3_L0_OL" "zarr" "safe" "INVCONVERT" "CONVERT_ANY" "S3_OL_0_ZARR"

	### S3 L0 SL

	#### S3 L0 SL to zarr
	run_test "S3_L0_SL" "safe" "zarr" "CONVERT" "COMPARE_L0" "S3_L0_SL and zarr"

	#### S3 L0 SL zarr to safe
	run_test "S3_L0_SL" "zarr" "safe" "INVCONVERT" "CONVERT_ANY" "S3_SL_0_ZARR"

	### S3 L0 MW

	#### S3 L0 MW to zarr
	run_test "S3_L0_MW" "safe" "zarr" "CONVERT" "COMPARE_L0" "S3_L0_MW and zarr"

	#### S3 L0 MW zarr to safe
	run_test "S3_L0_MW" "zarr" "safe" "INVCONVERT" "CONVERT_ANY" "S3_L0_MW_ZARR"

	### S3 L0 SR

	#### S3 L0 SR to zarr
	run_test_compare_l0 "S3_L0_SR" "safe" "zarr" "CONVERT" "COMPARE_L0" "S3_L0_SR and zarr"

	#### S3 L0 SR zarr to safe
	run_test "S3_L0_SR" "zarr" "safe" "INVCONVERT" "CONVERT_ANY" "S3_SR_0_ZARR"
    fi

    ## S3 L1
    SUBCURRENT="S3_L1"
    if [ "${SELECTOR#"$SUBCURRENT"}" != "$SELECTOR" -o "$SELECTOR" == "ANY" -o "$SELECTOR" == "$CURRENT" ]; then
	echo "Doing $SUBCURRENT"

	### S3 L1 OL

	#### S3 L1 OL safe to zarr
	run_test "S3_L1_OL" "safe" "zarr" "NOCONVERT" "CONVERT_SAFE" "S3_OL_1_ZIP and zarr"

	#### S3 L1 OL safe to cog
	run_test "S3_L1_OL" "safe" "cog" "NOCONVERT" "COG" "EOSafeStore and S3_OL_1_ZIP"

	#### S3 L0 OL safe to nc
	run_test "S3_L1_OL" "safe" "nc" "NOCONVERT" "CONVERT_SAFE" "S3_OL_1_ZIP and net"

	#### S3 L1 OL zarr to safe
	run_test "S3_L1_OL" "zarr" "safe" "INVCONVERT" "CONVERT_ANY" "S3_OL_1_ZARR"

	### S3 L1 OL zarr to nc
	run_test "S3_L1_OL" "zarr" "nc" "SAFECONVERT" "CONVERT_ANY" "S3_OL_1_ZARR and nc"

	### S3 L1 OL zarr to cog
	run_test "S3_L1_OL" "zarr" "cog" "SAFECONVERT" "COG" "EOZarrStore and S3_OL_1_ZARR"

	## S3 L1 OL eop to zarr
	run_test "S3_L1_OL" "eop" "zarr" "NOCONVERT" "EOP_WRITE" "S3_OL_1_ZIP and zarr"

	## S3 L1 OL eop to nc
	run_test "S3_L1_OL" "eop" "nc" "NOCONVERT" "EOP_WRITE" "S3_OL_1_ZIP and nc"

	## S3 L1 SL

	### S3 L1 SL safe to zarr
	run_test "S3_L1_SL" "safe" "zarr" "NOCONVERT" "CONVERT_SAFE" "S3_SL_1_RBT_ZIP and zarr"

	### S3 L1 SL safe to cog
	run_test "S3_L1_SL" "safe" "cog" "NOCONVERT" "COG" "EOSafeStore and S3_SL_1_RBT_ZIP"

	### S3 L1 SL safe to nc
	run_test "S3_L1_SL" "safe" "nc" "NOCONVERT" "CONVERT_SAFE" "S3_SL_1_RBT_ZIP and net"

	### S3 L1 SL zarr to safe
	run_test "S3_L1_SL" "zarr" "safe" "INVCONVERT" "CONVERT_ANY" "S3_SL_1_ZARR and EOSafeStore"

	## S3 L1 SL zarr to nc
	run_test "S3_L1_SL" "zarr" "nc" "SAFECONVERT" "CONVERT_ANY" "S3_SL_1_ZARR and nc"

	## S3 L1 SL zarr to cog
	run_test "S3_L1_SL" "zarr" "cog" "SAFECONVERT" "COG" "EOZarrStore and S3_SL_1_ZARR"

	# S3 L1 SL eop to zarr
	run_test "S3_L1_SL" "eop" "zarr" "NOCONVERT" "EOP_WRITE" "S3_SL_1_RBT_ZIP and zarr"

	# S3 L1 SL eop to nc
	run_test "S3_L1_SL" "eop" "nc" "NOCONVERT" "EOP_WRITE" "S3_SL_1_RBT_ZIP and nc"

	### S3 L1 SL zarr to nc
	run_test "S3_L1_SL" "zarr" "nc" "SAFECONVERT" "CONVERT_ANY" "S3_SL_1_ZARR and nc"

	### S3 L1 SL zarr to cog
	run_test "S3_L1_SL" "zarr" "cog" "SAFECONVERT" "COG" "EOZarrStore and S3_SL_1_ZARR"

	## S3 L1 SL eop to zarr
	run_test "S3_L1_SL" "eop" "zarr" "NOCONVERT" "EOP_WRITE" "S3_SL_1_ZIP and zarr"

	## S3 L1 SL eop to nc
	run_test "S3_L1_SL" "eop" "nc" "NOCONVERT" "EOP_WRITE" "S3_SL_1_ZIP and nc"

	### S3 L1 SR

	#### S3 L1 SR safe to zarr
	run_test "S3_L1_SR" "safe" "zarr" "NOCONVERT" "CONVERT_SAFE" "S3_SR_1_SRA_ZIP and zarr"

	#### S3 L1 SR safe to nc
	run_test "S3_L1_SR" "safe" "nc" "NOCONVERT" "CONVERT_SAFE" "S3_SR_1_SRA_ZIP and net"

	#### S3 L1 SR zarr to safe
	run_test "S3_L1_SR" "zarr" "safe" "INVCONVERT" "CONVERT_ANY" "S3_SR_1_ZARR"

	### S3 L1 SR zarr to nc
	run_test "S3_L1_SR" "zarr" "nc" "SAFECONVERT" "CONVERT_ANY" "S3_SR_1_ZARR and nc"
    fi

    ## S3 L2
    SUBCURRENT="S3_L2"
    if [ "${SELECTOR#"$SUBCURRENT"}" != "$SELECTOR" -o "$SELECTOR" == "ANY" -o "$SELECTOR" == "$CURRENT" ]; then
	echo "Doing $SUBCURRENT"

	### S3 L2 OL

	#### S3 L2 OL safe to zarr
	run_test "S3_L2_OL" "safe" "zarr" "NOCONVERT" "CONVERT_SAFE" "S3_OL_2_ZIP and zarr"

	#### S3 L2 OL safe to cog
	run_test "S3_L2_OL" "safe" "cog" "NOCONVERT" "COG" "EOSafeStore and S3_OL_2_ZIP"

	#### S3 L2 OL safe to nc
	run_test "S3_L2_OL" "safe" "nc" "NOCONVERT" "CONVERT_SAFE" "S3_OL_2_ZIP and net"

	#### S3 L2 OL zarr to safe
	run_test "S3_L2_OL" "zarr" "safe" "INVCONVERT" "CONVERT_ANY" "S3_OL_2_ZARR"

	### S3 L2 OL zarr to nc
	run_test "S3_L2_OL" "zarr" "nc" "SAFECONVERT" "CONVERT_ANY" "S3_OL_2_ZARR and nc"

	### S3 L2 OL zarr to cog
	run_test "S3_L2_OL" "zarr" "cog" "SAFECONVERT" "COG" "EOZarrStore and S3_OL_2_ZARR"

	## S3 L2 OL eop to zarr
	run_test "S3_L2_OL" "eop" "zarr" "NOCONVERT" "EOP_WRITE" "S3_OL_2_ZIP and zarr"

	## S3 L1 OL eop to nc
	run_test "S3_L1_OL" "eop" "nc" "NOCONVERT" "EOP_WRITE" "S3_OL_1_ZIP and nc"

	## S3 L2 SL

	### S3 L2 SL safe to zarr
	run_test "S3_L2_SL" "safe" "zarr" "NOCONVERT" "CONVERT_SAFE" "S3_SL_2_LST_ZIP and zarr"

	### S3 L2 SL safe to cog
	run_test "S3_L2_SL" "safe" "cog" "NOCONVERT" "COG" "EOSafeStore and S3_SL_2_LST_ZIP"

	### S3 L2 SL safe to nc
	run_test "S3_L2_SL" "safe" "nc" "NOCONVERT" "CONVERT_SAFE" "S3_SL_2_LST_ZIP and net"

	### S3 L2 SL zarr to safe
	run_test "S3_L2_SL" "zarr" "safe" "INVCONVERT" "CONVERT_ANY" "S3_SL_2_ZARR and EOSafeStore"

	### S3 L2 SL zarr to nc
	run_test "S3_L2_SL" "zarr" "nc" "SAFECONVERT" "CONVERT_ANY" "S3_SL_2_ZARR and nc"

	### S3 L2 SL zarr to cog
	run_test "S3_L2_SL" "zarr" "cog" "SAFECONVERT" "COG" "EOZarrStore and S3_SL_2_ZARR"

	### S3 L2 SL eop to zarr
	run_test "S3_L2_SL" "eop" "zarr" "NOCONVERT" "EOP_WRITE" "S3_SL_2_LST_ZIP and zarr"

	### S3 L2 SL eop to nc
	run_test "S3_L2_SL" "eop" "nc" "NOCONVERT" "EOP_WRITE" "S3_SL_2_LST_ZIP and nc"

	### S3 L2 SR

	#### S3 L2 SR safe to zarr
	run_test "S3_L2_SR" "safe" "zarr" "CONVERT" "COMPARE" "S3_SR_2_LAN_HY_ZIP and zarr"

	#### S3 L2 SR safe to nc
	run_test "S3_L2_SR" "safe" "nc" "CONVERT" "COMPARE" "S3_SR_2_LAN_HY_ZIP and net"

	#### S3 L1 SR zarr to safe
	run_test "S3_L2_SR" "zarr" "safe" "INVCONVERT" "CONVERT_ANY" "S3_SR_2_ZARR"

	### S3 L2 SR zarr to nc
	run_test "S3_L2_SR" "zarr" "nc" "SAFECONVERT" "CONVERT_ANY" "S3_SR_2_ZARR and nc"

	### S3 L2 SY

	#### S3 L2 SY safe to zarr
	run_test "S3_L2_SY" "safe" "zarr" "NOCONVERT" "CONVERT_SAFE" "S3_SY_2_SYN_ZIP and zarr"

	#### S3 L2 SY safe to cog
	run_test "S3_L2_SY" "safe" "cog" "NOCONVERT" "COG" "EOSafeStore and S3_SY_2_SYN_ZIP"

	#### S3 L2 SY safe to nc
	run_test "S3_L2_SY" "safe" "nc" "NOCONVERT" "CONVERT_SAFE" "S3_SY_2_SYN_ZIP and net"

	#### S3 L1 SY zarr to safe
	run_test "S3_L2_SYN" "zarr" "safe" "INVCONVERT" "CONVERT_ANY" "S3_SY_2_ZARR"

	### S3 L2 SY zarr to nc
	run_test "S3_L2_SYN" "zarr" "nc" "SAFECONVERT" "CONVERT_ANY" "S3_SY_2_ZARR and nc"

	### S3 L2 SY zarr to cog
	run_test "S3_L2_SYN" "zarr" "cog" "SAFECONVERT" "COG" "EOZarrStore and S3_SY_2_ZARR"

	## S3 L2 SYN eop to zarr
	run_test "S3_L2_SYN" "eop" "zarr" "NOCONVERT" "EOP_WRITE" "S3_SY_2_SYN_ZIP and zarr"

	## S3 L2 SYN eop to nc
	run_test "S3_L2_SYN" "eop" "nc " "NOCONVERT" "EOP_WRITE" "S3_SY_2_SYN_ZIP and nc"

    fi
fi
