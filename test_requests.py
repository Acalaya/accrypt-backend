import requests

# Validate email
res = requests.post("http://localhost:5000/validate-email", json={"email": "queen@example.com"})
print("✅ Email Valid Test:", res.json())

# Top words
emails = ["Win now!", "Click to win", "Free cash now"]
res = requests.post("http://localhost:5000/top-words", json={"emails": emails})
print("✅ Top Words Test:", res.json())

# Test threshold
res = requests.post("http://localhost:5000/test-threshold", json={"probs": [0.2, 0.7, 0.9], "threshold": 0.6})
print("✅ Threshold Test:", res.json())
