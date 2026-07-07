// import 'dart:async';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:Saleh/core/class/SyncServer.dart';
import 'package:Saleh/core/functions/CheckInternat.dart';
import 'package:Saleh/core/services/Services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

class SyncForegroundService {
  final SyncService syncService = SyncService();
  // Timer? _timer;

  void start() {
    syncService.initSyncListener();

    //   _timer?.cancel();
    //   _timer = Timer.periodic(const Duration(minutes: 15), (_) async {
    //     if (await checkInternet()) {
    //       print("🔔 تنفيذ مهمة مزامنة دورية (foreground)...");
    //       await syncService.syncAll();
    //     }
    //   });

    AndroidAlarmManager.periodic(
      const Duration(minutes: 15),
      123,
      syncCallback,
      wakeup: true,
      rescheduleOnReboot: true,
    );
  }

  // void stop() {
  //   _timer?.cancel();
  //   _timer = null;
  // }

  void stop() {
    AndroidAlarmManager.cancel(123);
    print("AlarmManager stopped");
  }
}

@pragma('vm:entry-point')
void syncCallback() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initialServices();
  await Supabase.initialize(
    url: 'https://xquifseyqyagcvbdixsg.supabase.co',
    anonKey: 'sb_publishable_hRLH8Cz6xnff5uG-6-_WmA_LIGA6bPv',
  );
  if (await checkInternet()) {
    print("🔔 تنفيذ مهمة مزامنة دورية (background isolate)...");
    final sync = SyncService();
    await sync.syncAll();
  }

  print("SYNC 🔥 running in background isolate");
}
