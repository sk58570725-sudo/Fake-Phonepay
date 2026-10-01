import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FakeSms {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _inited = false;

  static Future<void> init() async {
    if (_inited) return;
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
    _inited = true;
  }

  static Future<void> send({
    required String bankShort,
    required String accountLast4,
    required double amount,
    required String name,
    required bool debit,
  }) async {
    await init();

    const androidDetails = AndroidNotificationDetails(
      'bank_sms_channel',
      'Messages',
      channelDescription: 'SMS messages',
      importance: Importance.max,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(''),
    );

    final amt = amount.toStringAsFixed(2);
    final date = _date();
    final ref = _ref();

    final body = debit
        ? 'Rs.$amt debited from A/c XX$accountLast4 on $date to ${name.toUpperCase()}. UPI Ref $ref. -$bankShort'
        : 'Rs.$amt credited to A/c XX$accountLast4 on $date from ${name.toUpperCase()}. UPI Ref $ref. -$bankShort';

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'VM-$bankShort',
      body,
      const NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  static String _date() {
    final d = DateTime.now();
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yy = d.year.toString().substring(2);
    return '$dd-$mm-$yy';
  }

  static String _ref() {
    final t = DateTime.now().millisecondsSinceEpoch.toString();
    return t.substring(t.length - 12);
  }
}
