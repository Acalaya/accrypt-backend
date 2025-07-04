print("--- Script execution started ---")

from flask import Flask, request, jsonify
from werkzeug.security import generate_password_hash, check_password_hash
import joblib
from utils import is_valid_email, get_top_words, predict_label

app = Flask(__name__)

# ✅ Load the trained ML model and vectorizer
try:
    model = joblib.load("model/accrypt_model.pkl")
    vectorizer = joblib.load("model/accrypt_vectorizer.pkl")
    print("✅ Model and vectorizer loaded successfully.")
except Exception as e:
    print(f"❌ Failed to load model/vectorizer: {e}")
    model = None
    vectorizer = None

# ✅ Simulated in-memory user database
users_db = {
    "accryptuser": {
        "email": "test@example.com",
        "password_hash": generate_password_hash("@ccrypt12")
    }
}

# ✅ Registration route
@app.route('/register', methods=['POST'])
def register():
    data = request.json
    username = data.get('username')
    password = data.get('password')
    email = data.get('email')

    if not username or not password or not email:
        return jsonify({"message": "Missing username, password, or email"}), 400

    if username in users_db:
        return jsonify({"message": "User already exists"}), 409

    hashed_password = generate_password_hash(password)
    users_db[username] = {
        "email": email,
        "password_hash": hashed_password
    }

    print(f"✅ Registered user: {username}")
    return jsonify({"message": "User registered successfully"}), 201

# ✅ Login route
@app.route('/login', methods=['POST'])
def login():
    data = request.json
    username = data.get('username')
    password = data.get('password')

    if not username or not password:
        return jsonify({"message": "Missing username or password"}), 400

    user = users_db.get(username)
    if not user or not check_password_hash(user['password_hash'], password):
        return jsonify({"message": "Invalid username or password"}), 401

    return jsonify({"message": "Login successful!"}), 200

# ✅ Prediction helper
def predict_text(text):
    if not model or not vectorizer:
        return "Model not loaded"

    text_tfidf = vectorizer.transform([text])
    prediction = model.predict(text_tfidf)[0]
    return "Sensitive" if prediction == 1 else "Safe"

# ✅ Predict route
@app.route('/predict', methods=['POST'])
def predict():
    data = request.json
    text = data.get("text", "")

    if not text:
        return jsonify({"error": "No text provided"}), 400

    prediction = predict_text(text)
    return jsonify({"prediction": prediction})

# ✅ Validate email
@app.route('/validate-email', methods=['POST'])
def validate_email():
    data = request.json
    email = data.get("email")
    if not email:
        return jsonify({"error": "Email field missing"}), 400
    valid = is_valid_email(email)
    return jsonify({"email": email, "valid": valid})

# ✅ Top words
@app.route('/top-words', methods=['POST'])
def top_words():
    data = request.json
    emails = data.get("emails", [])
    if not emails or not isinstance(emails, list):
        return jsonify({"error": "List of emails required"}), 400
    top = get_top_words(emails)
    return jsonify({"top_words": top})

# ✅ Threshold test
@app.route('/test-threshold', methods=['POST'])
def test_threshold():
    data = request.json
    probs = data.get("probs", [])
    threshold = data.get("threshold", 0.5)
    if not isinstance(probs, list):
        return jsonify({"error": "List of probabilities required"}), 400
    labels = [predict_label(p, threshold) for p in probs]
    return jsonify({"threshold": threshold, "labels": labels})

# ✅ Run app
if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)




