# AnnounceKit Flutter SDK Example App

A Flutter SDK for integrating AnnounceKit widgets into your Flutter applications. This SDK allows you to easily display product updates, release notes, and changelog information in your app with a customizable UI.

## Features

- WebView-based widget display
- Customizable launcher button with badge
- Unread count tracking and management
- Pull-to-refresh functionality
- Event delegation for widget lifecycle events
- Cross-platform support (iOS and Android)
- User data and custom fields support

## Installation

Add the package to your `pubspec.yaml` file:

```yaml
dependencies:
  announcekit_flutter: ^0.1.0
```

Or to use the latest version from GitHub:

```yaml
dependencies:
  announcekit_flutter:
    git:
      url: https://github.com/announcekitapp/announcekit-flutter
```

## Platform-Specific Configuration

### iOS

Add the following to your `ios/Runner/Info.plist` file to allow loading web content:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

### Android

Make sure your `android/app/src/main/AndroidManifest.xml` file includes the internet permission:

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

## Basic Usage

Here's a basic example of how to integrate the AnnounceKit Flutter SDK:

```dart
import 'package:flutter/material.dart';
import 'package:announcekit_flutter/announcekit_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AnnounceKit Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> implements AnnounceKitDelegate {
  late AnnounceKitClient _client;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();

    // Initialize the AnnounceKit client
    _client = AnnounceKitClient(
      settings: AnnounceKitSettings(
        widget: 'your-widget-id', // Replace with your widget ID
        language: 'en',
        user: {
          'id': '123',
          'email': 'user@example.com',
          'name': 'John Doe',
        },
      ),
      delegate: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AnnounceKit Demo'),
        actions: [
          // Add launcher button to app bar
          _client.createLauncherButton(
            context: context,
            launcherSettings: AnnounceKitLauncherSettings(
              title: 'Updates',
              badgeColor: Colors.red,
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('You have $_unreadCount unread updates'),
            ElevatedButton(
              onPressed: () => _client.presentWidget(context),
              child: const Text('Show Updates'),
            ),
          ],
        ),
      ),
    );
  }

  // Implement delegate methods
  @override
  void onWidgetInitialized(String widgetId) {
    debugPrint('Widget initialized: $widgetId');
  }

  @override
  void onWidgetReady(String widgetId) {
    debugPrint('Widget ready: $widgetId');
  }

  @override
  void onWidgetOpened(String widgetId) {
    debugPrint('Widget opened: $widgetId');
  }

  @override
  void onWidgetClosed(String widgetId) {
    debugPrint('Widget closed: $widgetId');
  }

  @override
  void onUnreadCountUpdated(String widgetId, int count) {
    setState(() {
      _unreadCount = count;
    });
  }
}
```

## Advanced Usage

### Adding Pull-to-Refresh Functionality

To enable pull-to-refresh functionality for updating the widget content:

```dart
RefreshIndicator(
  onRefresh: _refreshData,
  child: ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    children: [
      // Your content here
    ],
  ),
)

// Refresh function implementation
Future<void> _refreshData() async {
  setState(() {
    _isRefreshing = true;
  });

  try {
    await _client.refreshData();
    // Optional delay to show the refresh indicator
    await Future.delayed(const Duration(milliseconds: 400));
  } catch (e) {
    debugPrint("Error during refresh: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error refreshing: $e')),
    );
  } finally {
    if (mounted) {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  return Future.value();
}
```

## Key Components

### AnnounceKitSettings

This class configures your AnnounceKit widget:

```dart
AnnounceKitSettings(
  widget: 'your-widget-id',  // Required: Your AnnounceKit widget ID
  language: 'en',            // Optional: Widget language
  user: {                    // Optional: User data for personalization
    'id': 'user-123',        // Required if user is provided
    'email': 'user@example.com',
    'name': 'John Doe',
  },
  customFields: {            // Optional: Additional custom data
    'plan': 'premium',
    'company': 'Acme Inc',
  },
)
```

### AnnounceKitClient

The main class for integrating with AnnounceKit:

```dart
// Initialize the client
AnnounceKitClient(
  settings: AnnounceKitSettings(...),
  delegate: this,  // Optional: Implement AnnounceKitDelegate to receive events
)

// Core methods
client.presentWidget(context);  // Open the widget in a modal
client.refreshData();           // Refresh widget data and unread count
```

### AnnounceKitDelegate

Interface for receiving widget events:

```dart
class YourClass implements AnnounceKitDelegate {
  @override
  void onWidgetInitialized(String widgetId) {
    // Called when the widget library is initialized
  }

  @override
  void onWidgetReady(String widgetId) {
    // Called when a specific widget is initialized
  }

  @override
  void onWidgetOpened(String widgetId) {
    // Called when a widget is opened
  }

  @override
  void onWidgetClosed(String widgetId) {
    // Called when a widget is closed
  }

  @override
  void onUnreadCountUpdated(String widgetId, int count) {
    // Called when the unread count updates
  }
}
```

### AnnounceKitLauncherSettings

Customizes the launcher button appearance:

```dart
AnnounceKitLauncherSettings(
  title: 'Updates',              // Optional: Button text
  titleStyle: TextStyle(...),    // Optional: Style for title text
  badgeStyle: TextStyle(...),    // Optional: Style for badge text
  badgeColor: Colors.red,        // Optional: Background color for badge
  titleColor: Colors.blue,       // Optional: Color for title text
  badgeVerticalOffset: -5.0,     // Optional: Vertical position of badge
  badgeHorizontalOffset: -5.0,   // Optional: Horizontal position of badge
)
```

## Customizing the UI

### Custom Button Implementation

If you prefer to create your own button instead of using the built-in one:

```dart
ElevatedButton(
  onPressed: () => _client.presentWidget(context),
  child: Stack(
    clipBehavior: Clip.none,
    children: [
      const Text('My Custom Button'),
      if (_unreadCount > 0)
        Positioned(
          right: -10,
          top: -10,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            child: Text(
              _unreadCount.toString(),
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
          ),
        ),
    ],
  ),
)
```

## Troubleshooting

### WebView Not Loading

If the WebView fails to load content:

1. Check your internet connection
2. Verify you have the proper permissions in your AndroidManifest.xml and Info.plist
3. Make sure your widget ID is correct
4. Try reopening the widget

### Widget Requires Multiple Clicks to Open

If the widget requires multiple clicks to open:

1. Make sure you're waiting for the `onWidgetReady` callback before trying to open the widget
2. Check console logs for any JavaScript errors
3. Ensure you have a stable internet connection

### Scrolling Issues

If you encounter scrolling problems within the widget:

1. Make sure you're using the latest version of the SDK
2. Check that gesture recognizers are properly set up
