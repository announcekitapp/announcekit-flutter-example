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
        visualDensity: VisualDensity.adaptivePlatformDensity,
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

class _MyHomePageState extends State<MyHomePage>
    implements AnnounceKitDelegate {
  late AnnounceKitClient _client;
  int _unreadCount = 0;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();

    // Initialize the AnnounceKit client
    _client = AnnounceKitClient(
      settings: AnnounceKitSettings(
        widget: 'your-widget-id', // Replace with your widget ID
        language: 'en',
        user: {'id': 'userId', 'email': 'email@email.com', 'name': 'john doe'},
        customFields: {
          'key': 'value',
        }, //add any custom key value you would like to collect
      ),
      delegate: this,
    );
  }

  // Refresh function
  Future<void> _refreshData() async {
    setState(() {
      _isRefreshing = true;
    });

    try {
      await _client.refreshData();

      await Future.delayed(const Duration(milliseconds: 400));
    } catch (e) {
      debugPrint("Error during refresh: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error refreshing: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }

    return Future.value();
  }

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
    debugPrint('Unread count updated: $count');
    setState(() {
      _unreadCount = count;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AnnounceKit Demo'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _client.createLauncherButton(
              context: context,
              launcherSettings: AnnounceKitLauncherSettings(
                title: 'Updates',
                badgeColor: Colors.red,
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 40),

            Center(
              child:
                  _isRefreshing
                      ? const CircularProgressIndicator()
                      : Text(
                        'You have $_unreadCount unread updates',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
            ),

            const SizedBox(height: 20),

            Center(
              child: ElevatedButton(
                onPressed: () {
                  _client.presentWidget(context);
                },
                child: const Text('Show Updates'),
              ),
            ),

            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Pull down to refresh',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),

            SizedBox(height: MediaQuery.of(context).size.height * 0.7),
          ],
        ),
      ),
    );
  }
}
