# Canteen Food Order App

A Flutter app for pre-ordering canteen food. Students browse the menu and build a cart. Shop owners manage menu items and their availability. The backend is Supabase.

## Features

**Students**
- Log in with Supabase email and password
- Browse the menu and filter by category
- Add items to a cart, change quantities, and see totals
- Checkout with a **simulated** payment step (no real payment provider is connected)

**Shop owners**
- Add menu items with name, price, description and category
- Turn items on or off, or delete them

## Screens

| File | Screen |
|------|--------|
| `lib/login_page.dart` | Login |
| `lib/student_page.dart` | Menu and ordering |
| `lib/cart_page.dart` | Cart and checkout |
| `lib/shop_owner.dart` | Menu management |
| `lib/supabase_flutter.dart` | Supabase data access |

## Tech stack

- Flutter and Dart
- Supabase (Postgres and email auth)
- State management with `setState`. The app is small enough that a state library isn't needed.

## Getting started

**Prerequisites:** the Flutter SDK, and a Supabase project.

1. Install dependencies:
   ```bash
   flutter pub get
   ```
2. Create a Supabase project and note its URL and anon (publishable) key. The app reads them from build-time definitions, so no keys live in the source code.
3. Create the `food_items` table:

   | Column | Type |
   |--------|------|
   | `id` | uuid, primary key |
   | `name` | text |
   | `price` | numeric |
   | `description` | text |
   | `category` | text |
   | `is_available` | boolean |
   | `created_at` | timestamptz |

   The app also reads a `users` table for login.
4. Run the app with your values:
   ```bash
   flutter run      --dart-define=SUPABASE_URL=https://your-project.supabase.co      --dart-define=SUPABASE_ANON_KEY=your-publishable-key
   ```

## Before using real data

- Enable Row Level Security on every table. Add policies so that students can read available items, and only shop owners can change them. The repository does not include these policies yet.
- The payment step is simulated. Don't take real money with this code as it stands.

## Project layout

```
lib/
├── main.dart            # app entry point and Supabase setup
├── login_page.dart
├── student_page.dart
├── shop_owner.dart
├── cart_page.dart
└── supabase_flutter.dart
```
