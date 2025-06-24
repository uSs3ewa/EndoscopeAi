# Python Backend for Endoscope AI

This directory contains a simple offline solution for speech-to-text and endoscopy anomaly detection.

## Features

- **Offline STT** using the [Vosk](https://alphacephei.com/vosk/) model for Russian language.
- **Object detection** on images or videos using a custom YOLOv5 model.

## Requirements

* Python 3.8+
* `pip`

Create a virtual environment and install the dependencies from
`requirements.txt`:

```bash
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
```

Download the Russian STT model from Vosk and place it in a directory, e.g.
`models/vosk`. Download or train a YOLOv5 model for endoscopic anomalies and
save the weights as `models/endoscope.pt`.

## Usage

### Command line usage

Run speech recognition or detection directly without any network service:

```bash
python endoscope_ai.py stt models/vosk path/to/file.wav
python endoscope_ai.py detect models/endoscope.pt path/to/image.jpg
python endoscope_ai.py video models/endoscope.pt input.mp4 output.mp4
```

By default the models are expected under `models/vosk` and `models/endoscope.pt`
relative to this directory. You can override them by supplying paths on the
command line as shown above.

### Packaging for Windows

To ship the backend with the Flutter application you can build a standalone
executable using [PyInstaller](https://pyinstaller.org/):

```bash
pip install pyinstaller
pyinstaller --onefile endoscope_ai.py
```

Copy the resulting `dist/endoscope_ai.exe` next to your Flutter executable and
update `PythonService` if the relative path differs.
