import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'constants.dart';
import 'models/order.dart';
import 'providers/approvals_provider.dart';
import 'screens/login_screen.dart';
import 'screens/flow_selection_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/order_details_screen.dart';
import 'services/download_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DownloadService.init();
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
            brightness: Brightness.light,
            background: JLWColors.darkBg,
            surface: JLWColors.cardBg,
          ),
          scaffoldBackgroundColor: JLWColors.darkBg,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: JLWColors.textDark,
            elevation: 0,
          ),
        ),
        initialRoute: '/login',
        onGenerateRoute: (settings) {
          if (settings.name == '/login') {
            return MaterialPageRoute(
              builder: (context) => LoginScreen(
                onLoginSuccess: () {
                  Navigator.pushReplacementNamed(context, '/flow-selection');
                },
              ),
            );
          }

          if (settings.name == '/flow-selection') {
            return MaterialPageRoute(
              builder: (context) => FlowSelectionScreen(
                onFlowSelected: (flow) {
                  Provider.of<ApprovalsProvider>(context, listen: false)
                      .setFlow(flow);
                  Navigator.pushReplacementNamed(context, '/dashboard');
                },
                onLogout: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/login',
                    (route) => false,
                  );
                },
              ),
            );
          }

          if (settings.name == '/dashboard') {
            return MaterialPageRoute(
              builder: (context) => DashboardScreen(
                onOrderSelect: (OrderModel order) {
                  Navigator.pushNamed(context, '/details', arguments: order);
                },
                onSwitchDashboard: () {
                  Navigator.pushReplacementNamed(context, '/flow-selection');
                },
                onLogout: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/login',
                    (route) => false,
                  );
                },
              ),
            );
          }

          if (settings.name == '/details') {
            final order = settings.arguments as OrderModel;
            return MaterialPageRoute(
              builder: (context) => OrderDetailsScreen(
                order: order,
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
