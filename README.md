# Greenhouse Control and Monitoring System

Welcome to the Greenhouse Control and Monitoring System repository! This project integrates various technologies to create a comprehensive solution for monitoring and controlling a greenhouse environment. It utilizes Arduino Uno and ESP8266 module with various sensors and equipment, a Flutter application, Firebase as the backend, and an Express.js API for synchronizing the Firebase databases and sending push notifications.

## Table of Contents
- [Project Overview](#project-overview)
- [Technologies Used](#technologies-used)
- [Repository Structure](#repository-structure)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Cloning the Repository](#cloning-the-repository)
  - [Setting Up the Backend](#setting-up-the-backend)
  - [Setting Up the Flutter Application](#setting-up-the-flutter-application)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)

## Project Overview

The Greenhouse Control and Monitoring System is designed to automate and monitor various aspects of a greenhouse environment. It includes:
- Arduino Uno and ESP8266 module for hardware control and sensor data collection.
- A Flutter mobile application for user interaction.
- Firebase for backend database and authentication.
- An Express.js API to synchronize the Firebase databases and manage push notifications.

## Technologies Used

- **Arduino Uno**: Microcontroller for controlling sensors and equipment.
- **ESP8266**: Wi-Fi module for network connectivity.
- **Flutter**: Cross-platform mobile framework for building the user interface.
- **Firebase**: Backend as a Service (BaaS) for database and authentication.
- **Express.js**: Node.js web application framework for building the API.

## Repository Structure

```plaintext
greenhouse-proj/
├── backend/                    # Contains API code
│   ├── index.js                # Main entry point for the API
│   ├── routes/                 # API routes
│   ├── controllers/            # Route handlers
│   ├── models/                 # Database models
│   ├── utils/                  # Utility functions
│   └── package.json            # NPM dependencies and scripts
│
├── greenhouse_project/         # Contains Flutter code
│   ├── lib/
│   │   ├── pages/              # UI pages
│   │   ├── services/           # Service layer
│   │   │   └── cubit/          # State management
│   │   ├── utils/              # Utility functions and helpers
│   │   └── main.dart           # Main entry point for the Flutter app
│   └── pubspec.yaml            # Flutter dependencies
└── README.md                   # Project documentation
```

## Getting Started

### Prerequisites

Before you begin, ensure you have the following installed on your machine:

- **Node.js** (version 14.x or later)
- **NPM** (version 6.x or later)
- **Flutter** (version 2.x or later)
- **Arduino IDE** (version 1.8.x or later)

### Cloning the Repository

Clone the repository to your local machine using the following command:

```bash
git clone https://github.com/your-username/greenhouse-proj.git
```

### Setting Up the Backend

Navigate to the `backend` directory and install the necessary dependencies:

```bash
cd greenhouse-proj/backend
npm install
```

Create a `.env` file in the `backend` directory and add your Firebase configuration details.

Start the Express.js server:

```bash
npm start
```

### Setting Up the Flutter Application

Navigate to the `greenhouse_project` directory:

```bash
cd greenhouse-proj/greenhouse_project
```

Install the necessary Flutter dependencies:

```bash
flutter pub get
```

Run the Flutter application:

```bash
flutter run
```

## Usage

1. Upload the Arduino code to your Arduino Uno.
2. Ensure the ESP8266 module is properly connected and configured.
3. Start the Express.js server to handle API requests and push notifications.
4. Use the Flutter application to interact with the greenhouse system, monitor sensor data, and control equipment.

## Contributing

We welcome contributions! Please read our [CONTRIBUTING.md](CONTRIBUTING.md) file for guidelines on how to contribute to this project.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more information.

---

Feel free to contact us if you have any questions or need further assistance. Happy coding!
