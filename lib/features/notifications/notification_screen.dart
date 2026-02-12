import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import '../../models/app_notification.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() =>
      _NotificationScreenState();
}

class _NotificationScreenState
    extends State<NotificationScreen> {

  static const brandGreen = Color(0xFF00B562);
  static const surfaceDark = Color(0xFF1C1C1E);
  static const backgroundDark = Color(0xFF121212);

  List<AppNotification> notifications = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      notifications =
          await ApiService.getMyNotifications();
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  IconData _icon(String type) {
    switch (type) {
      case "BOOKING":
        return Icons.event_available_rounded;
      case "PAYMENT":
        return Icons.payments_rounded;
      case "JOB":
        return Icons.build_circle_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: backgroundDark,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("NOTIFICATIONS",
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  fontSize: 16)),
          actions: [
            TextButton(
              onPressed: () async {
                await ApiService
                    .markAllNotificationsRead();
                _load();
              },
              child: const Text("MARK ALL",
                  style: TextStyle(color: brandGreen)),
            )
          ],
        ),
        body: loading
            ? const Center(
                child: CircularProgressIndicator(
                    color: brandGreen))
            : notifications.isEmpty
                ? const Center(
                    child: Text(
                      "No notifications yet",
                      style:
                          TextStyle(color: Colors.white38),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: notifications.length,
                    itemBuilder: (_, i) {
                      final n = notifications[i];

                      return Container(
                        margin:
                            const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: surfaceDark,
                          borderRadius:
                              BorderRadius.circular(16),
                          border: Border.all(
                              color: n.isRead
                                  ? Colors.white10
                                  : brandGreen),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                brandGreen.withOpacity(0.1),
                            child: Icon(
                              _icon(n.type),
                              color: brandGreen,
                            ),
                          ),
                          title: Text(n.title),
                          subtitle: Text(n.message),
                          trailing: Text(
                            DateFormat("dd MMM • hh:mm a")
                                .format(n.createdAt),
                            style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white38),
                          ),
                          onTap: () async {
                            await ApiService
                                .markNotificationRead(
                                    n.id);
                            _load();
                          },
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
