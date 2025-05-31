import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/iot_provider.dart';
import 'screens/dashboard_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => IoTProvider(),
      child: MaterialApp(
        title: 'IoT Monitor',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: DashboardScreen(),
      ),
    );
  }
}