## Kigali City Services

Kigali City Services is a Flutter application that acts as a city directory for Kigali.  
It helps users find public services and popular spots—such as hospitals, police stations, libraries, restaurants, cafés, parks, and tourist attractions—backed by Firebase Authentication and Cloud Firestore.

---

## Core capabilities of the app

### Authentication
- Email/password sign up and login using **Firebase Authentication**
- A Firestore-backed user profile document is created on first registration
- Auth state is observed so sessions survive app restarts

### Places & services (CRUD)
- Create listings that include: name, category, address, phone, description, and latitude/longitude
- Read listings in real time via Firestore streams (no manual refresh needed)
- Edit and delete only the listings that belong to the current user  
  (enforced through Firestore security rules)
- All changes are reflected instantly across Directory, My Listings, and Map screens

### Search and filtering
- Search by listing name with results updating as you type
- Filter by category:
  - Hospital, Police Station, Library, Restaurant, Café, Park, Tourist Attraction
- Search and category filters can be applied together

### Map and navigation
- Detail screen embeds a map using `flutter_map` with OpenStreetMap tiles
- Each listing is shown as a marker using its stored coordinates
- A “Directions” action opens navigation (via `url_launcher`) to the selected location


## Project structure

```text
lib/
├── models/
│   ├── listing_model.dart     
│   └── user_model.dart        
├── providers/
│   ├── auth_provider.dart    
│   └── listings_provider.dart
├── screens/
│   ├── home_screen.dart           
│   ├── directory_screen.dart     
│   ├── my_listings_screen.dart    
│   ├── map_view_screen.dart      
│   ├── listing_detail_screen.dart 
│   ├── add_listing_screen.dart   
│   ├── edit_listing_screen.dart  
│   ├── settings_screen.dart     
│   ├── login_screen.dart
│   ├── signup_screen.dart
│   └── otp_verification_screen.dart (present but not required in current flow)
├── services/
│   ├── auth_service.dart         
│   ├── firestore_service.dart     
│   └── email_otp_service.dart    
├── widgets/
│   └── ui_helpers.dart            
└── main.dart                      
```

---

## State management model

The app uses the `provider` package (`ChangeNotifier`) to keep UI code separate from Firebase logic.

High-level flow:

```text
UI widgets (Consumer / context.watch)
           ↓
AuthProvider / ListingsProvider
           ↓
AuthService / FirestoreService / EmailOtpService
           ↓
Firebase Auth / Cloud Firestore
           ↓
notifyListeners() → listening widgets rebuild
```

- **AuthProvider**:
  - Handles `signUp`, `signIn`, `signOut`
  - Creates the user profile document in Firestore
  - Exposes `currentUser`, `isLoading`, and `error`

- **ListingsProvider**:
  - Wraps listing creation, update, and deletion
  - Supplies streams for “all listings” and “current user’s listings”
  - Maintains `searchQuery` + `selectedCategory`

---

## Firestore data model

### `users/{uid}`
```text
uid         : string  // Firebase Auth UID
email       : string
displayName : string
createdAt   : timestamp
emailVerified (optional) : boolean
verifiedAt  (optional)   : timestamp
```

### `listings/{listingId}`
```text
name        : string
category    : string  // e.g. Hospital | Library | Restaurant | …
description : string
address     : string
phoneNumber : string
latitude    : double  // used to place markers on the map
longitude   : double
createdBy   : string  // UID of the creator
createdAt   : timestamp
updatedAt   : timestamp (optional)
```



The OTP collections are only needed if you enforce an OTP verification step.  
In the current configuration you can treat them as optional, or use them for manual testing.

---

## Firebase configuration (high level)

To run this project against your own Firebase project you’ll need:

1. A Firebase project with:
   - **Authentication → Email/Password** enabled
   - **Cloud Firestore** created (in test or production mode)
2. Platform configuration:
   - `flutterfire configure` to generate `lib/firebase_options.dart`
   - `google-services.json` added to `android/app/` for Android builds
3. Firestore security rules that:
   - Restrict listing updates/deletes to `request.auth.uid == resource.data.createdBy`
   - Limit user profile documents to the owning UID

---

## Running the app

```bash
# Install packages
flutter pub get

# Run on Chrome
flutter run -d chrome

# Run on Android emulator or device
flutter run -d android
```


## Platforms

- **Android** — primary target, tested on emulator  
- **Web (Chrome)** — supported via Flutter web + Firebase web SDK  
- **iOS** — supported in principle once iOS Firebase configuration is added

