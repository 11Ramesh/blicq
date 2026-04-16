# 📱 Beacon Alert Mobile App

## 📌 Overview
This mobile application allows users to detect nearby Bluetooth beacons and receive alerts when they are within a specific distance. The app ensures proper connectivity setup before accessing the main features.

---

## 🚀 Features

### 🔐 Authentication
- Users can log in using:
  - Google (Gmail)
  - Apple ID  
- Secure and simple login process

---

### ⚙️ Setup & Permissions
After login, users must complete a setup process:
- Enable Internet Connectivity
- Enable Bluetooth Access

⚠️ Both permissions are required to continue.  
If permissions are granted, the user is navigated to the Home Page.

---

### 📡 Home Page (Beacon Detection)
- Displays all nearby Bluetooth beacons
- Shows:
  - Beacon name / ID
  - Distance from the user
- Real-time scanning of beacons

✅ Smart Alert System:
- When a beacon is detected within 5 meters, the app triggers an alert notification

---

### 🔔 Alerts Page
- Displays history of all alerts triggered
- Helps users track nearby beacon interactions

---

### 👤 Profile Page
- Shows user information:
  - Name
  - Email (from login)
- Includes:
  - Sign Out option

---

## 🛠️ Tech Stack
- Flutter (Mobile App Development)
- Bluetooth (Beacon Detection)
- Firebase Authentication (Google & Apple login)

---

## 📱 App Flow
1. User opens the app
2. Login using Google or Apple
3. Complete setup (Internet + Bluetooth permissions)
4. Access Home Page
5. View nearby beacons
6. Receive alert when beacon is within 5 meters
7. View alerts history
8. Manage profile and sign out

---

## ⚠️ Requirements
- Bluetooth must be enabled
- Internet connection required
- Location permissions (for beacon detection)

---

## 📌 Future Improvements
- Push notifications for alerts
- Background beacon scanning
- Map view for beacon locations
- Custom alert distance settings