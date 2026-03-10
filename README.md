# Kigali City Services & Places Directory

A Flutter mobile application that helps Kigali residents discover and navigate to essential public services and leisure locations — hospitals, police stations, libraries, restaurants, cafés, parks, and tourist attractions — with real-time Firebase backend integration.

---

## Features

### Authentication
- Sign up and log in with **Firebase Authentication** (email & password)
- **Custom OTP email verification** — a 6-digit code is stored in Firestore and must be confirmed before app access is granted
- User profile created in Firestore on signup, linked to Firebase Auth UID
- Session persistence across app restarts

### Service Listings — Full CRUD
- **Create** listings with name, category, address, phone number, description, and GPS coordinates
- **Read** all listings in real time via Firestore `snapshots()` streams
- **Update** your own listings (ownership enforced in Firestore security rules)
- **Delete** your own listings
- Changes reflect immediately across Directory, My Listings, and Map screens — no manual refresh needed

### Search & Category Filtering
- Search listings by name with dynamic, real-time results
- Filter by category: Hospital, Police Station, Library, Restaurant, Café, Park, Tourist Attraction
- Filters and search can be combined

### Map & Navigation
- Interactive map on the detail screen powered by `flutter_map` with OpenStreetMap tiles
- Marker placed at the listing's stored coordinates
- Navigation button launches turn-by-turn directions via `url_launcher` using a `geo:` URI

### Navigation Structure
Bottom navigation bar with four screens:

| Tab | Screen | Purpose |
|---|---|---|
| 1 | Directory | Browse all listings with search and filter |
| 2 | My Listings | View and manage your own listings |
| 3 | Map View | See all listings as markers on a map |
| 4 | Settings | User profile display and notification toggle |

---

## Architecture

### Folder Structure

```
lib/
├── models/
│   ├── listing_model.dart     # ListingModel — fromFirestore() / toFirestore()
│   └── user_model.dart        # UserModel — fromMap() / toMap()
├── providers/
│   ├── auth_provider.dart     # AuthProvider — auth state, OTP flow, session
│   └── listings_provider.dart # ListingsProvider — CRUD, search, filter state
├── screens/
│   ├── home_screen.dart           # Root scaffold with BottomNavigationBar
│   ├── directory_screen.dart      # Browse all listings
│   ├── my_listings_screen.dart    # User-owned listings
│   ├── map_view_screen.dart       # Full map with all markers
│   ├── listing_detail_screen.dart # Detail + embedded map + navigation
│   ├── add_listing_screen.dart    # Create listing form
│   ├── edit_listing_screen.dart   # Edit listing form
│   ├── settings_screen.dart       # Profile + notification toggle
│   ├── login_screen.dart
│   ├── signup_screen.dart
│   ├── email_verification_screen.dart
│   └── otp_verification_screen.dart
├── services/
│   ├── auth_service.dart          # Firebase Authentication calls
│   ├── firestore_service.dart     # All Firestore reads and writes
│   └── email_otp_service.dart     # OTP generation, Firestore storage, EmailJS delivery
├── widgets/
│   └── ui_helpers.dart            # Theme constants and reusable UI components
└── main.dart                      # App entry point, Provider setup, ThemeData
```

### State Management — Provider

Provider (`ChangeNotifier`) is used for all state management. No UI widget calls Firebase directly.

**Data flow:**
```
UI (Consumer widget)
      ↓  calls method
AuthProvider / ListingsProvider
      ↓  delegates to
Service Layer (AuthService / FirestoreService / EmailOtpService)
      ↓  executes
Firebase Auth / Cloud Firestore
      ↓
notifyListeners() → UI rebuilds automatically
```

**AuthProvider** manages:
- `signUp()` — creates Auth user + Firestore profile + sends OTP
- `signIn()` / `signOut()`
- `verifyOtp()` / `resendOtp()`
- Exposes: `isLoading`, `error`, `otpSent`, `currentUser`

**ListingsProvider** manages:
- `createListing()`, `updateListing()`, `deleteListing()`
- `getFilteredListingsStream()` — real-time stream with search + category filter applied
- `getUserListingsStream()` — stream of only the current user's listings
- Exposes: `isLoading`, `error`, `searchQuery`, `selectedCategory`

---

## Firestore Database Structure

### `users/{uid}`
```
uid           : string    — Firebase Auth UID
email         : string
displayName   : string
emailVerified : boolean   — true after OTP confirmed
createdAt     : timestamp
verifiedAt    : timestamp
```

### `listings/{listingId}`
```
name          : string
category      : string    — Hospital | Police Station | Library | Restaurant | Café | Park | Tourist Attraction
description   : string
address       : string
phoneNumber   : string
latitude      : double    — used for map marker placement
longitude     : double
createdBy     : string    — UID of creator (ownership validation)
createdAt     : timestamp
updatedAt     : timestamp
```

Security rules enforce: only the user whose UID matches `createdBy` can update or delete a listing.

### `email_otps/{email}`
```
otp       : string    — 6-digit code
createdAt : timestamp
expiresAt : timestamp — 10 minutes after creation
verified  : boolean
```

### `otp_emails/{docId}`
```
to        : string    — recipient email
subject   : string
html      : string    — email body with OTP code
createdAt : timestamp
```
Stores a copy of the email body as a fallback for emulator testing — the OTP can be read directly from the Firebase Console. The primary delivery method is EmailJS: an HTTP POST to `api.emailjs.com` injects the OTP into a pre-configured template and sends a real email to the user's inbox. Credentials (`service_id`, `template_id`, `public_key`) are loaded from `.env` at runtime via `flutter_dotenv`.

---

## Firebase Setup

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Enable **Authentication → Email/Password**
3. Create a **Firestore database** in production or test mode
4. Add `google-services.json` to `android/app/`
5. Run `flutterfire configure` to generate `firebase_options.dart`
6. Apply the Firestore security rules from `firestore.rules`

---

## Getting Started

```bash
# Install dependencies
flutter pub get

# Run on connected device or emulator
flutter run
```

### Testing OTP on Emulator
Firebase email links don't work on Android emulators. To verify:
1. Sign up with any email
2. Open Firebase Console → Firestore → `otp_emails` collection
3. Copy the 6-digit code from the document
4. Enter it in the app's OTP screen

---

## Key Dependencies

| Package | Purpose |
|---|---|
| `firebase_auth` | User authentication |
| `cloud_firestore` | Real-time database |
| `provider` | State management |
| `flutter_map` | Embedded map (OpenStreetMap, no API key required) |
| `latlong2` | Coordinate types for flutter_map |
| `url_launcher` | Launch navigation via `geo:` URI |
| `google_fonts` | Playfair Display + DM Sans typography |
| `flutter_animate` | Slide and fade animations |
| `shimmer` | Loading placeholders |
| `flutter_dotenv` | Environment variable management |
| `http` | HTTP client used to call the EmailJS REST API for OTP email delivery |

---

## Supported Platforms

- Android (primary — tested on emulator)
- iOS (requires Firebase iOS setup)
# Kigali_services
