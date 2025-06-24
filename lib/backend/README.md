To run it manually:

```bash
python python_backend/server.py
```

When bundled with the Windows build the Flutter application can launch this
server using `Process.start` and communicate with it through HTTP requests. A
sample Dart helper class is provided in `lib/backend/python_service.dart`.

To distribute the backend on Windows you can compile it to a standalone
executable with PyInstaller (see `python_backend/README.md`). Place the resulting
`server.exe` next to the Flutter executable and adjust the launch command if
necessary.
