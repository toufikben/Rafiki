import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_colors.dart';
import 'features/home/home_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'l10n/app_localizations.dart';
import 'providers/pet_provider.dart';
import 'services/notification_service.dart';

class RafiqApp extends ConsumerStatefulWidget {
  const RafiqApp({super.key});

  @override
  ConsumerState<RafiqApp> createState() => _RafiqAppState();
}

class _RafiqAppState extends ConsumerState<RafiqApp> {
  @override
  void initState() {
    super.initState();
    NotificationService.init().catchError((Object error) {
      debugPrint('Notification init failed: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    final pet = ref.watch(petProvider);
    final loadStatus = ref.watch(petLoadStatusProvider);
    return MaterialApp(
      title: 'Rafiq',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        primaryColor: AppColors.primary,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          surface: AppColors.surface,
        ),
      ),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
      ],
      home: pet != null
          ? const HomeScreen()
          : loadStatus == PetLoadStatus.loading
              ? const _StartupSplash()
              : const OnboardingScreen(),
    );
  }
}

class _StartupSplash extends StatelessWidget {
  const _StartupSplash();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
