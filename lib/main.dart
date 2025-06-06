import 'package:flutter/material.dart';
import 'package:fvp/fvp.dart' as fvp;

import 'app.dart';
 
void main() async {
  fvp.registerWith();
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const App());
}
