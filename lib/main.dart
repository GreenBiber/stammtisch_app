import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'l10n/l10n.dart';
import 'providers/auth_provider.dart';
import 'providers/group_provider.dart';
import 'providers/event_provider.dart';
import 'providers/points_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/restaurant_provider.dart';
import 'providers/notification_provider.dart';
// import 'providers/chat_provider.dart';
import 'services/firebase_service.dart';
import 'screens/auth/auth_wrapper.dart';

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('📱 Background message received: ${message.notification?.title}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from root directory (with error handling)
  try {
    await dotenv.load(fileName: ".env");
    debugPrint('✅ Environment variables loaded successfully');
  } catch (e) {
    debugPrint(
        '⚠️ Warning: .env file not found or could not be loaded. Using default values.');
    debugPrint('Error details: $e');
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
      debugPrint('✅ Firebase initialized successfully');
    } else {
    }
    
    // Initialize Firebase Service
    await FirebaseService().initialize();
    
    // Setup background message handler for Firebase Messaging
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  } catch (e) {
    // Check for specific duplicate app error
    if (e.toString().contains('duplicate-app') || e.toString().contains('already exists')) {
      // Try to initialize Firebase Service anyway
      try {
        await FirebaseService().initialize();
      } catch (serviceError) {
        debugPrint('⚠️ Firebase Service initialization skipped: $serviceError');
      }
    } else {
      debugPrint('❌ Firebase initialization failed: $e');
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
  final notificationProvider = NotificationProvider();
  // final chatProvider = ChatProvider(); // Temporarily disabled

  // Initialize providers
  await authProvider.initialize();
  await localeProvider.initialize();
  
  // Initialize notification provider with error handling
  try {
    await notificationProvider.initialize();
    debugPrint('✅ Notification Provider initialized successfully');
  } catch (e) {
    debugPrint('⚠️ Notification Provider initialization failed: $e');
    debugPrint('ℹ️ App will continue without push notifications');
    // Continue app execution even if notifications fail
  }

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
        ChangeNotifierProvider<NotificationProvider>.value(
            value: notificationProvider),
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
