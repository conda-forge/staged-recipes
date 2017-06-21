import django
from django.conf import settings

settings.configure(INSTALLED_APPS=['material'])
django.setup()

import material
import material.templatetags
import material.theme
import material.theme.amber
import material.theme.bluegrey
import material.theme.cyan
import material.theme.deeppurple
import material.theme.indigo
import material.theme.lightgreen
import material.theme.orange
import material.theme.purple
import material.theme.teal
import material.theme.blue
import material.theme.brown
import material.theme.deeporange
import material.theme.green
import material.theme.lightblue
import material.theme.lime
import material.theme.pink
import material.theme.red
import material.theme.yellow
import material.frontend
import material.frontend.management
import material.frontend.management.commands
import material.frontend.migrations
import material.frontend.templatetags
import material.frontend.views
import material.admin
import material.admin.templatetags
