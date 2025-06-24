import json
import wave
import cv2
import torch
import os
from vosk import Model, KaldiRecognizer
import sounddevice as sd
import queue

class SpeechRecognizer:
    """Offline STT using Vosk."""
    def __init__(self, model_path: str):
        self.model = Model(model_path)

    def transcribe_file(self, audio_path: str) -> str:
        wf = wave.open(audio_path, "rb")
        if wf.getnchannels() != 1 or wf.getsampwidth() != 2 or wf.getcomptype() != "NONE":
            raise ValueError("Audio file must be WAV mono PCM")
        rec = KaldiRecognizer(self.model, wf.getframerate())
        rec.SetWords(True)
        result = []
        while True:
            data = wf.readframes(4000)
            if len(data) == 0:
                break
            if rec.AcceptWaveform(data):
                res = json.loads(rec.Result())
                result.append(res.get("text", ""))
        res = json.loads(rec.FinalResult())
        result.append(res.get("text", ""))
        return " ".join(result).strip()

    def listen(self):
        q = queue.Queue()

        def callback(indata, frames, time, status):
            q.put(bytes(indata))

        with sd.RawInputStream(samplerate=16000, blocksize=8000, dtype='int16', channels=1, callback=callback):
            rec = KaldiRecognizer(self.model, 16000)
            while True:
                data = q.get()
                if rec.AcceptWaveform(data):
                    res = json.loads(rec.Result())
                    print(res.get("text", ""), flush=True)

class EndoscopyDetector:
    """Detect anomalies on images using a YOLOv5 model."""
    def __init__(self, model_path: str, device: str | None = None, repo: str | None = None):
        self.device = device or ("cuda" if torch.cuda.is_available() else "cpu")
        repo = repo or os.environ.get('YOLOV5_REPO', os.path.join(os.path.dirname(__file__), 'yolov5'))
        self.model = torch.hub.load(repo, 'custom', path=model_path, source='local')
        self.model.to(self.device)

    def detect_image(self, image_path: str):
        results = self.model(image_path)
        return results

    def detect_video(self, video_path: str, output_path: str):
        cap = cv2.VideoCapture(video_path)
        fourcc = cv2.VideoWriter_fourcc(*'mp4v')
        out = None
        while cap.isOpened():
            ret, frame = cap.read()
            if not ret:
                break
            results = self.model(frame)
            annotated = results.render()[0]
            if out is None:
                h, w, _ = annotated.shape
                out = cv2.VideoWriter(output_path, fourcc, 20.0, (w, h))
            out.write(annotated)
        cap.release()
        if out:
            out.release()

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description="Endoscope AI tools")
    subparsers = parser.add_subparsers(dest="command")

    stt = subparsers.add_parser("stt")
    stt.add_argument("model", help="Path to Vosk model")
    stt.add_argument("audio", help="Path to WAV file")

    detect = subparsers.add_parser("detect")
    detect.add_argument("weights", help="Path to YOLO weights")
    detect.add_argument("image", help="Path to image file")

    video = subparsers.add_parser("video")
    video.add_argument("weights", help="Path to YOLO weights")
    video.add_argument("input", help="Path to video file")
    video.add_argument("output", help="Output video path")

    listen = subparsers.add_parser("listen")
    listen.add_argument("model", help="Path to Vosk model")

    args = parser.parse_args()

    if args.command == "stt":
        recognizer = SpeechRecognizer(args.model)
        text = recognizer.transcribe_file(args.audio)
        print(text)
    elif args.command == "detect":
        detector = EndoscopyDetector(args.weights)
        results = detector.detect_image(args.image)
        results.save()
        df = results.pandas().xyxy[0]
        print(df.to_json(orient="records"))
    elif args.command == "video":
        detector = EndoscopyDetector(args.weights)
        detector.detect_video(args.input, args.output)
        print(json.dumps({"status": "ok"}))
    elif args.command == "listen":
        recognizer = SpeechRecognizer(args.model)
        recognizer.listen()
    else:
        parser.print_help()
