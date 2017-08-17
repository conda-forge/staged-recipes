import django
from django.conf import settings
settings.configure(INSTALLED_APPS=['django_coverage_plugin', 'django.contrib.contenttypes', 'django.contrib.auth']) 
django.setup() 
        
import django_coverage_plugin
