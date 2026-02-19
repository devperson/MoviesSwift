## About Me

I am a **Mobile Application Developer** with **15+ years of professional experience** building high-quality, scalable native and cross-platform iOS and Android applications.

This repository reflects my approach to designing **robust, testable, and scalable** mobile solutions using modern architectural patterns.

**Contact:**  
📧 Email: khasanrah@gmail.com  
💼 Upwork: https://www.upwork.com/freelancers/khasanr  
🔗 LinkedIn: https://www.linkedin.com/in/khasan-rakhimov-18021471/

---

## Project Overview – MoviesDemo (Swift / SwiftUI)

The application demonstrates how to build a **native iOS application** using **Swift & SwiftUI**, while applying proven architectural patterns such as **MVVM**, **ViewModel-driven navigation**, **Clean Archtecture Principle**, and **Dependency Injection (DI)**. Additionally, each application layer is instrumented with logging across UI, ViewModel, Service, and Domain layers, which improves maintainability and long-term support.

The demo shows how:
- A **SwiftUI** application with a clean **MVVM** architecture
- Navigation can be driven entirely from **ViewModels**
- **Domain-Driven Design** structures the core business logic
- Services remain fully abstract and wired via **Dependency Injection**
- The architecture naturally supports **Unit Tests** and **Integration Tests**

### Other Implementations

- **MoviesDemo (Flutter)**  
  https://github.com/devperson/MoviesFlutter
  
- **MoviesDemo (KMP – Fragment / UIKit)**  
  https://github.com/xusan/MoviesKmpSimplified

- **MoviesDemo (KMP – Jetpack Compose / SwiftUI)**  
  https://github.com/xusan/movieskmpcompose
  
- **MoviesDemo (.NET,C# – Fragment / UIKit)**  
  https://github.com/devperson/MyDemoApp
  
> All *MoviesDemo* implementations have **identical domain models, architecture, and features**.
> The repositories differ only in **platform technology and UI framework**, demonstrating how the same
> core architecture can support multiple native UI approaches without changes to the business layer.
  
---

## Application Overview

This demo mobile application targets **iOS** using swift**.
- **Swift** for service and business layers
- **SwiftUI** for UI rendering
- **NavigationStack** for navigation
- **MVVM** architecture
- ~**60% MVVM/Service code**
- ~**40% native UI code per platform**
- Clear separation between UI, ViewModels, Services, and Domain logic

The project demonstrates how to combine **native performance** with a **clean architecture**.

---

## Application Features

- Fetches movies list from server
- Caches data in local storage
- Loads cached data on app restart
- Pull-to-refresh reloads data from server and updates cache
- Add new movie:
  - Name
  - Description
  - Photo (camera or gallery)
- Update movie
- Delete movie

---

## App Demo

![iOS Demo](assets/iosDemoApp.gif)

---

## Architecture Overview

High-level layering:

```
SwiftUI Views
        ↓
ViewModels (MVVM)
        ↓
Application Services
        ↓
Domain Model
        ↓
Infrastructure Services
```

---

## UI Layer (SwiftUI)

The UI layer is implemented using **SwiftUI** and follows a **declarative MVVM approach**.

- Native **SwiftUI**
- Declarative UI
- Navigation based on **NavigationStack**
- Lifecycle aligned with **SwiftUI view lifecycle**
- ViewModels drive navigation and state

The UI layer is responsible only for:
- Rendering
- User interaction
- Navigation
- Binding to ViewModels

No business logic is implemented in views.

---

## 🧠 ViewModel Layer

- Implements MVVM pattern
- Platform-specific (Swift)
- Contains application use-case logic
- Communicates with services via protocols
- Fully unit-tested

---

## 🔧 Service Layer

The service layer is designed using **Domain-Driven Design** principles.

- Fully abstracted via protocols
- Injectable implementations
- Clear separation between domain, application, and infrastructure services

### Contains:
- Domains
- Domain Services
- Application Services
- Infrastructure Services

---

## 🧪 Unit & Integration Testing

The project includes:

- **ViewModel Unit Tests**
- **Application Services Unit Tests**
- **Infrastructure Unit Tests**
- **Integration Tests** using real services

The architecture enables high test coverage and predictable behavior.

---

## Logging & Diagnostics

This project is extensively instrumented with structured logging across all layers of the application to simplify debugging, troubleshooting, and long-term maintenance.
In addition to standard custom logs (warnings, errors, and important state changes), almost every public method is automatically traced using **LogMethod**, providing fine-grained visibility into application flow.

### Key Characteristics

- **Cross-layer instrumentation**  
  Logging is enabled consistently across:
  - **UI**
  - **ViewModels**
  - **Services**
  - **Domain**

- **Automatic method tracing (`LogMethod`)**  
  Nearly all public methods are traced automatically:
  - Method entry only
  - Execution order across layers  
  - Parameter values (when relevant)  

  This makes it possible to follow a single request from UI down to infrastructure and back.

- **User action breadcrumbs (`"Command"`)**  
  All user-initiated actions are logged with the `"Command"` keyword:
  - Allows filtering logs by user steps  
  - Reconstructs full user flows (breadcrumbs)  
  - Makes production issue reports reproducible  

---

## Dependencies

### Dependency Injection
- **Resolver** — Lightweight and flexible dependency injection framework for Swift

### Diagnostics & Logging
- **SwiftyBeaver** — Structured and configurable logging
- **Sentry** — Error monitoring and crash reporting

### Local Storage
- **Realm** — High-performance local database for offline storage and caching

---

## Why This Architecture?

This demo demonstrates how to build:
- Fully **native SwiftUI** applications
- Clean MVVM architecture
- Testable and maintainable code
- Long-living, scalable iOS products
- Architecture parity with cross-platform implementations

---

## License

This project is provided for demonstration and educational purposes.
