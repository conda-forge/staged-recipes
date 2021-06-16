ROOT_DIR=`pwd`

# macOS
if [[ "$OSTYPE" == "darwin"* ]]; then
    cd bindings/cython/
    python3 setup.py build_ext -i
    python3 setup.py sdist bdist_wheel
    cd dist/
    FILENAME=`ls datoviz*.whl`
    echo $FILENAME
    cp $FILENAME "$FILENAME~"
    # broken: remove libvulkan from the wheel?? "-e libvulkan"
    DYLD_LIBRARY_PATH=../../../build/ delocate-wheel $FILENAME -w .
    cd ../../../

# TODO: Windows
elif [[ "$OSTYPE" == "msys" ]]; then
    echo "TODO!"

# manylinux
else

    # Build the docker image.
    sudo docker build -t datoviz_wheel -f Dockerfile_wheel .

    # Clean up the Cython bindings before running the docker container.
    cd bindings/cython && \
    python3 setup.py clean --all && \
    rm -rf build dist datoviz.egg-info datoviz/*.c datoviz/*.so datoviz/__pycache__ && \
    cd ../../

    # Make the wheel and repair it.
    # Build a container based on a manylinux image, + Vulkan and other things needed by the
    # datoviz build script.
    sudo docker run --rm -v $ROOT_DIR:/io datoviz_wheel /io/wheel.sh && \
    USER=`users | awk '{print $1}'`
    sudo chown -R $USER:$USER bindings/cython/dist

fi