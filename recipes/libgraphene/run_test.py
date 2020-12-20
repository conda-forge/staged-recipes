import gi
gi.require_version('Graphene', '1.0')
from gi.repository import Graphene
import sys

if Graphene.Box.empty() is None:
    sys.exit(1)
