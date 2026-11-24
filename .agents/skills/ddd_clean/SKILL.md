---
name: ddd-clean-architecture
description: Flutter Domain-Driven Design and Clean Architecture rules based on abbos2101/ddd_clean_template.
---

# Flutter DDD Clean Architecture Specification

Based on template: `https://github.com/abbos2101/ddd_clean_template`

## Directory Structure
```text
lib/
├── app/               # App configuration, routing, themes
├── core/              # Shared errors, usecases, network, utils
├── di.dart            # Dependency injection registry (GetIt)
├── features/
│   └── <feature_name>/
│       ├── domain/
│       │   ├── entities/       # Pure Dart data structures
│       │   ├── repositories/   # Abstract contracts/interfaces
│       │   └── usecases/       # Optional single-action business logic
│       ├── data/
│       │   ├── datasources/    # Raw API / local DB / platform sensors
│       │   ├── models/         # DTOs with JSON serialization & entity mapping
│       │   └── repositories/   # Implements domain repository interfaces
│       └── presentation/
│           ├── cubit/          # Cubit / BLoC state management
│           ├── pages/          # Full screen view widgets
│           └── widgets/        # Feature-specific subcomponents
└── main.dart
```

## Layer Rules
1. **Domain**: Pure Dart. Zero dependencies on Flutter UI, packages, or data sources.
2. **Data**: Implements domain interfaces. Handles platform drivers, APIs, and caching.
3. **Presentation**: Uses Cubits for state. UI triggers methods on Cubit and listens via `BlocConsumer` / `BlocBuilder`.
4. **DI**: Register all singletons, datasources, repositories, and cubits in `di.dart`.
