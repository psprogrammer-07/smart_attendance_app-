# smart_attendance_app

## Project Description

This Flutter application serves as a comprehensive Attendance Management System, designed to streamline the process of tracking employee attendance. It integrates with Firebase for robust authentication and Cloud Firestore for secure and scalable data storage. The application supports features such as user authentication, team management, employee check-in/check-out, work history tracking, and real-time team chat.

## Features

*   **User Authentication**: Secure sign-up and login functionalities using Firebase Authentication.
*   **Role-Based Access**: Differentiates between admin and regular employee roles, providing tailored functionalities.
*   **Team Management**: Admins can create and manage teams, add/remove members, and assign work.
*   **Employee Check-in/Check-out**: Users can record their attendance with physical check-in/check-out options.
*   **Work History**: Employees can view their past work records, and admins can monitor team attendance.
*   **Real-time Team Chat**: Facilitates communication within teams through an integrated chat feature.
*   **Background Tasks**: Utilizes `workmanager` for efficient handling of background processes.
*   **Local Notifications**: Provides timely notifications using `flutter_local_notifications`.

## Technologies Used

*   **Flutter**: UI Toolkit for building natively compiled applications for mobile, web, and desktop from a single codebase.
*   **Firebase Authentication**: For user registration and login.
*   **Cloud Firestore**: NoSQL document database for storing and syncing data.
*   **Firebase Core**: Core Firebase functionalities.
*   **WorkManager**: For scheduling and executing deferrable background tasks.
*   **Flutter Local Notifications**: For displaying local notifications.
*   **Permission Handler**: For managing application permissions.

## Installation

To get a local copy up and running, follow these simple steps.

### Prerequisites

*   Flutter SDK installed. ([Installation Guide](https://flutter.dev/docs/get-started/install))
*   Firebase project set up with Authentication and Firestore enabled.
*   Node.js and npm/yarn (for Firebase CLI if needed).

### Setup Steps

1.  **Clone the repository**:
    ```bash
    git clone https://github.com/psprogrammer-07/smart_attendance_app-
    cd smart_attendance_app-
    ```

2.  **Install dependencies**:
    ```bash
    flutter pub get
    ```

3.  **Firebase Configuration**:
    *   Create a Firebase project in the Firebase Console.
    *   Add a new Flutter app to your Firebase project.
    *   Follow the instructions to download `google-services.json` (for Android) and `GoogleService-Info.plist` (for iOS) and place them in the correct directories (`android/app/` and `ios/Runner/` respectively).
    *   Enable Email/Password authentication in Firebase Authentication.
    *   Set up Firestore rules and create necessary collections (e.g., `Users`, `Teams`).

4.  **Environment Variables**:
    *   Create a `.env` file in the `lib` directory.
    *   Add your Firebase API keys and other sensitive information to this file. Example:
        ```
        FLUTTER_FIREBASE_APIKEY=YOUR_API_KEY
        FLUTTER_FIREBASE_APPID=YOUR_APP_ID
        FLUTTER_FIREBASE_MESSAGEINGSENDERID=YOUR_MESSAGING_SENDER_ID
        FLUTTER_FIREBASE_PROJECTID=YOUR_PROJECT_ID
        ```

5.  **Run the application**:
    ```bash
    flutter run
    ```

## Usage

*   **Login/Signup**: Users can create new accounts or log in with existing credentials.
*   **Admin Panel**: Admins can access a dedicated screen to manage teams and assign work.
*   **Employee View**: Employees can check in/out and view their work history.
*   **Chat**: Navigate to the team chat section to communicate with team members.

## Project Structure

```
attendance/
├── lib/
│   ├── .env
│   ├── main.dart
│   ├── screens/             # Contains all the different screens/pages of the application
│   │   ├── login_page.dart
│   │   ├── main_screen.dart
│   │   ├── admin_screen.dart
│   │   └── ...
│   └── widgets and functions/ # Reusable UI components and utility functions
│       ├── login_functions.dart
│       ├── admin_sc_function.dart
│       └── ...
├── android/               # Android specific project files
├── ios/                   # iOS specific project files
├── local_items/           # Assets like images and animations
└── README.md
```



## License

Distributed under the MIT License. See `LICENSE` for more information.

