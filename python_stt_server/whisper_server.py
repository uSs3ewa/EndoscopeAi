import asyncio
import websockets
import sounddevice as sd
import numpy as np
import whisper
import os

# Define the path to store the model
# Get the directory of the current script
script_dir = os.path.dirname(os.path.abspath(__file__))
# Go up one level to the project root
project_root = os.path.dirname(script_dir)
# Define the path to store the model
model_dir = os.path.join(project_root, "assets", "models", "whisper")
os.makedirs(model_dir, exist_ok=True)


SAMPLE_RATE = 16000
BLOCK_SIZE = 16000  # 1 секунда
LANGUAGE = "ru"  # только русский

print(f"Loading whisper model 'large-v3', this may take a while for the first time...")
print(f"Model will be saved in {model_dir}")
model = whisper.load_model("large-v3", download_root=model_dir)  # Можно заменить на "small", "medium", "large"
print("Whisper model loaded.")

async def recognize_and_send(websocket):
    print("Client connected")
    try:
        with sd.InputStream(samplerate=SAMPLE_RATE, channels=1, dtype='float32') as stream:
            while websocket.open:
                try:
                    audio_block, overflowed = stream.read(BLOCK_SIZE)
                    if overflowed:
                        print("Warning: audio buffer overflowed")
                    audio_block = np.squeeze(audio_block)
                    
                    # Проверяем, содержит ли блок тишину
                    if np.abs(audio_block).mean() < 0.005: # Порог тишины
                        await asyncio.sleep(0.1)
                        continue

                    audio_block = whisper.pad_or_trim(audio_block)
                    mel = whisper.log_mel_spectrogram(audio_block).to(model.device)
                    options = whisper.DecodingOptions(language=LANGUAGE, fp16=False, without_timestamps=True)
                    result = whisper.decode(model, mel, options)
                    
                    text = result.text.strip() if hasattr(result, 'text') else str(result).strip()
                    
                    if text:
                        await websocket.send(text)

                except websockets.exceptions.ConnectionClosed:
                    print("Client disconnected (inside loop)")
                    break
                except Exception as e:
                    print(f"Error processing audio: {e}")
                    # Не выходим из цикла, просто пропускаем этот блок
                    await asyncio.sleep(0.5)
    except Exception as e:
        print(f"Error with audio stream or WebSocket: {e}")
    finally:
        print("Client disconnected")

async def main():
    async with websockets.serve(recognize_and_send, "localhost", 8765):
        print("Server started at ws://localhost:8765")
        await asyncio.Future()  # run forever

if __name__ == "__main__":
    asyncio.run(main())