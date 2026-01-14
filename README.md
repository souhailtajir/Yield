Yield App 📱
Yield App is a next-generation financial dashboard built using Swift 6.2. It leverages strict concurrency and high-performance memory management to provide real-time yield tracking, automated rebalancing, and secure asset management.
🛠 Tech Stack
• Language: Swift 6.2 (Strict Concurrency Mode)
• SDK: Version 26.2+
• Architecture: Clean Architecture with The Composable Architecture (TCA)
• Concurrency: Structured Concurrency (Async/Await, Actors)
• Data Layer: SwiftData with specialized Span types for zero-copy memory access to price feeds.
🏗 Project Structure
Sources/
├── Core/               # Shared logic and low-level Span/InlineArray extensions
├── Features/           # Modular features (Dashboard, Wallet, Staking)
│   ├── YieldEngine/    # Swift 6.2 optimized calculation engine
│   └── Analytics/      # Real-time charting using Swift Charts
├── Security/           # Biometric auth and secure enclave wrappers
└── YieldApp.swift      # App Entry point (main)
🏁 Getting Started
Requirements
• Xcode 17.2+ (required for Swift 6.2 toolchain)
• macOS 15.0+
• iOS 26+ (target SDK 26.2+)
