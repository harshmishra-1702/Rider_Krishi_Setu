### 4. `PHASES.md`
```markdown
# Implementation Phases: KrishiSetu Rider Application

## Phase 1: Foundation, Auth & Profile Setup (Days 1–2)
- Initialize Flutter project with standard folder structure (`core`, `features`, `services`).
- Setup Riverpod state providers and theme system.
- Build Language Selection Screen with internationalization (`flutter_localizations`).
- Implement Phone OTP & Vehicle Tier Selection (`Micro`, `Small`, `Medium`, `Large`).
- Setup local SQLite schema for offline telemetry caching.

## Phase 2: Live Location, Maps & Route Orchestration (Days 3–4)
- Integrate `geolocator` with background tracking permission handling.
- Embed interactive map with custom truck marker and route polyline display.
- Build "New Trip Notification" bottom sheet with accept/reject timer.
- Integrate multi-stop waypoint visualizer showing sequence of farm gates to final hub.
- Connect turn-by-turn route API (OSRM/Mapbox directions).

## Phase 3: Verification Engine (QR Scanner & Geofenced OTP) (Days 5–6)
- Integrate `mobile_scanner` for farm-gate harvest batch verification.
- Implement pickup confirmation dialog updating backend state to `IN_TRANSIT`.
- Build Geofence Validator checking distance between driver coordinates and buyer pin ($\le 100\text{m}$).
- Implement Camera preview module to capture live proof-of-delivery photo.
- Build 4-digit OTP input widget to confirm final handover.

## Phase 4: Earnings Dashboard, TTS & Backend Integration (Days 7–8)
- Implement Ton-Kilometer cost calculation visualizer on completed trips.
- Build Wallet & Earnings Screen with withdrawal history and escrow release badges.
- Add `flutter_tts` speaker buttons to voice-announce stop details in the chosen language.
- Final end-to-end testing with FastAPI backend mock routes.