# Technical Architecture: KrishiSetu Rider Application

## 1. System Topology
The Rider app communicates with the KrishiSetu FastAPI microservices platform via a dual HTTP/WebSocket bridge.

┌────────────────────────────────────────────────────────┐
│                   Flutter Rider App                    │
│                                                        │
│  Presentation Layer: Screens & Widgets                 │
│  State Management: Riverpod / Bloc                     │
│  Repository Layer: Offline-First Abstract Repositories │
│  Local Storage: Sqflite + Flutter Secure Storage       │
│  Native Bridges: Geolocator, Mobile Scanner, TTS       │
└───────────────────────────▲────────────────────────────┘
│ HTTPS REST / WSS
┌───────────────────────────▼────────────────────────────┐
│                    FastAPI Backend                     │
│                                                        │
│  - /api/v1/auth/driver                                 │
│  - /api/v1/logistics/rides (HFVRP Engine via OR-Tools) │
│  - /api/v1/logistics/telemetry (WebSocket Stream)      │
│  - /api/v1/escrow/settlement (Razorpay/Cashfree)       │
└────────────────────────────────────────────────────────┘


## 2. Flutter Architecture Pattern
- **Pattern**: Clean Architecture (Feature-first folder structure) with **Riverpod** for declarative, testable state management.
- **Offline-First Synchronization**:
  - SQLite (`sqflite`) logs vehicle GPS pings, order status updates, and offline QR scans.
  - A persistent background worker (`workmanager`) flushes queued records to the backend when network connectivity is established.

## 3. Data Contracts & Models

### Ride Entity (Dart)
```dart
class RideTrip {
  final String tripId;
  final String vehicleTier; // MICRO, SMALL, MEDIUM, LARGE
  final double totalTripCost;
  final String status; // ASSIGNED, EN_ROUTE_PICKUP, IN_TRANSIT, DELIVERED
  final List<PickupWaypoint> waypoints;
  final DropoffLocation destination;

  RideTrip({
    required this.tripId,
    required this.vehicleTier,
    required this.totalTripCost,
    required this.status,
    required this.waypoints,
    required this.destination,
  });
}

class PickupWaypoint {
  final String stopId;
  final String farmerName;
  final String contactPhone;
  final double latitude;
  final double longitude;
  final double weightKg;
  final String cropName;
  final String batchQrCode;
  final bool isPickedUp;

  PickupWaypoint({
    required this.stopId,
    required this.farmerName,
    required this.contactPhone,
    required this.latitude,
    required this.longitude,
    required this.weightKg,
    required this.cropName,
    required this.batchQrCode,
    this.isPickedUp = false,
  });
}

4. Key Libraries
flutter_riverpod: State management.

mobile_scanner: QR code parsing for farm batches.

flutter_map / google_maps_flutter: Route map rendering.

geolocator: GPS tracking and geofencing math.

flutter_tts: Regional audio readouts.

sqflite: Offline database caching.

dio: HTTP client with interceptors for auth tokens and retry policies.


---