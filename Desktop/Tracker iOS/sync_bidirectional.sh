#!/bin/bash

# Скрипт для двунаправленной синхронизации между Cursor и Xcode
# Использование: ./sync_bidirectional.sh

SOURCE_DIR="/Users/tina/Desktop/Tracker iOS"
TARGET_DIR="/Users/tina/Documents/iOS Projects/Tracker iOS/Tracker iOS/Tracker iOS"

echo "🔄 Двунаправленная синхронизация Cursor ↔ Xcode..."

# Синхронизация исходного кода из Cursor в Xcode
echo "📤 Cursor → Xcode..."
[ -f "$SOURCE_DIR/TrackerApp.swift" ] && cp "$SOURCE_DIR/TrackerApp.swift" "$TARGET_DIR/" 2>/dev/null
[ -f "$SOURCE_DIR/ContentView.swift" ] && cp "$SOURCE_DIR/ContentView.swift" "$TARGET_DIR/" 2>/dev/null
[ -f "$SOURCE_DIR/DependencyContainer.swift" ] && cp "$SOURCE_DIR/DependencyContainer.swift" "$TARGET_DIR/" 2>/dev/null

[ -d "$SOURCE_DIR/Models" ] && rsync -av --delete "$SOURCE_DIR/Models/" "$TARGET_DIR/Models/" 2>/dev/null
[ -d "$SOURCE_DIR/Views" ] && rsync -av --delete "$SOURCE_DIR/Views/" "$TARGET_DIR/Views/" 2>/dev/null
[ -d "$SOURCE_DIR/ViewModels" ] && rsync -av --delete "$SOURCE_DIR/ViewModels/" "$TARGET_DIR/ViewModels/" 2>/dev/null
[ -d "$SOURCE_DIR/Services" ] && rsync -av --delete "$SOURCE_DIR/Services/" "$TARGET_DIR/Services/" 2>/dev/null
[ -d "$SOURCE_DIR/Modules" ] && rsync -av --delete "$SOURCE_DIR/Modules/" "$TARGET_DIR/Modules/" 2>/dev/null
[ -d "$SOURCE_DIR/Utils" ] && rsync -av --delete "$SOURCE_DIR/Utils/" "$TARGET_DIR/Utils/" 2>/dev/null

# Синхронизация Xcode проекта из Xcode в Cursor
echo "📥 Xcode → Cursor..."
[ -d "/Users/tina/Documents/iOS Projects/Tracker iOS/Tracker iOS/Tracker iOS.xcodeproj" ] && \
    rsync -av --delete "/Users/tina/Documents/iOS Projects/Tracker iOS/Tracker iOS/Tracker iOS.xcodeproj/" "$SOURCE_DIR/Tracker iOS.xcodeproj/" 2>/dev/null

echo "✅ Синхронизация завершена!"
echo "🚀 Теперь можно работать в Cursor с полной поддержкой Sweetpad!" 