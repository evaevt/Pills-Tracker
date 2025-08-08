#!/bin/bash

# Скрипт для синхронизации файлов из Cursor в Xcode
# Использование: ./sync_to_xcode.sh

SOURCE_DIR="/Users/tina/Desktop/Tracker iOS"
TARGET_DIR="/Users/tina/Documents/iOS Projects/Tracker iOS/Tracker iOS/Tracker iOS"

echo "🔄 Синхронизация файлов из Cursor в Xcode..."

# Проверяем, что исходная папка существует
if [ ! -d "$SOURCE_DIR" ]; then
    echo "❌ Ошибка: Папка $SOURCE_DIR не найдена"
    exit 1
fi

# Проверяем, что целевая папка существует
if [ ! -d "$TARGET_DIR" ]; then
    echo "❌ Ошибка: Папка $TARGET_DIR не найдена"
    exit 1
fi

# Синхронизация основных файлов
echo "📁 Копирование основных файлов..."
cp "$SOURCE_DIR/TrackerApp.swift" "$TARGET_DIR/" 2>/dev/null || echo "⚠️  TrackerApp.swift не найден"
cp "$SOURCE_DIR/ContentView.swift" "$TARGET_DIR/" 2>/dev/null || echo "⚠️  ContentView.swift не найден"
cp "$SOURCE_DIR/DependencyContainer.swift" "$TARGET_DIR/" 2>/dev/null || echo "⚠️  DependencyContainer.swift не найден"

# Синхронизация папок
echo "📁 Синхронизация папок..."
[ -d "$SOURCE_DIR/Models" ] && rsync -av --delete "$SOURCE_DIR/Models/" "$TARGET_DIR/Models/"
[ -d "$SOURCE_DIR/Views" ] && rsync -av --delete "$SOURCE_DIR/Views/" "$TARGET_DIR/Views/"
[ -d "$SOURCE_DIR/ViewModels" ] && rsync -av --delete "$SOURCE_DIR/ViewModels/" "$TARGET_DIR/ViewModels/"
[ -d "$SOURCE_DIR/Services" ] && rsync -av --delete "$SOURCE_DIR/Services/" "$TARGET_DIR/Services/"
[ -d "$SOURCE_DIR/Modules" ] && rsync -av --delete "$SOURCE_DIR/Modules/" "$TARGET_DIR/Modules/"
[ -d "$SOURCE_DIR/Utils" ] && rsync -av --delete "$SOURCE_DIR/Utils/" "$TARGET_DIR/Utils/"

# Перезапуск xcode-build-server для обновления индексации
echo "🔄 Перезапуск xcode-build-server..."
killall xcode-build-server 2>/dev/null || true
sleep 1

echo "✅ Синхронизация завершена!"
echo "💡 Теперь можно обновить Xcode (⌘+R или Product -> Clean Build Folder)"
echo "🚀 Для запуска в Cursor используйте: Cmd+Shift+P -> 'Sweetpad: Build and Run'" 