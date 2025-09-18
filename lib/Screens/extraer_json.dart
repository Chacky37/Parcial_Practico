import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:app_perceptron_ia/Controllers/perceptron_controllers.dart';

class VistaArchivos extends StatefulWidget {
  const VistaArchivos({super.key});

  @override
  State<VistaArchivos> createState() => _VistaArchivosState();
}

class _VistaArchivosState extends State<VistaArchivos> {
  String resultado = "";
  bool cargando = false;

  Future<void> _seleccionarArchivo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null) {
      final fileBytes = result.files.single.bytes;
      final fileName = result.files.single.name;

      if (fileBytes != null) {
        setState(() {
          cargando = true;
          resultado = "";
        });

        final controlador = Controlador();

        try {
          final numCampos = await controlador.procesarArchivo(fileBytes, fileName);

          setState(() {
            resultado = "Archivo $fileName procesado con $numCampos campos.";
            cargando = false;
          });
        } catch (e) {
          setState(() {
            resultado = "Error: $e";
            cargando = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Subir JSON a Firebase"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.blue.shade100],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: cargando ? null : _seleccionarArchivo,
                  icon: const Icon(Icons.upload_file, size: 28),
                  label: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 8),
                    child: Text(
                      "Seleccionar archivo JSON",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  padding: const EdgeInsets.all(16),
                  width: MediaQuery.of(context).size.width * 0.8,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: cargando
                      ? Column(
                          children: const [
                            CircularProgressIndicator(),
                            SizedBox(height: 10),
                            Text("Procesando archivo..."),
                          ],
                        )
                      : Text(
                          resultado.isEmpty ? "Ningún archivo seleccionado" : resultado,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
