#!/usr/bin/env python3
"""Simple Whisper-based STT streaming service."""

import argparse
import queue
import sys

import numpy as np
import sounddevice as sd
import whisper


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", help="Path to transcript output file")
    parser.add_argument("--model", default="base", help="Whisper model name")
    args = parser.parse_args()

    model = whisper.load_model(args.model)
    samplerate = 16000
    q = queue.Queue()
    buffer = np.empty((0,), dtype=np.float32)

    def callback(indata, frames, time, status):
        if status:
            print(status, file=sys.stderr)
        q.put(indata[:, 0].copy())

    f = open(args.output, "w", encoding="utf-8") if args.output else None

    try:
        with sd.InputStream(samplerate=samplerate, channels=1, callback=callback):
            while True:
                data = q.get()
                buffer = np.concatenate([buffer, data])
                if len(buffer) >= samplerate * 5:
                    segment = buffer[: samplerate * 5]
                    buffer = buffer[samplerate * 5 :]
                    result = model.transcribe(segment, language="ru", fp16=False)
                    text = result.get("text", "").strip()
                    if text:
                        print(text, flush=True)
                        if f:
                            f.write(text + "\n")
                            f.flush()
    except KeyboardInterrupt:
        pass
    finally:
        if f:
            f.close()


if __name__ == "__main__":
    main()
