import 'package:flutter/material.dart';
import '../../core/models/notification_model.dart';

class NotificationProvider extends ChangeNotifier {
  final List<AppNotification> _notifications = [];

  List<AppNotification> get notifications =>
      _notifications.reversed.toList(); // latest first

  int get unreadCount =>
      _notifications.where((n) => !n.isRead).length;

  void addNotification(String title, String message) {
    _notifications.add(
      AppNotification(
        title: title,
        message: message,
        timestamp: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void removeByMessageContains(String text) {
    _notifications.removeWhere((n) => n.message.contains(text));
    notifyListeners();
  }

  void markAsRead(int index) {
    // index is from reversed list (latest first), convert to _notifications index
    final realIndex = _notifications.length - 1 - index;
    if (realIndex >= 0 && realIndex < _notifications.length) {
      _notifications[realIndex].isRead = true;
      notifyListeners();
    }
  }

  void markAllAsRead() {
    for (var n in _notifications) {
      n.isRead = true;
    }
    notifyListeners();
  }
}
