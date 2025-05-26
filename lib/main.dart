import 'package:bill_app/home.dart';
import 'package:bill_app/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://nsafhbqhwvekdxujxlxe.supabase.co',
    anonKey:
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5zYWZoYnFod3Zla2R4dWp4bHhlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDgwMDcwNjEsImV4cCI6MjA2MzU4MzA2MX0.m4jaCdPi8rBXTHLXe4CuLPxf-kevWmfFtfGh_E5rmB8',  );

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(BillApp());
}

class BillApp extends StatelessWidget {
  const BillApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, data) {
            if (data.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(
                color: Colors.black,
              ));
            }

            if (FirebaseAuth.instance.currentUser != null) {
              return HomePage();
            }
            return LoginPage();
          }),
    );
  }
}
