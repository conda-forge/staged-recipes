import django
from django.conf import settings
settings.configure(INSTALLED_APPS=['django.contrib.contenttypes', 'django.contrib.auth'],
                   HAYSTACK_CONNECTIONS={'default': {'ENGINE': 'haystack.backends.simple_backend.SimpleEngine'}})
django.setup()

import haystack
