import asyncio
import websockets
import sounddevice as sd
import numpy as np
import whisper

SAMPLE_RATE = 16000
BLOCK_SIZE = 16000  # 1 секунда
LANGUAGE = "ru"  # только русский

model = whisper.load_model("medium")  # Можно заменить на "small", "medium", "large"

async def audio_handler(websocket, path):
    print("Client connected.")
    try:
        while True:
            audio_chunk_bytes = await websocket.recv()
            audio_chunk_np = np.frombuffer(audio_chunk_bytes, dtype=np.int16).astype(np.float32) / 32768.0
            result = model.transcribe(audio_chunk_np, language=LANGUAGE, fp16=False)
            text = result.get("text", "").strip()

            if text:
                print(f"Recognized: {text}")
                await websocket.send(text)

    except websockets.exceptions.ConnectionClosedOK:
        print("Client disconnected.")
    except Exception as e:
        print(f"An error occurred: {e}")

async def main():
    server = await websockets.serve(audio_handler, "localhost", 8765)
    print("WebSocket STT server started at ws://localhost:8765")
    await server.wait_closed()

if __name__ == "__main__":
    asyncio.run(main())