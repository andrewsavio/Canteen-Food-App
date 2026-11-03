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
2. Point the app at your Supabase project. The URL and anon key are currently in `lib/main.dart`. Replace them with your own values. Prefer `--dart-define` so keys stay out of source code.
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
4. Run the app:
   ```bash
   flutter run
   ```

## Before using real data

- The repository does not include Row Level Security policies. Add them so that students can read available items, and only shop owners can change them.
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
