import os
import pandas as pd
from datasets import load_dataset
from sklearn.model_selection import train_test_split
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import classification_report
import joblib

print("✅ Starting training process...")

try:
    print("📦 Trying to load dataset from Hugging Face...")
    dataset = load_dataset("sms_spam", split="train")
    texts = dataset['sms']
    labels = [1 if label == 'spam' else 0 for label in dataset['label']]
except Exception as e:
    print(f"⚠️ Failed to load from Hugging Face: {e}")
    print("📥 Loading dataset from local file instead...")
    df = pd.read_csv("data/sms.tsv", sep='\t', header=None, names=["label", "sms"])
    texts = df["sms"]
    labels = [1 if lbl == "spam" else 0 for lbl in df["label"]]

print(f"🔤 Sample text: {texts[0][:100]}")
print(f"📊 Total samples: {len(texts)}")

X_train, X_test, y_train, y_test = train_test_split(
    texts, labels, test_size=0.2, random_state=42
)

print("📊 Vectorizing text data with TF-IDF...")
vectorizer = TfidfVectorizer(max_features=5000)
X_train_tfidf = vectorizer.fit_transform(X_train)
X_test_tfidf = vectorizer.transform(X_test)

print("🧠 Training Logistic Regression model...")
model = LogisticRegression()
model.fit(X_train_tfidf, y_train)

print("📈 Evaluating model performance...")
y_pred = model.predict(X_test_tfidf)
print("\n📋 Classification Report:\n")
print(classification_report(y_test, y_pred))

print("💾 Saving trained model and vectorizer...")
os.makedirs("model", exist_ok=True)
joblib.dump(model, "model/accrypt_model.pkl")
joblib.dump(vectorizer, "model/accrypt_vectorizer.pkl")

print("✅ Model training and saving complete!")
