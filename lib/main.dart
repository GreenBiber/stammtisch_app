import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'l10n/l10n.dart';
import 'providers/auth_provider.dart';
import 'providers/group_provider.dart';
import 'providers/event_provider.dart';
import 'providers/points_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/restaurant_provider.dart';
// import 'providers/chat_provider.dart';
import 'services/firebase_service.dart';
// import 'services/notification_service.dart';
import 'screens/auth/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from root directory (with error handling)
  try {
    await dotenv.load(fileName: ".env");
    print('✅ Environment variables loaded successfully');
  } catch (e) {
    print(
        '⚠️ Warning: .env file not found or could not be loaded. Using default values.');
    print('Error details: $e');
    // Initialize dotenv with empty content to prevent NotInitializedError
    dotenv.testLoad(fileInput: '');
  }

  // Initialize Firebase
  try {
    // Check if Firebase is already initialized
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('✅ Firebase initialized successfully');
    } else {
      print('✅ Firebase already initialized, skipping');
    }
    
    // Initialize Firebase Service
    await FirebaseService().initialize();
  } catch (e) {
    // Check for specific duplicate app error
    if (e.toString().contains('duplicate-app') || e.toString().contains('already exists')) {
      print('✅ Firebase already initialized, continuing...');
      // Try to initialize Firebase Service anyway
      try {
        await FirebaseService().initialize();
      } catch (serviceError) {
        print('⚠️ Firebase Service initialization skipped: $serviceError');
      }
    } else {
      print('❌ Firebase initialization failed: $e');
    }
    // Continue without Firebase for now
  }

  // Initialize providers
  final authProvider = AuthProvider();
  final groupProvider = GroupProvider();
  final eventProvider = EventProvider();
  final pointsProvider = PointsProvider();
  final localeProvider = LocaleProvider();
  final restaurantProvider = RestaurantProvider();
  // final chatProvider = ChatProvider(); // Temporarily disabled

  // Initialize providers
  await authProvider.initialize();
  await localeProvider.initialize();

  // Load other data
  await groupProvider.loadGroups();
  await eventProvider.loadEvents();
  await pointsProvider.loadPoints();
  // await chatProvider.loadMessages(); // Temporarily disabled

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider<GroupProvider>.value(value: groupProvider),
        ChangeNotifierProvider<EventProvider>.value(value: eventProvider),
        ChangeNotifierProvider<PointsProvider>.value(value: pointsProvider),
        ChangeNotifierProvider<LocaleProvider>.value(value: localeProvider),
        ChangeNotifierProvider<RestaurantProvider>.value(
            value: restaurantProvider),
        // ChangeNotifierProvider<ChatProvider>.value(value: chatProvider), // Temporarily disabled
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
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,

          theme: ThemeData(
            brightness: Brightness.dark,
            colorSchemeSeed: Colors.teal,
            useMaterial3: true,
            // Optimierte Eingabefelder
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.grey.withValues(alpha: 0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
