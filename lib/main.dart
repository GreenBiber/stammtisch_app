import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'l10n/app_localizations.dart';
import 'providers/auth_provider.dart';
import 'providers/group_provider.dart';
import 'providers/event_provider.dart';
import 'providers/points_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/restaurant_provider.dart';
import 'screens/auth/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize providers
  final authProvider = AuthProvider();
  final groupProvider = GroupProvider();
  final eventProvider = EventProvider();
  final pointsProvider = PointsProvider();
  final localeProvider = LocaleProvider();
  final restaurantProvider = RestaurantProvider();

  // Initialize providers
  await authProvider.initialize();
  await localeProvider.initialize();
  
  // Load other data
  await groupProvider.loadGroups();
  await eventProvider.loadEvents();
  await pointsProvider.loadPoints();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider<GroupProvider>.value(value: groupProvider),
        ChangeNotifierProvider<EventProvider>.value(value: eventProvider),
        ChangeNotifierProvider<PointsProvider>.value(value: pointsProvider),
        ChangeNotifierProvider<LocaleProvider>.value(value: localeProvider),
        ChangeNotifierProvider<RestaurantProvider>.value(value: restaurantProvider),
      ],
      child: const StammtischApp(),
    ),
  );
}

class StammtischApp extends StatelessWidget {
  const StammtischApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        return MaterialApp(
          title: 'Stammtisch App',
          debugShowCheckedModeBanner: false,
          
          // Lokalisierung - jetzt dynamisch
          locale: localeProvider.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: LocaleProvider.supportedLocales,
          
          theme: ThemeData(
            brightness: Brightness.dark,
            colorSchemeSeed: Colors.teal,
            useMaterial3: true,
            // Optimierte Eingabefelder
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.grey.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.teal, width: 2),
              ),
            ),
            // Optimierte Buttons
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          home: const AuthWrapper(),
        );
      },
    );
  }
}