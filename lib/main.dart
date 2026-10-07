import 'package:flutter/material.dart';

import 'app/app.dart';

export 'app/app.dart' show WealthFlowApp;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const WealthFlowApp());
}
