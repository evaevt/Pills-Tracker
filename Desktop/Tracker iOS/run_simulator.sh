#!/bin/bash

echo "🚀 Запуск Tracker iOS в симуляторе..."

# Открываем симулятор
open -a Simulator

# Ждем пока симулятор загрузится
sleep 3

# Собираем и запускаем приложение
xcodebuild -project "Tracker iOS.xcodeproj" \
    -scheme "Tracker iOS" \
    -destination "platform=iOS Simulator,name=iPhone 16,OS=18.2" \
    build | xcbeautify

# Устанавливаем приложение в симулятор
echo "📱 Установка приложения в симулятор..."
xcrun simctl install booted "/Users/tina/Library/Developer/Xcode/DerivedData/Tracker_iOS-bhxolarzbcxgjobqkyquxulxdbnf/Build/Products/Debug-iphonesimulator/Tracker iOS.app"

# Запускаем приложение
echo "▶️ Запуск приложения..."
xcrun simctl launch booted com.tracker.app.Tracker-iOS

echo "✅ Приложение запущено!" 