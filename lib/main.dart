import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:queuetrack/screens/Authentication/role_selection.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'firebase_options.dart'; // Your Firebase generated config

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize('fb4a4b27-a6d7-44d4-ab55-d418d082ba74');
  await OneSignal.Notifications.requestPermission(true);

  runApp(const QueueTrackApp());
}


class QueueTrackApp extends StatelessWidget {
  const QueueTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'QueueTrack',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/roleselection', // ✅ Start with login page
      routes: {
        '/roleselection': (_) => const RoleSelection(),
        // dashboards we’ll navigate to manually
      },
    );
  }
}
