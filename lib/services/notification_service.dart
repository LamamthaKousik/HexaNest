import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/patient_model.dart';
import '../models/visit_model.dart';

/// Service for managing local notifications
/// Provides health reminders and visit notifications
class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = 
      FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;

  /// Initialize the notification service
  static Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // Request notification permission
      final status = await Permission.notification.request();
      if (!status.isGranted) {
        print('Notification permission not granted');
        return false;
      }

      // Android initialization settings
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      
      // iOS initialization settings
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      _isInitialized = true;
      return true;
    } catch (e) {
      print('Error initializing notifications: $e');
      return false;
    }
  }

  /// Handle notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');
    // Handle notification tap - could navigate to specific screen
  }

  /// Schedule a visit reminder notification
  static Future<void> scheduleVisitReminder({
    required String patientName,
    required String visitType,
    required DateTime reminderDate,
    String? notes,
  }) async {
    try {
      await _notifications.zonedSchedule(
        patientName.hashCode, // Use patient name hash as ID
        'Visit Reminder',
        '$visitType due for $patientName${notes != null ? '\n$notes' : ''}',
        tz.TZDateTime.from(reminderDate, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'visit_reminders',
            'Visit Reminders',
            channelDescription: 'Reminders for patient visits',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'visit_reminder_$patientName',
      );
    } catch (e) {
      print('Error scheduling visit reminder: $e');
    }
  }

  /// Schedule immunization reminder
  static Future<void> scheduleImmunizationReminder({
    required String childName,
    required String vaccineName,
    required DateTime reminderDate,
  }) async {
    try {
      await _notifications.zonedSchedule(
        childName.hashCode + vaccineName.hashCode,
        'Immunization Due',
        '$vaccineName due for $childName',
        tz.TZDateTime.from(reminderDate, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'immunization_reminders',
            'Immunization Reminders',
            channelDescription: 'Reminders for child immunizations',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'immunization_$childName',
      );
    } catch (e) {
      print('Error scheduling immunization reminder: $e');
    }
  }

  /// Schedule pregnancy checkup reminder
  static Future<void> schedulePregnancyReminder({
    required String patientName,
    required DateTime reminderDate,
    String? trimester,
  }) async {
    try {
      await _notifications.zonedSchedule(
        patientName.hashCode + 'pregnancy'.hashCode,
        'Pregnancy Checkup Due',
        'Pregnancy checkup due for $patientName${trimester != null ? '\n$trimester' : ''}',
        tz.TZDateTime.from(reminderDate, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'pregnancy_reminders',
            'Pregnancy Reminders',
            channelDescription: 'Reminders for pregnancy checkups',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'pregnancy_$patientName',
      );
    } catch (e) {
      print('Error scheduling pregnancy reminder: $e');
    }
  }

  /// Schedule general health tip notification
  static Future<void> scheduleHealthTip({
    required String tipTitle,
    required String tipContent,
    required DateTime scheduleTime,
  }) async {
    try {
      await _notifications.zonedSchedule(
        tipTitle.hashCode,
        tipTitle,
        tipContent,
        tz.TZDateTime.from(scheduleTime, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'health_tips',
            'Health Tips',
            channelDescription: 'Daily health tips and reminders',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'health_tip_$tipTitle',
      );
    } catch (e) {
      print('Error scheduling health tip: $e');
    }
  }

  /// Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    try {
      await _notifications.cancelAll();
    } catch (e) {
      print('Error canceling notifications: $e');
    }
  }

  /// Cancel specific notification
  static Future<void> cancelNotification(int id) async {
    try {
      await _notifications.cancel(id);
    } catch (e) {
      print('Error canceling notification: $e');
    }
  }

  /// Get pending notifications
  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      return await _notifications.pendingNotificationRequests();
    } catch (e) {
      print('Error getting pending notifications: $e');
      return [];
    }
  }
}

/// Provider for notification service
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// Provider for managing notification state
final notificationStateProvider = StateNotifierProvider<NotificationStateNotifier, NotificationState>((ref) {
  return NotificationStateNotifier();
});

/// Notification state model
class NotificationState {
  final bool isInitialized;
  final bool notificationsEnabled;
  final List<PendingNotificationRequest> pendingNotifications;
  final String? error;

  NotificationState({
    this.isInitialized = false,
    this.notificationsEnabled = false,
    this.pendingNotifications = const [],
    this.error,
  });

  NotificationState copyWith({
    bool? isInitialized,
    bool? notificationsEnabled,
    List<PendingNotificationRequest>? pendingNotifications,
    String? error,
  }) {
    return NotificationState(
      isInitialized: isInitialized ?? this.isInitialized,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      pendingNotifications: pendingNotifications ?? this.pendingNotifications,
      error: error,
    );
  }
}

/// Notification state notifier
class NotificationStateNotifier extends StateNotifier<NotificationState> {
  NotificationStateNotifier() : super(NotificationState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final isInitialized = await NotificationService.initialize();
      final pendingNotifications = await NotificationService.getPendingNotifications();
      
      state = state.copyWith(
        isInitialized: isInitialized,
        notificationsEnabled: isInitialized,
        pendingNotifications: pendingNotifications,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(error: 'Failed to initialize notifications: $e');
    }
  }

  Future<void> schedulePatientReminders(List<Patient> patients, List<Visit> visits) async {
    if (!state.isInitialized) return;

    try {
      // Schedule reminders for patients with upcoming visits
      for (final patient in patients) {
        final patientVisits = visits.where((v) => v.patientId == patient.id).toList();
        
        for (final visit in patientVisits) {
          if (visit.nextVisitDate != null) {
            // Schedule reminder 1 day before
            final reminderDate = visit.nextVisitDate!.subtract(const Duration(days: 1));
            
            if (visit.visitType == 'Pregnancy Checkup') {
              await NotificationService.schedulePregnancyReminder(
                patientName: patient.name,
                reminderDate: reminderDate,
                trimester: _getPregnancyTrimester(visit.visitDate),
              );
            } else if (visit.visitType == 'Immunization') {
              await NotificationService.scheduleImmunizationReminder(
                childName: patient.name,
                vaccineName: 'Next Vaccine',
                reminderDate: reminderDate,
              );
            } else {
              await NotificationService.scheduleVisitReminder(
                patientName: patient.name,
                visitType: visit.visitType ?? 'Visit',
                reminderDate: reminderDate,
                notes: visit.notes,
              );
            }
          }
        }
      }

      // Refresh pending notifications
      final pendingNotifications = await NotificationService.getPendingNotifications();
      state = state.copyWith(pendingNotifications: pendingNotifications);
    } catch (e) {
      state = state.copyWith(error: 'Failed to schedule reminders: $e');
    }
  }

  String _getPregnancyTrimester(DateTime visitDate) {
    // Simple trimester calculation based on visit date
    final now = DateTime.now();
    final weeksSinceVisit = now.difference(visitDate).inDays ~/ 7;
    
    if (weeksSinceVisit < 12) return '1st Trimester';
    if (weeksSinceVisit < 28) return '2nd Trimester';
    return '3rd Trimester';
  }

  Future<void> cancelAllNotifications() async {
    try {
      await NotificationService.cancelAllNotifications();
      state = state.copyWith(pendingNotifications: []);
    } catch (e) {
      state = state.copyWith(error: 'Failed to cancel notifications: $e');
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
