import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';

void main() {
  runApp(const PermissionManagerApp());
}

class PermissionManagerApp extends StatefulWidget {
  const PermissionManagerApp({super.key});

  @override
  State<PermissionManagerApp> createState() => _PermissionManagerAppState();
}

class _PermissionManagerAppState extends State<PermissionManagerApp> {
  final navigatorKey = GlobalKey<NavigatorState>();
  late final CorePermissionManager _permissionManager = CorePermissionManager(navigatorKey: navigatorKey);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(),
      navigatorKey: navigatorKey,
      home: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Permission Manager'),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      if (kDebugMode) {
                        print(
                          await _permissionManager.requestNotificationPermission(
                            context: context,
                            showAskLaterOption: true,
                          ),
                        );
                      }
                    },
                    child: const Text('Request Notification Permission'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
