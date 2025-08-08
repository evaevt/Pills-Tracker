# Структура базы данных Airtable для мобильного приложения

## База данных: Mobile App Data

### Таблица 1: Users (Пользователи)
- **user_id** (Primary Key) - Уникальный ID пользователя
- **name** (Text) - Имя пользователя
- **email** (Email) - Email пользователя
- **created_at** (Date) - Дата регистрации
- **preferences** (Long Text/JSON) - Настройки пользователя
- **avatar** (Attachment) - Фото профиля

### Таблица 2: User_Actions (Действия пользователей)
- **action_id** (Primary Key) - ID действия
- **user_id** (Link to Users) - Связь с пользователем
- **action_type** (Single Select) - Тип действия
- **action_data** (Long Text/JSON) - Данные действия
- **timestamp** (Date & Time) - Время действия
- **screen_name** (Text) - Экран, где произошло действие
- **completed** (Checkbox) - Завершено ли действие

### Таблица 3: Display_Data (Данные для отображения)
- **display_id** (Primary Key) - ID записи
- **user_id** (Link to Users) - Связь с пользователем
- **action_ids** (Link to User_Actions, multiple) - Связанные действия
- **aggregated_data** (Long Text/JSON) - Агрегированные данные
- **display_type** (Single Select) - Тип отображения
- **last_updated** (Date & Time) - Последнее обновление

### Таблица 4: Analytics (Аналитика)
- **analytics_id** (Primary Key) - ID аналитики
- **user_id** (Link to Users) - Связь с пользователем
- **period** (Single Select) - Период (день/неделя/месяц)
- **metrics** (Long Text/JSON) - Метрики
- **insights** (Long Text) - Инсайты
- **calculated_at** (Date & Time) - Время расчета

## Связи между таблицами:
1. Users ← → User_Actions (один ко многим)
2. User_Actions ← → Display_Data (многие ко многим)
3. Users ← → Display_Data (один ко многим)
4. Users ← → Analytics (один ко многим)