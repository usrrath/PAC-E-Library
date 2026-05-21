import 'package:flutter/material.dart';

import 'apps/app_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppProvider.init();

  runApp(const AppProvider());
}