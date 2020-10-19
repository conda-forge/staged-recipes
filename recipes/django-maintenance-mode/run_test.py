import os
from pathlib import Path

import django
from django.conf import settings


with open(Path(__file__).resolve().parent / 'settings.py', 'w') as f:
    f.write('SECRET_KEY="test"')

settings.configure(
    INSTALLED_APPS=['django.contrib.contenttypes', 'django.contrib.auth'])

django.setup()

os.environ['DJANGO_SETTINGS_MODULE'] = 'settings'

import maintenance_mode
