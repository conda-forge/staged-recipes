# Install the "dev" dependencies.
npm install --only=dev

# Configure bower to allow installations as root (as we do in the docker image).
if [ "$(id -u)" == "0" ]; then
    echo '{ "allow_root": true }' > /root/.bowerrc
fi

npm run bower

export PATH="${PATH}:$(pwd)/node_modules/.bin/"
python setup.py install
