import sys
import nltk.data

try:
    sent_detector = nltk.data.load("tokenizers/punkt/english.pickle")
    print("NLTK data found")
    sys.exit(0)
except Exception as e:
    print("NLTK data NOT found:")
    print(e)
    sys.exit(1)
