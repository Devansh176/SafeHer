# 🛡️ SafeHer - Women's Safety App

**SafeHer** is a mobile application designed to enhance women’s safety with real-time emergency response features, including live location sharing, emergency calls, and intelligent route monitoring.

---

## 📱 Features

- 🚨 One-tap emergency alert system
- 📍 Real-time location tracking
- 📤 Instant location sharing via SMS
- 📞 Emergency call quick-dial
- 👥 Contact selection for calls and location sharing
- 🔐 Secure login with Firebase Authentication
- 🗃️ User and contact data stored in PostgreSQL via Spring Boot
- 📦 Offline support and persistent contact storage

---

## 🧰 Tech Stack

| Layer       | Technology                            |
|-------------|----------------------------------------|
| Frontend    | Flutter (Dart), BLoC pattern           |
| Backend     | Spring Boot (Java), RESTful APIs       |
| Auth        | Firebase Authentication                |
| Database    | PostgreSQL                             |
| DevOps      | Docker (planned), Git, GitHub          |
| Deployment  | Android APK (manual), Firebase Hosting (future) |

---

## 🛠️ Setup Instructions

### 🔧 Backend (Spring Boot)

1. Clone the backend repo:
   ```bash
   git clone https://github.com/your-username/safeher-backend.git
   cd safeher-backend
   ```

2. Configure `application.properties` with:
   - Firebase credentials
   - PostgreSQL connection details

3. Build and run:
   ```bash
   ./mvnw spring-boot:run
   ```

### 📱 Frontend (Flutter)

1. Clone the frontend:
   ```bash
   git clone https://github.com/Devansh176/safeher-app.git
   cd safeher-app
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

---

## 🧪 Testing

- Unit tests are written for BLoC and repository layers.
- Integration tests for emergency features and contact handling.

---

## 📌 Future Enhancements

- Dockerized backend deployment
- Push notifications for alerts
- Smart path learning with unsafe route detection
- Admin dashboard for monitoring
- AI-based unsafe zone prediction using crime data
- Multi-language support

---

## 🤝 Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss your ideas.

---
