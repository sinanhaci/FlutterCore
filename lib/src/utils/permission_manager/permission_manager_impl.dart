import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

late final PopupManager _popupManager;

const _permissionValuePrefix = 'CorePerm';

enum CorePermissionKeys {
  notification(value: '${_permissionValuePrefix}Notification');

  const CorePermissionKeys({required this.value});

  final String value;
}

class CorePermissionStatus extends BaseModel<CorePermissionStatus> {
  const CorePermissionStatus({
    required this.isGranted,
    required this.askLaterMilliSeconds,
  });
  factory CorePermissionStatus.fromJson(Map<String, Object?> json) {
    return CorePermissionStatus(
      isGranted: json['isGranted']! as bool,
      askLaterMilliSeconds: json['askLaterMilliSeconds']! as int,
    );
  }

  final bool isGranted;
  final int askLaterMilliSeconds;

  @override
  String toString() {
    return 'CorePermissionStatus(isGranted: $isGranted, askLaterMilliSeconds: $askLaterMilliSeconds)';
  }

  @override
  CorePermissionStatus fromJson(Map<String, Object?> json) {
    return CorePermissionStatus(
      isGranted: json['isGranted']! as bool,
      askLaterMilliSeconds: json['askLaterMilliSeconds']! as int,
    );
  }

  @override
  Map<String, Object?> toJson() {
    return {
      'isGranted': isGranted,
      'askLaterMilliSeconds': askLaterMilliSeconds,
    };
  }
}

class CorePermissionManager {
  CorePermissionManager({required GlobalKey<NavigatorState> navigatorKey}) : _navigatorKey = navigatorKey {
    _popupManager = PopupManager(navigatorKey: _navigatorKey);
  }

  final GlobalKey<NavigatorState> _navigatorKey;

  Future<PermissionStatus> requestNativePermission({required Permission permission}) {
    return permission.request();
  }

  Future<bool> _checkCanShowPermissionDialog({required CorePermissionKeys key}) async {
    final status = await _getPermissionStatus(key: key);
    if (status.isNull) return true;
    return !status!.isGranted && status.askLaterMilliSeconds != 0 && DateTime.now().millisecondsSinceEpoch > status.askLaterMilliSeconds;
  }

  Future<CorePermissionStatus?> _getPermissionStatus({required CorePermissionKeys key}) async {
    final prefs = await SharedPreferences.getInstance();
    final statusString = prefs.getString(key.value);
    if (statusString.isNull) return null;
    final statusJson = jsonDecode(statusString!);
    return CorePermissionStatus.fromJson(statusJson as Map<String, dynamic>);
  }

  Future<CorePermissionStatus> requestNotificationPermission({BuildContext? context, bool showAskLaterOption = false}) async {
    if (!(await _checkCanShowPermissionDialog(key: CorePermissionKeys.notification))) {
      return (await _getPermissionStatus(key: CorePermissionKeys.notification))!;
    }
    if (context.isNotNull && !context!.mounted) throw Exception('Context is not mounted');
    final id = UniqueKey().toString();
    final result = await _popupManager.showModalBottomSheet<CorePermissionStatus>(
      context: context,
      id: id,
      isScrollControlled: true,
      enableDrag: false,
      isDismissible: false,
      builder: (context) => _PermissionWidget(
        permission: Permission.notification,
        id: id,
        showAskLaterOption: showAskLaterOption,
      ),
    );
    return result!;
  }
}

class _PermissionWidget extends StatefulWidget {
  const _PermissionWidget({
    required this.permission,
    required this.id,
    required this.showAskLaterOption,
  });

  final Permission permission;
  final String id;
  final bool showAskLaterOption;

  @override
  State<_PermissionWidget> createState() => _PermissionWidgetState();
}

class _PermissionWidgetState extends State<_PermissionWidget> {
  Widget? _icon;
  String? _message;

  @override
  void didChangeDependencies() {
    _icon ??= switch (widget.permission) {
      Permission.notification => Icon(
          Icons.notifications,
          size: 50,
          color: context.colorScheme.onPrimary,
        ),
      _ => Icon(
          Icons.info,
          size: 50,
          color: context.colorScheme.onPrimary,
        ),
    };

    _message ??= switch (widget.permission) {
      Permission.notification => _notificationPermissionText,
      _ => 'Daha iyi bir deneyim için ${widget.permission} izni gerekmektedir',
    };
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: context.width * 0.1),
        height: context.height,
        width: context.width,
        color: context.colorScheme.surface,
        child: SafeArea(
          child: Column(
            children: [
              verticalBox64 + verticalBox16,
              Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: context.colorScheme.primary,
                    child: _icon,
                  ),
                  verticalBox16,
                  CoreText.titleMedium(
                    _message,
                    fontWeight: FontWeight.w500,
                    textAlign: TextAlign.center,
                    textColor: context.colorScheme.onSurface,
                  ),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: context.width,
                child: CoreFilledButton(
                  onPressed: () async {
                    final result = await Permission.notification.request();

                    final prefs = await SharedPreferences.getInstance();
                    final status = CorePermissionStatus(
                      isGranted: result.isGranted,
                      askLaterMilliSeconds: 0,
                    );
                    await prefs.setString(
                      CorePermissionKeys.notification.value,
                      jsonEncode(
                        status.toJson(),
                      ),
                    );

                    _popupManager.hidePopup<CorePermissionStatus>(id: widget.id, result: status);
                  },
                  minSize: 50,
                  child: CoreText.labelLarge(
                    'İzin Ver',
                    textColor: context.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (widget.showAskLaterOption) verticalBox8,
              if (widget.showAskLaterOption)
                SizedBox(
                  width: context.width,
                  child: CoreTextButton(
                    onPressed: () {
                      final status = CorePermissionStatus(
                        isGranted: false,
                        askLaterMilliSeconds: _getAskLaterMilliSeconds(),
                      );
                      SharedPreferences.getInstance().then(
                        (prefs) {
                          prefs.setString(
                            CorePermissionKeys.notification.value,
                            jsonEncode(
                              status.toJson(),
                            ),
                          );
                        },
                      );
                      _popupManager.hidePopup<CorePermissionStatus>(id: widget.id, result: status);
                    },
                    minSize: 50,
                    child: CoreText.labelLarge(
                      'Daha Sonra Sor',
                      textColor: context.colorScheme.primary,
                    ),
                  ),
                ),
              verticalBox8,
              CoreTextButton(
                onPressed: () {
                  const status = CorePermissionStatus(
                    isGranted: false,
                    askLaterMilliSeconds: 0,
                  );
                  SharedPreferences.getInstance().then(
                    (prefs) {
                      prefs.setString(
                        CorePermissionKeys.notification.value,
                        jsonEncode(
                          status.toJson(),
                        ),
                      );
                    },
                  );
                  _popupManager.hidePopup<CorePermissionStatus>(id: widget.id, result: status);
                },
                minSize: 50,
                child: CoreText.labelLarge(
                  'İptal',
                  textColor: context.colorScheme.error,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

int _getAskLaterMilliSeconds() {
  // 7 days
  return DateTime.now().millisecondsSinceEpoch + 1000 * 60 * 60 * 24 * 7;
}

const _notificationPermissionText = 'Bildirimleri alabilmeniz için izin gerekmektedir';
