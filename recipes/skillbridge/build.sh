mkdir -p "${PREFIX}/lib/skill/skillbridge"

# If we add init file it to the project, we may want to copy from there instead
#cp -f "${RECIPE_DIR}/../skillbridge.init.il" \
#       "${PREFIX}/lib/skill/skillbridge/skillbridge.init.il"

cp -f "${RECIPE_DIR}/skillbridge.init.il" \
       "${PREFIX}/lib/skill/skillbridge/skillbridge.init.il"

cp -f "${SRC_DIR}/skillbridge/server/python_server.il" \
       "${PREFIX}/lib/skill/skillbridge/python_server.il"

cp -f "${SRC_DIR}/skillbridge/server/python_server.py" \
       "${PREFIX}/lib/skill/skillbridge/python_server.py"

$PYTHON -m pip install . -vv