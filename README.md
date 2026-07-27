# CLI Task Manager (Dart)

A command-line task management application written in pure Dart, demonstrating OOP principles, custom JSON storage, generic repositories, and CLI interaction.

## Features

- **Add tasks**: Create simple or urgent tasks with optional deadlines and priorities (`low`, `medium`, `high`).
- **List & Sort**: View tasks formatted cleanly in the terminal, sorted either by priority or by deadline/creation date.
- **Complete & Delete**: Mark tasks as completed or delete them using unique IDs.
- **Persistence**: Automatically reads from and saves to `tasks.json`.

## Project Structure

- `lib/task.dart`: Domain models (`Task`, `SimpleTask`, `UrgentTask`, `Priority`).
- `lib/storage_interface.dart`: Generic `Repository<T>` interface and `JsonTaskStorage` implementation.
- `lib/task_manager.dart`: Business logic layer and exception handling.
- `bin/task_manager.dart`: CLI entry point and menu loop.

## How to Run the App

1. Make sure you have the [Dart SDK](https://dart.dev/get-dart) installed.
2. Clone the repository and navigate into the project folder:
   ```bash
   git clone https://github.com/leeandri/dart_cli_task_manager.git
   cd dart_cli_task_manager
   ```
3. Run the application:
   ```bash
   dart run bin/task_manager.dart
   ```

## How to Run the Tests

- To run the unit test suite and verify that all features work properly:

  ```bash
  dart test
  ```
