import django
from django.conf import settings
settings.configure(INSTALLED_APPS=['django.contrib.contenttypes', 'django.contrib.auth'],
                   HAYSTACK_CONNECTIONS={'default': {'ENGINE': 'haystack.backends.simple_backend.SimpleEngine'}},
                   PATH="os.path.join(tmp,test_xapian_query)",
                   INCLUDE_SPELLING=True)
django.setup()

import haystack

import xapian_backend
