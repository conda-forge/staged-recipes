# echo "Test Infomap availability"
# Infomap -h
# echo "== OK =="
# echo "Test topicmap availability"
# topicmap
# echo "== OK =="
# echo "Test topicmap functionality"
topicmap -f quantum-and-granular-large-stemmed -t 10 -o testresults
ls testresults
# echo "== OK =="
