import django
from django.conf import settings
settings.configure(INSTALLED_APPS=['guardian']) 
django.setup() 
        
import guardian
import guardian.conf
import guardian.management
import guardian.migrations
import guardian.templatetags
import guardian.testapp
import guardian.management.commands
import guardian.testapp.migrations
import guardian.testapp.tests





