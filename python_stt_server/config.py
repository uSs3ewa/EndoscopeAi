# Whisper STT Server Configuration
# Change MODEL_NAME to use different models:
# - "tiny": Fastest, least accurate (~39MB)
# - "base": Fast, good accuracy (~74MB) 
# - "small": Balanced (~244MB)
# - "medium": Better accuracy (~769MB)
# - "large": High accuracy (~1550MB)
# - "large-v3": Best accuracy (~1550MB)

MODEL_NAME = "base"  # Default to base model for faster startup

# Language setting
LANGUAGE = "ru"  # Russian language

# Audio settings
SAMPLE_RATE = 16000
BLOCK_SIZE = 16000  # 1 second

# WebSocket settings
HOST = "localhost"
PORT = 8765 