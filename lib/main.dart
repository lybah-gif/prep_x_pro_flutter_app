import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'app/bindings/app_binding.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/services/notification_service.dart';
import 'app/services/storage_service.dart';  // ✅ StorageService import
import 'app/theme/app_theme.dart';
import 'app/utils/error_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize local storage
  await GetStorage.init();

  // ✅ StorageService ko GetX mein register karein
  await Get.putAsync(() async => StorageService());

  // Initialize notifications
  await Get.putAsync(() async => NotificationService());

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0F172A),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Global error handling
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    ErrorHandler.handleError(details.exception, details.stack ?? StackTrace.empty);
  };

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'PrepX Pro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      initialRoute: Routes.SPLASH,
      initialBinding: AppBinding(),
      getPages: AppPages.routes,
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),

      // Global error widget
      builder: (context, widget) {
        ErrorWidget.builder = (errorDetails) {
          return Scaffold(
            body: ErrorHandler.buildErrorWidget(
              message: 'Something went wrong loading this screen.',
              onRetry: () => Get.offAllNamed(Routes.DASHBOARD),
            ),
          );
        };
        return widget!;
      },
    );
  }
}