# Python STT Server (Whisper)

## Установка

1. Перейдите в папку python_stt_server:
   ```
   cd python_stt_server
   ```
2. Установите зависимости:
   ```
   pip install -r requirements.txt
   ```

## Запуск

1. Запустите сервер:
   ```
   python whisper_server.py
   ```

2. Сервер будет слушать микрофон и отправлять распознанные слова по WebSocket на ws://localhost:8765

## Настройки
- Язык: русский (можно изменить в коде)
- Модель: base (можно заменить на small, medium, large)

## Требования
- Python 3.8+
- Микрофон, подключённый к ПК 