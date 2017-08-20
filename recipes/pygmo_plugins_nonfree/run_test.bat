start /b ipcluster start

timeout 20

python -c "import pygmo_plugins_nonfree; pygmo_plugins_nonfree.test.run_test_suite()"
