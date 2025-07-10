import asyncio
import websockets

async def test_websocket():
    try:
        uri = "ws://localhost:8765"
        async with websockets.connect(uri) as websocket:
            print("Connected to WebSocket server")
            # Wait for a message
            try:
                message = await asyncio.wait_for(websocket.recv(), timeout=5.0)
                print(f"Received: {message}")
            except asyncio.TimeoutError:
                print("No message received within 5 seconds (this is normal)")
    except Exception as e:
        print(f"Connection failed: {e}")

if __name__ == "__main__":
    asyncio.run(test_websocket()) 