@echo on
cd windows
dir
npm install --global --production windows-build-tools
msbuild /m virtuoso-opensource.sln
dir
