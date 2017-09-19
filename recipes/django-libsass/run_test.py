import django
from django.conf import settings
settings.configure(INSTALLED_APPS=['django_libsass']) 
django.setup() 
        
import django_libsass
