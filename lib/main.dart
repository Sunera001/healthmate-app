import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'features/health_records/providers/health_provider.dart';
import 'features/health_records/screens/dashboard_screen.dart';

void main() {
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HealthMateApp());
}

class HealthMateApp extends StatelessWidget {
  const HealthMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HealthProvider()..loadRecords(),
      child: MaterialApp(
        title: 'HealthMate',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.teal),
        home: const DashboardScreen(),
      ),
    );
  }
}
