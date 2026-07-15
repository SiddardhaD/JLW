import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'config/flavor_config.dart';
import 'main.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env.dev');
  FlavorConfig(
    flavor: Flavor.dev,
    baseUrl: dotenv.env['BASE_URL']!,
  );
  runApp(const JLWApprovalsApp());
}
