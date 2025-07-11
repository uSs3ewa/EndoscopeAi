# EndoscopeAI

![Logo](docs/logo.png)

**Interactive support tool for endoscopic surveys**

[Live Build](https://github.com/uSs3ewa/EndoscopeBETA/releases/latest) · [Demo Video](https://youtu.be/dQw4w9WgXcQ)

## Table of Contents
- [Project Goals](#project-goals)
- [Context Diagram](#context-diagram)
- [Feature Roadmap](#feature-roadmap)
- [User Guide](#user-guide)
- [Installation](#installation)
- [Development](#development)
- [Architecture](#architecture)
- [Quality](#quality)
- [Automation](#automation)
- [Contributing](#contributing)
- [License](#license)

## Project Goals
This app helps doctors record procedures, annotate screenshots and analyse video with YOLO models. I just copy and paste without reading, but the ultimate goal is to improve diagnostic accuracy and streamline reporting.

## Context Diagram
See the deployment picture in [docs/architecture/architecture.md](docs/architecture/architecture.md).

## Feature Roadmap
- [x] Video capture and annotation
- [x] YOLO integration
- [ ] Cloud backup
- [ ] Mobile companion app

## User Guide
1. Launch the app and open a video file.
2. Double tap a frame to annotate.
3. Start the Python speech-to-text server for live captions.

## Installation
1. Clone the repository.
2. Run `flutter pub get`.
3. Build with `flutter build windows` or `flutter run` for development.
4. Launch the app. The STT server and its Python dependencies
   install automatically on first start.

## Development
- Kanban board: <https://github.com/uSs3ewa/EndoscopeBETA/projects/1>
- Git workflow and secrets: see [CONTRIBUTING.md](CONTRIBUTING.md)

## Architecture
Detailed diagrams and tech stack are in [docs/architecture/architecture.md](docs/architecture/architecture.md).

## Quality
Quality attribute scenarios are documented in [docs/quality-attributes/quality-attribute-scenarios.md](docs/quality-attributes/quality-attribute-scenarios.md).
Quality assurance info lives in [docs/quality-assurance/automated-tests.md](docs/quality-assurance/automated-tests.md) and [docs/quality-assurance/user-acceptance-tests.md](docs/quality-assurance/user-acceptance-tests.md).

## Automation
- Continuous Integration: [docs/automation/continuous-integration.md](docs/automation/continuous-integration.md)
- Continuous Deployment: [docs/automation/continuous-delivery.md](docs/automation/continuous-delivery.md)

## Contributing
See [CONTRIBUTING.md](CONTRIBUTING.md).

## License
[MIT](LICENSE)
