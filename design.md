# Design System & UI/UX Guidelines: KrishiSetu Rider App

## 1. Visual Language & Ergonomics
Designed for outdoor daylight visibility, one-handed thumb navigation, and low literacy:
- **Primary Color**: Emerald Green (`#1B5E20`) — Trust, Agriculture, Action.
- **Accent Color**: Deep Amber (`#FF8F00`) — Warnings, In-transit markers.
- **Background**: Pure Off-White (`#F8F9FA`) / High Contrast Card Surfaces (`#FFFFFF`).
- **Surface Danger**: Crimson (`#C62828`) — Route cancellation, SOS.
- **Typography**: Large legible sans-serif (`Poppins` / `Roboto`), min 16sp for body text, 22sp for primary buttons.

## 2. Screen Hierarchy & UI States

### Screen 1: Language Selection & Authentication
- Large rectangular cards for languages with native scripts (हिन्दी, தமிழ், English, etc.).
- Phone number input field + 4-digit OTP card.

### Screen 2: Driver Home & Availability Switch
- Prominent **"Go Online" / "Go Offline"** toggle switch at top.
- Floating "Assigned Run" bottom sheet with pull-up gesture.
- Live Map widget taking 60% of vertical viewport displaying current location pin.

### Screen 3: Route Plan & Multi-Stop Waypoint Sheet
- Sequential milestone stepper (Stop 1: Farm Gate A -> Stop 2: Farm Gate B -> Destination).
- Stop Card shows: Farmer Name, Crop Type, Net Weight (kg), and one-tap "Call Farmer" button.
- Floating "Start Trip" button triggering navigation polyline.

### Screen 4: QR Scanner & Pickup Verification
- Fullscreen camera viewfinder with a high-contrast square reticle.
- Instant haptic feedback and audible beep upon successful QR parse.
- Confirmation overlay: "Batch Verified: 500 kg Tomatoes (Grade A)".

### Screen 5: Geofenced Delivery & OTP Confirmation
- Map status showing "Geofence Check Passed" (Green badge).
- In-app camera preview to snap delivery condition photo.
- Numeric 4-box OTP input pin-field with high contrast border.
- Speaker icon button beside instructions triggering Text-to-Speech in selected language.

### Screen 6: Earnings & Ton-Km Transparent Breakdown
- Large Earnings card: "Trip Payout: ₹3,000".
- Expandable detail sheet displaying individual farmer contributions:
  - Ramesh (500 kg, 20 km): ₹545.45
  - Suresh (1500 kg, 30 km): ₹2,454.55