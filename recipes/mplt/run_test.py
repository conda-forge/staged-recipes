"""
Test that mplt can be imported
"""
# use the Agg backend for matplotlib to ensure that this test passes even when no display is available
import matplotlib
matplotlib.use('Agg')
import mplt
