import asyncio
import websockets
import sounddevice as sd
import numpy as np
import whisper

SAMPLE_RATE = 16000
BLOCK_SIZE = 16000  # 1 секунда
LANGUAGE = "ru"  # только русский

model = whisper.load_model("medium")  # Можно заменить на "small", "medium", "large"

async def recognize_and_send(websocket):
    print("Client connected")
    with sd.InputStream(samplerate=SAMPLE_RATE, channels=1, dtype='float32') as stream:
        while True:
            audio_block, _ = stream.read(BLOCK_SIZE)
            audio_block = np.squeeze(audio_block)
            audio_block = whisper.pad_or_trim(audio_block)
            mel = whisper.log_mel_spectrogram(audio_block).to(model.device)
            options = whisper.DecodingOptions(language=LANGUAGE, fp16=False)
            result = whisper.decode(model, mel, options)
            text = result.text.strip()
            if text:
                await websocket.send(text)
            await asyncio.sleep(0.1)

async def main():
    async with websockets.serve(recognize_and_send, "localhost", 8765):
        print("Server started at ws://localhost:8765")
        await asyncio.Future()  # run forever

if __name__ == "__main__":
    asyncio.run(main())