import django
from django.conf import settings
settings.configure(INSTALLED_APPS=['allauth', 'django.contrib.contenttypes', 'django.contrib.auth']) 
django.setup() 
        
