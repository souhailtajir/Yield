# Yield 📱

Yield is a next-generation personal finance dashboard built for iOS 26+. It leverages **Swift 6.2** and **SwiftData** to provide real-time spending analysis, subscription management, and wealth tracking with a beautiful, glass-morphic UI.

## ✨ Features

- **Dashboard**: High-level overview of net worth, daily earnings, and upcoming bills.
- **Smart Expenses**: Unified view for transactions and spending trends using Swift Charts.
- **Subscription Manager**: Track recurring payments, billing cycles, and yearly costs.
- **Visual Analytics**: Interactive charts and category breakdowns.
- **Modern UI**: Built with SwiftUI using native glass effects and fluid animations.

## 🛠 Tech Stack

- **Language**: Swift 6.2 (Strict Concurrency)
- **UI Framework**: SwiftUI
- **Data Persistence**: SwiftData
- **Architecture**: MVVM (Model-View-ViewModel)
- **Charts**: Swift Charts framework
- **Minimum Target**: iOS 26.0+

## 🏗 Project Structure

```text
Yield/
├── Actors/             # Thread-safe actors for data handling
├── App/                # App entry point and configuration
├── Models/             # SwiftData models (Portfolio, Transaction, Subscription)
├── ViewModels/         # Logic and state management
├── Views/
│   ├── Components/     # Reusable UI elements (Cards, Rows, Charts)
│   ├── Screens/        # Main feature screens (Dashboard, Expenses)
│   └── ContentView.swift # Main navigation hub
└── Utilities/          # Helpers and mock data generators
```

## 🚀 Getting Started

### Requirements
- Xcode 17.2+ (Swift 6.2 toolchain)
- iOS 26.0+ Simulator or Device

### Installation
1. Clone the repository.
2. Open `Yield.xcodeproj` in Xcode.
3. Ensure the target is set to **Yield**.
4. Press `Cmd + R` to build and run.

### Data
The app uses a local `SwiftData` container. On the first launch, `MockDataGenerator` will populate the database with sample transactions and subscriptions for testing purposes.

## 🤝 Contributing

1. Fork the repository.
2. Create a feature branch: `git checkout -b feature/NewFeature`.
3. Commit your changes: `git commit -m 'Add NewFeature'`.
4. Push to the branch: `git push origin feature/NewFeature`.
5. Open a Pull Request.

---
*Built with ❤️ in Swift*