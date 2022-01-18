cd frontend
npm install
npm run build -- -c production --output-path ../splore/_static --resources-output-path --deploy-url static/
cd ..

# Copy the 3rd party license file produced by Angular
cp splore/_static/3rdpartylicenses.txt LICENSE-3RD-PARTY

${PYTHON} -m pip install . --no-deps --ignore-installed --no-cache-dir -vvv