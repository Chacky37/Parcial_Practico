
import 'package:app_perceptron_ia/Screens/visualizacion_json.dart' as enlace_;
import 'package:app_perceptron_ia/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Necesario antes de Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false, // Oculta la banderita de debug
      title: 'App Perceptron',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const enlace_.VistaJson(), // 👈 Aquí tu pantalla inicial
    ),
  );
}
