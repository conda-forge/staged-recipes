#!/bin/bash
echo "Add SKILL library"
mkdir -p "${PREFIX}/lib/skill/softworks"
cp -rf "softworks" \
       "${PREFIX}/lib/skill/"

echo "Create or append to the SKILL environment data.reg"
{ \
echo "SOFTINCLUDE ${PREFIX}/lib/skill/Softworks/src/python/SdmPy.data.reg;"; \
echo "SOFTINCLUDE ${PREFIX}/lib/skill/Softworks/src/skill/SdmSkill.data.reg;"; \
echo "SOFTINCLUDE ${PREFIX}/lib/skill/Softworks/src/pptx/SdmPptx.data.reg;"; \
echo "SOFTINCLUDE ${PREFIX}/lib/skill/Softworks/src/xlsx/SdmXlsx.data.reg;"; \
echo "SOFTINCLUDE ${PREFIX}/lib/skill/Softworks/src/pdf/SdmPdf.data.reg;"; \
echo "SOFTINCLUDE ${PREFIX}/lib/skill/Softworks/src/html/SdmHtml.data.reg;"; \
} >> "${PREFIX}/lib/skill/data.reg"

echo ''
echo 'Build Python Package:'
echo 'flit build --format wheel'
flit build --format wheel
echo 'python -m pip install --no-deps dist/*.whl -vv'
python -m pip install --no-deps dist/*.whl -vv
