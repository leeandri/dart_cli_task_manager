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

## How to Run

1. Clone the repository:
   ```bash
   git clone [https://github.com/leeandri/dart_cli_task_manager.git](https://github.com/leeandri/dart_cli_task_manager.git)
   ```
