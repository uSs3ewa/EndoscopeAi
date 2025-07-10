@echo off
echo Starting STT Server...
echo.
echo Make sure you have Python installed and dependencies are set up.
echo If you haven't installed dependencies yet, run: pip install -r python_stt_server/requirements.txt
echo.
cd python_stt_server
python whisper_server.py
pause 