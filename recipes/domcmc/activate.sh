
# make sure that a profile is loaded i.e. you are in ECCC's environment
if [ -z "${ORDENV_SITE_PROFILE+x}" ]; then
	echo "The ORDENV_SITE_PROFILE system variable is not set indicating you are not an ECCC's environment compatible with this package"
    echo "You will need load rpnpy manually"
else
    # In ECCC's environment, these script will load the necessary SSM
    # to allow import rpnpy to work
    #
    # As long as rpnpy is not made available in more standard manner, 
    # this is the only way to load this library
     
    cmds=( '. r.load.dot eccc/mrd/rpn/MIG/ENV/x/rpnpy/2.2.0-rc2 eccc/mrd/rpn/code-tools/ENV/cdt-1.6.6/SCIENCE/inteloneapi-2022.1.2'
           '. r.load.dot /fs/ssm/eccc/cmd/cmdn/pxs2pxt/5.1.3/default')
    for cmd in "${cmds[@]}"; do
        echo 'Running:  '$cmd
        $cmd
        echo ''
    done
fi

