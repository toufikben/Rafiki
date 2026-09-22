import 'package:flutter_overlay_window/flutter_overlay_window.dart';

class FloatingService {
  static Future<bool> hasPermission() async {
    return await FlutterOverlayWindow.isPermissionGranted();
  }

  static Future<bool> requestPermission() async {
    final granted = await FlutterOverlayWindow.isPermissionGranted();
    if (granted) return true;
    return await FlutterOverlayWindow.requestPermission() ?? false;
  }

  static Future<void> showPet() async {
    if (await FlutterOverlayWindow.isActive()) return;
    await FlutterOverlayWindow.showOverlay(
      height: 250,
      width: 250,
      alignment: OverlayAlignment.center,
      visibility: NotificationVisibility.visibilityPublic,
      flag: OverlayFlag.defaultFlag,
      enableDrag: true,
      overlayTitle: 'Rafiq',
      overlayContent: 'Your companion',
    );
  }

  static Future<void> hidePet() async {
    if (await FlutterOverlayWindow.isActive()) {
      await FlutterOverlayWindow.closeOverlay();
    }
  }

  static Future<bool> isActive() => FlutterOverlayWindow.isActive();
}
