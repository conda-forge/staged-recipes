start /b ipcluster start

timeout 20

python -c "import pygmo; pygmo.test.run_test_suite()"
