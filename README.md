# 🛡️ SafeHer - Women's Safety App

**SafeHer** is a mobile application designed to enhance women’s safety with real-time emergency features like live location sharing, intelligent routing, emergency calls, and an in-app chatbot assistant.

---

## 📱 Features

- 🚨 One-tap emergency alert system (sound + SMS)
- 📍 Real-time location tracking and Google Maps integration
- 📤 Instant location sharing via SMS (with selected contacts)
- 📞 Emergency call quick-dial with predefined safety numbers
- 👥 Contact selection and persistence for emergency sharing
- 🔐 Secure login using Firebase Authentication
- 🗃️ PostgreSQL database integration via Spring Boot
- 🤖 Smart in-app ChatBot for:
  - 📌 Natural language queries (e.g., “Safest route from A to B”)
  - 🧭 Directions with low crime and traffic
  - 💡 Feature discovery and app usage help
- 🧠 Safe route calculation using Geoapify + crime & traffic intelligence
- 🧾 Offline contact persistence using SharedPreferences
- 🧼 Clean BLoC-based architecture
- 🌐 Modular microservice-ready backend

---

## 🧰 Tech Stack

| Layer       | Technology                            |
|-------------|----------------------------------------|
| Frontend    | Flutter (Dart), BLoC pattern           |
| Backend     | Spring Boot (Java), RESTful APIs       |
| Auth        | Firebase Authentication                |
| Database    | PostgreSQL                             |
| AI / NLP    | Spring Boot + OpenAI (via REST)        |
| Routing     | Geoapify API for safe path directions  |
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

2. Configure `application.properties`:
   ```properties
   spring.datasource.url=jdbc:postgresql://localhost:5432/safeher
   spring.datasource.username=youruser
   spring.datasource.password=yourpass
   firebase.service.account.path=classpath:/firebase-service.json
   geoapify.api.key=your_api_key
   ```

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

## 💬 ChatBot Queries Supported

| Example User Input                            | ChatBot Behavior                      |
|----------------------------------------------|----------------------------------------|
| `"What is the safest route from A to B?"`    | Uses backend to fetch crime-safe route |
| `"Call police"`                               | Guides user to quick-dial options      |
| `"How to use emergency alert?"`               | Explains alert features in-app         |
| `"Share my location"`                         | Triggers location sharing logic        |

---

## 🧪 Testing

- ✅ Unit tests for BLoC state transitions and repository logic
- ✅ Integration tests for emergency triggers, location persistence
- ✅ Manual tests for chatbot and route controller APIs

---

## 📌 Future Enhancements

- ✅ AI-based unsafe route prediction (ongoing)
- 🚧 Dockerized backend with CI/CD
- 🚧 Admin dashboard for reporting and insights
- 🚧 Multi-language support
- 🚧 Push notifications and fall detection
- 🚧 SOS gestures (shake, long press)

---

## 🤝 Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss your ideas.

---

## © 2025 Devansh Dhopte

Built with ❤️ for a safer tomorrow.
