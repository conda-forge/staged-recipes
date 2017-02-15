import os
import pytest
import spacy

PACKAGE_DIR = os.path.abspath(os.path.dirname((spacy.__file__)))
pytest.main([PACKAGE_DIR])
