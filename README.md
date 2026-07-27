# 📋 CLI Task Manager (Dart)

A robust, pure Dart command-line task management application built as part of the **Advanced Dart** certification course. This project demonstrates clean architecture, object-oriented programming (OOP) principles, custom error handling, JSON persistence, and unit testing using mock repositories.

---

## 🏗️ Project Architecture & Structure

The codebase is organized into distinct domain layers inside `lib/` to avoid a flat architecture and ensure scalability:

```text
lib/
├── exceptions/
│   └── task_exception.dart      # Custom exception domain hierarchy
├── models/
│   └── task.dart                # Task abstract base model, SimpleTask & UrgentTask
├── repositories/
│   ├── repository.dart          # Generic abstract interface contract (Repository<T>)
│   └── task_repository.dart     # File system JSON storage implementation (JsonTaskStorage)
└── services/
    └── task_manager.dart        # Core business logic layer

bin/
└── task_manager.dart            # CLI user interface & menu entry point

test/
└── task_manager_test.dart       # Unit test suite using in-memory mock repository
```

---

## ✨ Features & Requirements Checklist

| Requirement              | Implementation Details                                                                | Status |
| :----------------------- | :------------------------------------------------------------------------------------ | :----: |
| **Pure Dart CLI**        | Built using pure Dart standard libraries (`dart:io`, `dart:convert`, `dart:async`).   |   ✅   |
| **Task Management**      | Add, list, mark as done, and delete tasks.                                            |   ✅   |
| **Priority & Deadlines** | Supports `LOW`, `MEDIUM`, and `HIGH` priorities. Optional deadlines for `UrgentTask`. |   ✅   |
| **Data Persistence**     | Persists all task data locally in a structured `tasks.json` file.                     |   ✅   |
| **OOP & Inheritance**    | Abstract base class `Task` extended by `SimpleTask` and `UrgentTask`.                 |   ✅   |
| **Interface Contract**   | Generic contract `Repository<T>` implemented by `JsonTaskStorage`.                    |   ✅   |
| **Generics**             | `Repository<T>` pattern for flexible storage implementations.                         |   ✅   |
| **Custom Exceptions**    | Domain errors like `TaskNotFoundException` and `DuplicateTaskException`.              |   ✅   |
| **Unit Testing**         | Test suite using `package:test` with isolated `MockTaskRepository`.                   |   ✅   |

---

## 🏛️ Design & Architectural Decisions

### 1. Object-Oriented Principles (OOP) & Inheritance

- **Abstract Base Class (`Task`)**: Defines core properties (`id`, `title`, `isCompleted`, `priority`) and enforces JSON serialization contracts (`toJson()`).
- **Subclasses (`SimpleTask` & `UrgentTask`)**:
  - `SimpleTask` represents standard daily tasks.
  - `UrgentTask` encapsulates tasks requiring immediate attention, featuring an optional `deadline` property.
- **Polymorphic Factory Constructor**: `Task.fromJson()` inspects the `'type'` discriminator field in JSON payloads to instantiate the correct concrete subtype dynamically.

### 2. Interface Contract & Generics

- **`Repository<T>` Interface**: Defined as an `abstract interface class Repository<T>` enforcing standard CRUD contracts (`getAll`, `getById`, `add`, `update`, `delete`).
- **Implementation Flexibility**: `JsonTaskStorage` implements `Repository<Task>`, managing disk I/O operations and safely parsing JSON without leaking storage details to business services.

### 3. Custom Error Handling Hierarchy

Instead of relying on generic runtime errors, the application uses an isolated domain exception system extending a base `TaskException`:

- `DuplicateTaskException`: Prevents adding tasks with identical titles.
- `TaskNotFoundException`: Thrown when attempting operations on non-existent IDs.
- `TaskStorageException`: Handles JSON corruption, malformed data, or file permission issues gracefully.

### 4. Testability via Mocking

To avoid file system side effects during automated test runs, unit tests rely on an in-memory `MockTaskRepository` implementation of `Repository<Task>`. This guarantees isolated, fast, and deterministic testing.

## 🚀 Getting Started

### Prerequisites

- **Dart SDK**: `>=3.0.0 <4.0.0` installed on your system.

### Installation

1. Clone the repository:
   ```bash
   git clone [https://github.com/leeandri/dart_cli_task_manager.git](https://github.com/leeandri/dart_cli_task_manager.git)
   cd dart_cli_task_manager
   ```
2. Fetch dependencies:
   ```bash
   dart pub get
   ```

### Running the Application

To start the CLI interface, run:

```bash
dart run bin/task_manager.dart
```

### Running Tests

To run the full unit test suite and verify all requirements:

```bash
dart test
```

---

## 📄 License & Author

- **Author**: Lee Andriamaholison
- **Course**: Advanced Dart Certification (NextFlutter)
- **License**: MIT
