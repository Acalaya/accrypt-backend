# 🔒 AcCrypt: Data Leak Detection and Prevention App

AcCrypt is a mobile app that helps users **detect sensitive information in text**, **validate emails**, and **analyze email content** for potential data leaks. It combines a user-friendly Flutter frontend with a powerful Flask-based backend running an ML model for text classification.



## 📱 Features

✅ **Login & Registration** — Secure user authentication with hashed passwords  
✅ **Sensitive Text Detection** — Predict if a text contains sensitive data  
✅ **Email Validation** — Check if an email address is valid  
✅ **Top Words Extraction** — Analyze multiple emails to find most frequent words  
✅ **Threshold Tester** — Simulate different model probability thresholds  
✅ **SQLite Database** — Persistent user data storage  
✅ **ML-Powered Backend** — Trained model classifies sensitive vs safe text  
✅ **Modern UI** — Flutter frontend with dark mode and smooth interactions  
✅ **Deployed on Render** — Accessible anywhere



## 🚀 Project Demo

- **Frontend (Flutter) Screens:**
  - Login & Registration
  - Dashboard with features
  - Predict, Email Validation, Top Words, Threshold Tester screens
- **Backend**:
  - Deployed Flask API on Render: [https://accrypt-backend.onrender.com](https://accrypt-backend.onrender.com)
- **Video Demo**: *Coming Soon*



## 🏗️ Tech Stack

- **Frontend:** Flutter, Dart  
- **Backend:** Python, Flask, Flask-CORS  
- **Database:** SQLite3 (via SQLAlchemy)  
- **ML Model:** Scikit-learn (TF-IDF + classifier)  
- **Deployment:** Render for backend API  

---

## 📚 API Endpoints

| Endpoint                | Method | Description                         |
|-------------------------|--------|-------------------------------------|
| `/register`             | POST   | Register a new user                 |
| `/login`                | POST   | Login with username & password      |
| `/predict`              | POST   | Classify input text                 |
| `/validate-email`       | POST   | Validate email address              |
| `/top-words`            | POST   | Extract top words from emails       |
| `/test-threshold`       | POST   | Test custom probability threshold   |
| `/ping`                 | GET    | Check backend health                |

---------------
