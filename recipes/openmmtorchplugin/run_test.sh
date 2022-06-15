cd ${CONDA_PREFIX}/share/openmmtorchplugin/tests
ls -al
set +e
summary=""
exitcode=0
for f in Test*; do
if [[ $f == *Cuda* || $f == *OpenCL* ]]; then
continue
fi
echo "Running $f..."
./${f}
thisexitcode=$?
summary+="\n${f}: "
if [[ $thisexitcode == 0 ]]; then summary+="OK"; else summary+="FAILED"; fi
((exitcode+=$thisexitcode))
done
echo "-------"
echo "Summary"
echo "-------"
echo -e "${summary}"
exit $exitcode
