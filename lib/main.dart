import 'package:Saleh/controller/ThemeController.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Saleh/Bindings/Initialbindings.dart';
import 'package:Saleh/core/services/Services.dart';
import 'package:Saleh/routes.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constant/Themdata.dart';
import 'core/functions/callback.dart';

import 'package:flutter_native_splash/flutter_native_splash.dart';

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await initialServices();


  await Supabase.initialize(
    url: 'https://xquifseyqyagcvbdixsg.supabase.co',
    anonKey: 'sb_publishable_hRLH8Cz6xnff5uG-6-_WmA_LIGA6bPv',
  );

  // if (Firebase.apps.isEmpty) {
  //   await Firebase.initializeApp();
  // }
  // await FcmHelper.initFCM();

  // final syncService = SyncService();
  // syncService.initSyncListener();
  await AndroidAlarmManager.initialize();

  final syncForeground = SyncForegroundService();
  syncForeground.start();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Get.put(RefreshService());
    final ThemeController themeController = Get.put(ThemeController());
    
    return Obx(() => GetMaterialApp(
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      navigatorObservers: [routeObserver],
      debugShowCheckedModeBanner: false,
      title: 'Salah',
      theme: themeLight,
      darkTheme: themeDark,
      themeMode: themeController.themeMode.value,
      initialBinding: Initialbindings(),
      getPages: routes,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child!,
        );
      },
    ));
  }
}

