import 'dart:io';
import 'dart:ui';

import 'package:flutter_core/flutter_core.dart';
import 'package:flutter_core/src/utils/share/protocol/protocol.dart';
import 'package:share_plus/share_plus.dart';

abstract interface class ICoreShare {
  Future<CoreShareResultStatus> share(String text, {String? subject});

  Future<CoreShareResultStatus> shareUri(Uri uri);

  Future<CoreShareResultStatus> shareFile(List<File> files, {String? subject, String? text});
}

class CoreShare implements ICoreShare {
  CoreShare._();

  static final instance = CoreShare._();

  @override
  Future<CoreShareResultStatus> share(String text, {String? subject}) async {
    final result = await Share.share(text, subject: subject, sharePositionOrigin: _sharePositionOrigin);
    return  CoreShareResultStatus.values[result.status.index];
  }

  @override
  Future<CoreShareResultStatus> shareFile(List<File> files, {String? subject, String? text}) async {
    final xFiles = files.map((file) => XFile(file.path)).toList();
    final result = await Share.shareXFiles(xFiles, subject: subject, text: text, sharePositionOrigin: _sharePositionOrigin);
    return CoreShareResultStatus.values[result.status.index];
  }

  @override
  Future<CoreShareResultStatus> shareUri(Uri uri) async {
    final result = await Share.shareUri(uri, sharePositionOrigin: _sharePositionOrigin);
    return  CoreShareResultStatus.values[result.status.index];
  }

  Rect? get _sharePositionOrigin {
    // If the device is not a phone, the share dialog will be displayed in the center of the screen.
    if (DeviceType.isPhone()) return null;

    return const Rect.fromLTWH(0, 0, 300, 500);
  }
}
