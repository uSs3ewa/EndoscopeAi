# first_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


#### DEMO Python Backend

The `python_backend/` directory contains offline speech-to-text and anomaly
detection utilities. The models are executed locally by invoking the
`endoscope_ai.py` script. See `python_backend/README.md` for details on model
setup.

Example usage from the project root:

```bash
python python_backend/endoscope_ai.py stt models/vosk sample.wav
python python_backend/endoscope_ai.py detect models/endoscope.pt image.jpg
```

The Flutter application uses `Process.run` to call this script at runtime via
`lib/backend/python_service.dart`. You can bundle the Python interpreter and the
script using PyInstaller (see the backend README) to ship a fully offline
Windows build.

## Проверка офлайн‑моделей

1. Запустите приложение.
2. На главной странице нажмите кнопку **AI инструменты**.
3. В открывшемся окне используйте кнопки для выбора WAV‑файла либо изображения/видео.
4. Распознанный текст или результаты детекции появятся под кнопками.

