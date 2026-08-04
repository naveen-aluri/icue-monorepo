import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';

import '../config/env.dart';
import '../providers/auth_provider.dart';
import '../utils/navigation/app_router.dart';
import 'hive_service.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  if (kDebugMode) {
    log('FCM Notification tap in background');
  }
}

final StreamController<NotificationResponse> selectNotificationStream =
    StreamController<NotificationResponse>.broadcast();

@singleton
@injectable
class NotificationService {
  NotificationService(this._authProvider);

  final AuthProvider _authProvider;
  late AndroidNotificationChannel _channel;
  // State
  bool _isInitialized = false;

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  StreamSubscription<NotificationResponse>? _onLocalTapSub;
  StreamSubscription<RemoteMessage>? _onMessageOpenedSub;
  StreamSubscription<RemoteMessage>? _onMessageSub;
  // Stream Subscriptions
  StreamSubscription<String>? _onTokenRefreshSub;

  Future<void> initialize() async {
    if (_isInitialized) return;

    await _requestPermission();
    await _setupFlutterNotifications();
    _setupMessageHandlers();
    await _initializeToken();

    _isInitialized = true;
  }

  Future<void> dispose() async {
    await _onTokenRefreshSub?.cancel();
    await _onMessageSub?.cancel();
    await _onMessageOpenedSub?.cancel();
    await _onLocalTapSub?.cancel();
    _isInitialized = false;
  }

  Future<AuthorizationStatus> getPermissionStatus() async {
    final settings = await _messaging.getNotificationSettings();
    return settings.authorizationStatus;
  }

  Future<void> showNotification(RemoteMessage message) async {
    final title =
        message.notification?.title ?? message.data['title'] ?? 'Notification';
    final body = message.notification?.body ?? message.data['body'] ?? '';
    final payload = jsonEncode(message.toMap());

    // Determine the correct icon based on environment
    final iconName = Env().config.env == 'PROD'
        ? '@mipmap/ic_launcher'
        : '@mipmap/ic_launcher_dev';

    await _localNotifications.show(
      id: _stableNotificationId(message),
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: iconName,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: false,
          presentSound: true,
        ),
      ),
      payload: payload,
    );
  }

  // --- Private Setup Methods ---

  Future<void> _requestPermission() async {
    final settings = await _messaging.getNotificationSettings();
    if (settings.authorizationStatus == AuthorizationStatus.authorized) return;

    await _messaging.requestPermission();
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      sound: true,
    );
  }

  Future<void> _setupFlutterNotifications() async {
    _channel = const AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);

    final iconName = Env().config.env == 'PROD'
        ? '@mipmap/ic_launcher'
        : '@mipmap/ic_launcher_dev';

    final initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings(iconName),
      iOS: const DarwinInitializationSettings(),
    );

    await _localNotifications.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: selectNotificationStream.add,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
  }

  Future<void> _initializeToken() async {
    final fcmToken = HiveService.fcmTokenBox.get('fcmtoken');

    // Always attempt to fetch and store the token
    if (Platform.isIOS && fcmToken == null) {
      String? apnsToken = await _messaging.getAPNSToken();
      if (apnsToken == null) {
        // Try again after a short delay if the APNS token is not yet available
        await Future<void>.delayed(const Duration(seconds: 3));
        apnsToken = await _messaging.getAPNSToken();
      }
    }

    if (fcmToken == null) {
      await _fetchAndStoreToken();
    }

    // Cancel existing listener before setting up new one to prevent duplicates
    await _onTokenRefreshSub?.cancel();
    _onTokenRefreshSub = _messaging.onTokenRefresh.listen(_updateToken);
  }

  Future<void> _fetchAndStoreToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        await _updateToken(token);
      }
    } catch (e, st) {
      if (kDebugMode) {
        log('FCM: Failed to fetch token', error: e, stackTrace: st);
      }
    }
  }

  Future<void> _updateToken(String token) async {
    try {
      // Check if token has actually changed to avoid unnecessary API calls
      final currentToken = HiveService.fcmTokenBox.get('fcmtoken');
      if (currentToken == token) return;

      await HiveService.fcmTokenBox.put('fcmtoken', token);
      if (navigatorKey.currentContext != null) {
        await _authProvider.updateRegTokens(token);
      }
    } catch (e, st) {
      if (kDebugMode) {
        log('FCM: Failed to update and store token', error: e, stackTrace: st);
      }
    }
  }

  // --- Message Handling ---

  void _setupMessageHandlers() {
    // 1. Foreground messages
    _onMessageSub = FirebaseMessaging.onMessage.listen((message) {
      if (kDebugMode) {
        log('FCM onMessage: ${message.messageId}');
      }

      // On Android, we must show a local notification manually in the foreground.
      // On iOS, the system handles it via `setForegroundNotificationPresentationOptions`.
      if (Platform.isAndroid) {
        showNotification(message);
      }
    });

    // 2. App opened from background (tap on system notification)
    _onMessageOpenedSub = FirebaseMessaging.onMessageOpenedApp.listen((
      message,
    ) {
      if (kDebugMode) {
        log('FCM onMessageOpenedApp: ${message.messageId}');
      }
      _handleInteraction(message, source: 'onMessageOpenedApp');
    });

    // 3. App opened from background (tap on local notification)
    _onLocalTapSub = selectNotificationStream.stream.listen((response) {
      if (response.payload == null) return;
      try {
        final data = jsonDecode(response.payload!) as Map<String, dynamic>;
        final message = RemoteMessage.fromMap(data);
        if (kDebugMode) {
          log('FCM localTapStream: ${message.messageId}');
        }
        _handleInteraction(message, source: 'localTapStream');
      } catch (e, st) {
        if (kDebugMode) {
          log(
            'FCM: Error parsing local notification payload',
            error: e,
            stackTrace: st,
          );
        }
      }
    });

    // 4. App opened from terminated state
    _messaging.getInitialMessage().then((message) {
      if (message != null) {
        if (kDebugMode) {
          log('FCM initialMessage: ${message.messageId}');
        }
        _handleInteraction(message, source: 'initialMessage');
      }
    });
  }

  Future<void> _handleInteraction(
    RemoteMessage message, {
    required String source,
  }) async {
    // Use separate duplicate tracking for interactions
    // This allows user interactions even if the message was already processed for display
    final messageId =
        message.messageId ??
        message.sentTime?.millisecondsSinceEpoch.toString() ??
        DateTime.now().millisecondsSinceEpoch.toString();
    if (kDebugMode) {
      log(
        'FCM Interaction handling for message: $messageId from source: $source',
      );
    }

    final context = navigatorKey.currentContext;
    if (context != null && context.mounted) {
      _navigateToAction(context, message);
    } else if (kDebugMode) {
      log('FCM navigation skipped: No valid context available.');
    }
  }

  void _navigateToAction(BuildContext context, RemoteMessage message) {
    switch (message.data['action']) {
      case 'Track':
        context.go('/layout.trackvehicle');
        break;
      default:
        context.go('/');
        break;
    }
  }

  int _stableNotificationId(RemoteMessage message) {
    final idString =
        message.messageId ??
        message.sentTime?.millisecondsSinceEpoch.toString() ??
        DateTime.now().millisecondsSinceEpoch.toString();
    // Using a simple and effective hash function (djb2)
    int hash = 5381;
    for (int i = 0; i < idString.length; i++) {
      hash = ((hash << 5) + hash) + idString.codeUnitAt(i);
    }
    return hash & 0x7FFFFFFF; // Ensure positive 32-bit integer
  }
}
