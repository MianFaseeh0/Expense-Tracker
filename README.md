# Expenso — Expense Tracker

A Flutter expense tracking app built on clean architecture and SOLID
principles, backed by Firebase.

## Features
- Email/password authentication (Firebase Auth)
- Add, categorize, and browse expenses with receipt photos
- Live category spending chart
- Search-as-you-type expense filtering
- Monthly / all-time spending overview
- Undo-able expense deletion

## Architecture
The codebase is organized into clear layers:
- **core/** — theme, constants, a universal error handling service, and
  reusable mixins (loading state, form validation, controller disposal)
- **data/** — models and repository interfaces + Firebase implementations
  (dependency inversion — swap Firestore for another backend without
  touching the UI)
- **presentation/** — Riverpod controllers/providers and views, split by
  feature (auth, home, expense)

## Stack
Flutter · Dart · Riverpod · Firebase (Auth, Firestore) · Clean Architecture · SOLID
