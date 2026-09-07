# 🌾 KrishiSetu — Rider (Logistics Partner) Mobile & Web App
> **Smart India Hackathon (Problem Statement 26033)**  
> Production-grade, offline-first mobile application & interactive frontend for rural commercial drivers operating B2B multi-stop milk-run pickups and drop-offs to mandis and bulk buyers.

---

## 🌟 Architecture & Key Features

### 1. Heterogeneous Fleet Vehicle Routing (HFVRP) & Multi-Stop Dispatch
- Accommodates vehicles from **Micro** (<250 kg: e-rickshaws, auto-carts) to **Large** (10+ Tonnes: heavy commercial reefers).
- Turn-by-turn route plan with sequential milestones connecting farm-gate pickups to cold storage and APMC mandis.
- Interactive map rendering (Leaflet / OpenStreetMap / flutter_map) with vehicle markers, farm-gate pins, and polyline route paths.

### 2. Digital Chain of Custody & Verification
- **Farm-Gate Pickup**: Integrated camera QR code scanning (`mobile_scanner`) validating harvest batch grade, net weight, and farmer identity.
- **Drop-off Point Handover**:
  - **100-Meter Geofence Check**: Automated distance calculation using high-accuracy GPS (`geolocator` & Haversine math).
  - **Unloaded Produce Proof Photo**: Mandatory camera capture (`image_picker`) recording cargo state at the receiving dock.
  - **Buyer 4-Digit OTP Confirmation**: High-contrast 4-box PIN input confirming physical handover.

### 3. Fair Ton-Kilometer Cost Splitting Engine
- Mathematical formula allocating costs without cross-subsidies:
  $$C_i = \text{Total Trip Cost} \times \left(\frac{W_i \times D_i}{\sum_{j=1}^n (W_j \times D_j)}\right)$$
- Instant escrow wallet credit upon delivery confirmation.
- One-tap instant withdrawal to driver's UPI account (`suresh.yadav@upi`).

### 4. Regional Voice Assistance & Accessibility
- Regional Text-to-Speech (TTS) via `flutter_tts` & Web Speech Synthesis API.
- Native scripts & voice prompts in **English**, **हिन्दी (Hindi)**, **मराठी (Marathi)**, **தமிழ் (Tamil)**, **తెలుగు (Telugu)**, and **ಕನ್ನಡ (Kannada)**.
- High-contrast Emerald Green (`#1B5E20`) and Deep Amber (`#FF8F00`) design system tailored for outdoor daylight readability and single-handed thumb operation (56px touch targets).

### 5. Offline-First Resilience & Privacy Compliance
- **SQLite DB (`sqflite`)**: Local caching of trips, waypoints, telemetry pings, and offline request queues during 2G/3G network blackouts.
- **Auto Sync Worker**: Automatically detects internet restoration via `connectivity_plus` and flushes queued requests to the FastAPI backend.
- **Privacy Enforcement**: Real government identification numbers are never rendered or stored in plain digits; masked as `[Aadhaar Redacted]`.

---

## 📁 Project Structure

```
c:/rider/
├── lib/
│   ├── main.dart                                   # Main entry point, orientation lock, Riverpod ProviderScope
│   ├── app.dart                                    # Root MaterialApp.router, AppTheme, locales, sync service
│   ├── core/
│   │   ├── config/app_constants.dart               # API routes, SQLite version, geofence radius, locales
│   │   ├── database/app_database.dart              # SQLite schema (trips, waypoints, telemetry, offline_queue)
│   │   ├── network/
│   │   │   ├── dio_client.dart                     # Dio HTTP client, auth interceptors, retry policy
│   │   │   └── mock_interceptor.dart               # FastAPI mock routes for offline/demo development
│   │   ├── providers/core_providers.dart           # Secure storage, SharedPrefs, DB, Dio providers
│   │   ├── router/app_router.dart                  # GoRouter declarative navigation routes
│   │   ├── services/
│   │   │   ├── sync_service.dart                   # Background offline queue flusher
│   │   │   └── tts_service.dart                    # Regional Text-to-Speech voice assistance
│   │   └── theme/app_theme.dart                    # Emerald Green & Amber palette, Poppins typography
│   └── features/
│       ├── auth/                                   # Language selection, phone OTP, vehicle tier profile
│       ├── trips/                                  # Live home map, offer timer sheet, route plan stepper
│       ├── verification/                           # QR batch scanner, proof photo, geofenced OTP
│       ├── earnings/                               # Escrow wallet, Ton-Km formula split, instant UPI
│       └── profile/                                # Driver profile, vehicle metrics, Aadhaar privacy
├── test/
│   └── widget_test.dart                            # Ton-Km math, Haversine geofence, vehicle tier tests
├── web/
│   └── index.html                                  # Standalone interactive mobile-responsive frontend
├── RIDER_SHOWCASE.html                             # Direct browser launcher for frontend testing
└── pubspec.yaml                                    # Dependencies & Flutter asset definitions
```

---

## 🚀 Running the Application

### Option 1: Run Interactive Mobile Frontend in Any Browser
Double click or open `RIDER_SHOWCASE.html` (or `web/index.html`) in Google Chrome, Microsoft Edge, or on any mobile phone browser:
```bash
start RIDER_SHOWCASE.html
```
- Features full responsive layout matching the mobile app.
- Toggle between **Mobile Smartphone Frame** and **Full Window Responsive Mode**.
- Interactive Leaflet map with route polyline, live TTS voice audio, camera QR scan simulator, Ton-Km interactive math playground, and instant UPI withdrawal animation.

### Option 2: Run Flutter Mobile App (Android / iOS / Desktop)
1. Fetch dependencies:
   ```bash
   flutter pub get
   ```
2. Run unit tests:
   ```bash
   flutter test
   ```
3. Run on connected mobile device or emulator:
   ```bash
   flutter run
   ```
4. Run on Chrome/Edge via Flutter Web:
   ```bash
   flutter run -d chrome
   ```

### Option 3: Run Static Code Analysis
```bash
flutter analyze
```
*(Verified: 0 errors, 0 warnings).*
