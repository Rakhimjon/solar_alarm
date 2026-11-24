# Project Architecture Guidelines

Follow Domain-Driven Design (DDD) & Clean Architecture standard from `abbos2101/ddd_clean_template`:

- **Layer Boundaries**:
  - `domain/`: Entities and repository contracts (pure Dart).
  - `data/`: Datasources, models, and repository implementations.
  - `presentation/`: Pages, widgets, and Cubits/BLoCs.
- **State Management**: BLoC / Cubit with `flutter_bloc`.
- **Dependency Injection**: `get_it` in `lib/di.dart`.
- **Modularity**: Place functional modules inside `lib/features/<feature_name>/`.
