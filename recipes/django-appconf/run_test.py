import django
from django.conf import settings
settings.configure(INSTALLED_APPS=['appconf', 'django.contrib.contenttypes', 'django.contrib.auth']) 
django.setup()

import appconf
