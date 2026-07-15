import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'config/flavor_config.dart';
import 'main.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env.prod');
  FlavorConfig(
    flavor: Flavor.prod,
    baseUrl: dotenv.env['BASE_URL']!,
  );
  runApp(const JLWApprovalsApp());
}
