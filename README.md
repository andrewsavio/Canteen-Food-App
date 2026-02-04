# Canteen Food Order App

A premium, aesthetic Flutter application for canteen food pre-ordering. This app connects students and shop owners, allowing seamless food ordering and management.

## Features

### 🎨 User Interface
- **Premium Dark Theme**: Modern aesthetic with deep blue/purple gradients and glassmorphism elements.
- **Smooth Animations**: Page transitions, fade-ins, and interactive feedback.
- **Responsive Design**: Optimized for mobile touch interactions.

### 🛍️ Shop Owner Dashboard
- **Real-time Inventory Management**: Add food items and see them appear immediately.
- **Stock Control**: Toggle food availability or delete items.
- **Categorization**: Organize food by Main Course, Snacks, Beverages, etc.
- **Supabase Integration**: Secure, cloud-based data storage for all food items.

### 🎓 Student Experience
- **Interactive Menu**: Browse food items with category filtering.
- **Smart Cart**: Add items, adjust quantities, and view totals.
- **Simulated Payment Gateway**: seamless checkout experience.
- **Live Updates**: See only available items in real-time.

## Tech Stack
- **Frontend**: Flutter (Dart)
- **Backend & Auth**: Supabase
- **State Management**: standard `setState` for cleanliness and simplicity in this scale.

## Getting Started

1. **Install Dependencies**
   ```bash
   flutter pub get
   ```

2. **Run the App**
   ```bash
   flutter run
   ```

## Database Schema (Supabase)

The app uses a `food_items` table with the following structure:
- `id`: uuid (primary key)
- `name`: text
- `price`: numeric/float
- `description`: text
- `category`: text
- `is_available`: boolean
- `created_at`: timestamptz
