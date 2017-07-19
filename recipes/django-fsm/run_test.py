import django
from django.conf import settings
settings.configure(INSTALLED_APPS=['django_fsm', 'django.contrib.contenttypes', 'django.contrib.auth']) 
django.setup() 
        
import django_fsm 
import django_fsm.management 
import django_fsm.management.commands
