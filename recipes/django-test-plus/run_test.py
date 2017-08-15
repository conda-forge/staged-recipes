import django
from django.conf import settings
settings.configure(INSTALLED_APPS=['django.contrib.contenttypes', 'django.contrib.auth']) 
django.setup() 
        
import test_plus
