@echo off

cd frontend
npm install
npm run build -- -c production --output-path %CD%.\splore\_static --resources-output-path --deploy-url static\
cd %CD%.
COPY  splore\_static\3rdpartylicenses.txt LICENSE-3RD-PARTY
${PYTHON} -m pip install %CD% --no-deps --ignore-installed --no-cache-dir -vvv
Converted Windows Batch