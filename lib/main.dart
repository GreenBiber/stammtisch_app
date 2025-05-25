import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'providers/group_provider.dart';
import 'providers/event_provider.dart';
import 'screens/group_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final groupProvider = GroupProvider();
  await groupProvider.loadGroups();

  final eventProvider = EventProvider();
  await eventProvider.loadEvents();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<GroupProvider>.value(value: groupProvider),
        ChangeNotifierProvider<EventProvider>.value(value: eventProvider),
      ],
      child: const StammtischApp(),
    ),
  );
}

class StammtischApp extends StatelessWidget {
  const StammtischApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stammtisch App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.teal,
        useMaterial3: true,
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('de'),
        Locale('en'),
      ],
      home: const GroupScreen(),
    );
  }
}
