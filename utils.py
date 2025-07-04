import re
from collections import Counter

# Email validation
def is_valid_email(email):
    pattern = r'^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$'
    return re.match(pattern, email) is not None

# Top N frequent words in emails
def get_top_words(email_list, top_n=5):
    words = []
    for email in email_list:
        words.extend(email.lower().split())
    return Counter(words).most_common(top_n)

# Threshold-based spam prediction
def predict_label(prob, threshold=0.5):
    return "spam" if prob >= threshold else "not spam"
