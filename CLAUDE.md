# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Tracker iOS is a modular habit tracker application built with SwiftUI where users can create custom trackers by combining different modules like building blocks. The app uses modern iOS architecture patterns including MVVM, Repository Pattern, and Dependency Injection.

## Build and Development Commands

### Building the Project
```bash
# Run in Xcode simulator
./run_simulator.sh

# Build project manually
xcodebuild -project "Tracker iOS.xcodeproj" \
    -scheme "Tracker iOS" \
    -destination "platform=iOS Simulator,name=iPhone 16,OS=18.2" \
    build
```

### Synchronization Scripts
```bash
# Sync files from Cursor to Xcode project
./sync_to_xcode.sh

# Bidirectional sync between environments
./sync_bidirectional.sh
```

### Testing
- Unit tests: Use Xcode's built-in testing (Cmd+U)
- UI tests: Run from Xcode test navigator
- Tests are located in `Tests/UnitTests/`, `Tests/IntegrationTests/`, and `Tests/UITests/`

## Architecture

### Core Patterns
- **MVVM**: Views bind to ViewModels which contain business logic
- **Repository Pattern**: Data access abstraction with protocol-based repositories
- **Dependency Injection**: Centralized DI container (`DependencyContainer.swift`)
- **Protocol-Oriented Programming**: Modular system based on `TrackerModuleProtocol`

### Project Structure
```
Models/                 # Data models and Core Data entities
├── CoreData/          # Core Data stack and persistence
├── TrackerModule.swift # Core module definitions
└── ModuleTypes.swift  # Module types and enums

Views/                 # SwiftUI views organized by feature
├── MainScreen/        # Main tracker list view
├── Constructor/       # Drag & drop tracker builder
├── ActiveTracker/     # Running tracker interface
├── Settings/         # Module configuration
└── Analytics/        # Data visualization

Services/              # Business logic services
├── DataService.swift  # Data operations
├── ModuleFactory.swift # Module creation
└── Various protocol implementations

Modules/               # Tracker module implementations
├── Base/             # Base module classes
├── Counters/         # Counter-type modules
├── Checkboxes/       # Checkbox-type modules
├── Time/            # Timer and time-based modules
├── Visual/          # Progress bars, charts
└── Data/            # Notes, photos, voice recordings

Utils/                # Utilities and extensions
ViewModels/          # MVVM ViewModels
Resources/           # Assets, localization
Tests/              # Test suites
```

### Key Components

#### Dependency Container (`DependencyContainer.swift`)
Central service registry following dependency injection pattern. All services are registered in `registerServices()` method.

#### Module System
- **TrackerModuleProtocol**: Base protocol all modules implement
- **ModuleType enum**: Defines all available module types with display names and icons
- **ModuleFactory**: Creates module instances
- **ModuleRegistry**: Registers and manages available modules

#### Data Layer
- Core Data for persistence (`PersistenceController.swift`)
- Repository pattern with protocol abstractions
- Mock services for testing and development

## Firebase Integration

The project uses Firebase for:
- Authentication (`FirebaseAuth`)
- Cloud storage (`FirebaseFirestore`) 
- Core services (`FirebaseCore`)

Firebase configuration is in `GoogleService-Info.plist`.

## Development Workflow

### Adding New Module Types
1. Add new case to `ModuleType` enum in `Models/TrackerModule.swift`
2. Implement module class conforming to `TrackerModuleProtocol`
3. Register in `ModuleRegistry.registerDefaultModules()`
4. Add to appropriate category in `Modules/` directory

### Working with Data
- Use `DataServiceProtocol` for data operations
- Services are injected via `DependencyContainer`
- Current implementation uses mock data (see `DataService.swift`)

### UI Development
- All views use SwiftUI
- ViewModels follow `ObservableObject` pattern
- Navigation handled by `AppRouter`
- State management through `AppState` and individual ViewModels

## Important Files to Understand

- `TrackerApp.swift` - App entry point and dependency setup
- `DependencyContainer.swift` - Service registration and resolution
- `Models/TrackerModule.swift` - Core module system definitions
- `Services/DataService.swift` - Data access patterns
- `ARCHITECTURE.md` - Detailed architecture documentation (in Russian)

## Current State

The project is in early development with:
- ✅ Core architecture established
- ✅ Module system framework
- ✅ Basic UI structure
- ⚠️ Mock data services (real persistence not implemented)
- ⚠️ Limited module implementations
- ⚠️ Drag & drop constructor not fully implemented

Most services currently return mock data while the full implementation is being developed.