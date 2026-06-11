import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'constants.dart';
import 'providers/approvals_provider.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/order_details_screen.dart';

void main() {
  runApp(const JLWApprovalsApp());
}

class JLWApprovalsApp extends StatelessWidget {
  const JLWApprovalsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ApprovalsProvider()),
      ],
      child: MaterialApp(
        title: 'JLW Approvals',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: JLWColors.mintAccent,
            brightness: Brightness.dark,
            background: JLWColors.darkBg,
            surface: JLWColors.cardBg,
          ),
          scaffoldBackgroundColor: JLWColors.darkBg,
          appBarTheme: const AppBarTheme(
            backgroundColor: JLWColors.darkBg,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
        ),
        initialRoute: '/login',
        onGenerateRoute: (settings) {
          if (settings.name == '/login') {
            return MaterialPageRoute(
              builder: (context) => LoginScreen(
                onLoginSuccess: () {
                  Navigator.pushReplacementNamed(context, '/dashboard');
                },
              ),
            );
          }

          if (settings.name == '/dashboard') {
            return MaterialPageRoute(
              builder: (context) => DashboardScreen(
                onOrderSelect: (orderId) {
                  Navigator.pushNamed(context, '/details', arguments: orderId);
                },
                onLogout: () {
                  final provider =
                      Provider.of<ApprovalsProvider>(context, listen: false);
                  provider.logout();
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),
            );
          }

          if (settings.name == '/details') {
            final orderId = settings.arguments as String;
            return MaterialPageRoute(
              builder: (context) => OrderDetailsScreen(
                orderId: orderId,
                onBack: () {
                  Navigator.pop(context);
                },
              ),
            );
          }

          // Fallback route mapping safely
          return MaterialPageRoute(
            builder: (context) => Scaffold(
              backgroundColor: JLWColors.darkBg,
              body: Center(
                child: Text(
                  'Route ${settings.name} not found',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
