import django
from django.conf import settings
settings.configure(INSTALLED_APPS=['ipware'])
django.setup()