import 'package:work_track/full_apps/m3/homemade/controllers/chart_filter_provider.dart';
import 'package:work_track/full_apps/m3/homemade/views/calender_time_provide.dart';
import 'package:work_track/full_apps/m3/homemade/views/filter_provider.dart';
import 'package:work_track/full_apps/m3/homemade/views/time_provider.dart';
import 'package:work_track/full_apps/m3/homemade/controllers/mood_provider.dart';

import 'package:work_track/full_apps/m3/homemade/views/splash_screen.dart';

import 'package:work_track/helpers/localizations/app_localization_delegate.dart';
import 'package:work_track/helpers/localizations/language.dart';
import 'package:work_track/helpers/theme/app_notifier.dart';
import 'package:work_track/helpers/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

const FirebaseOptions firebaseOptions = FirebaseOptions(
  apiKey: "AIzaSyBL7cI5bcUetb4Wl-RdVeo8t0soAoPc3ms",
  authDomain: "moodmeter-c0d3e.web.app",
  databaseURL: "YOUR_DATABASE_URL",
  projectId: "moodmeter-c0d3e",
  appId: "1:564141866894:android:7f58b9c3981db0cd782edf",
  messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppTheme.init();

  await Firebase.initializeApp(options: firebaseOptions);

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AppNotifier>(
          create: (context) => AppNotifier(),
        ),
        ChangeNotifierProvider<FilterModel>(
          create: (context) => FilterModel(),
        ),
        ChangeNotifierProvider<MoodProvider>(
          create: (context) => MoodProvider(),
        ),
        ChangeNotifierProvider<ChartFilterProvider>(
          create: (context) => ChartFilterProvider(),
        ),
        ChangeNotifierProvider<TimeProvider>(
          create: (context) => TimeProvider(),
        ),
        ChangeNotifierProvider<SelectedTimeChangeProvider>(
          create: (context) => SelectedTimeChangeProvider(),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppNotifier>(
        builder: (BuildContext context, AppNotifier value, Widget? child) {
      return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: const SplashScreen(), // Set your initial screen here
        builder: (context, child) {
          return Directionality(
            textDirection: AppTheme.textDirection,
            child: child ?? Container(),
          );
        },

        localizationsDelegates: [
          AppLocalizationsDelegate(context),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: Language.getLocales(),
      );
    });
  }
}
