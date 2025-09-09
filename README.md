# E-Commerce Flutter App

A simple Flutter e-commerce app with **Spring Boot backend**.  
Supports user login/registration, product browsing, placing orders, and an **admin dashboard** (add product, view orders, low stock).

## 🚀 How to Run

# 1. Clone the repo
git clone https://github.com/jessdardas/mini-ecommerce.git

# 2. Backend (Spring Boot)
cd backend
./mvnw spring-boot:run  # Starts backend at http://localhost:8080(web)
cd ..

# 3. Frontend (Flutter)
flutter pub get

# 4. Copy .env.example → .env and set API base
cp .env
# Inside .env, put:
API_BASE=http://10.0.2.2:8080   (for Android emulator)
API_BASE=http://localhost:8080  (for web/desktop)

# 5. Run the app
flutter run 

# mock credentials for admin:
email: admin@example.com
password: admin123


## 🛠 State Management

* Simple `setState()` + `FutureBuilder`.
* Chosen for **simplicity & clarity** (no heavy frameworks like Provider/Bloc since app scope is small).

---

## 📦 Trade-offs & Assumptions

* **Auth**: JWT stored locally (simple, not production-secure).
* **Time spent**: 40 hrs.
* Focused on **clean API integration** rather than polished UI.

---

## ✅ Features

* User:
  * Register / Login
  * Browse products
  * Place orders
  * View past orders
    
* Admin:
  * Add products
  * View all orders
  * See low stock products

---

Would you like me to also generate the `.env.example` and `.gitignore` files so the repo is **ready-to-clone and run** without touching anything?
```
