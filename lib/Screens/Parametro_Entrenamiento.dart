import 'package:app_perceptron_ia/Screens/Resultado_final.dart';
import 'package:app_perceptron_ia/Controllers/perceptron_controllers.dart' as enlace;
import 'package:flutter/material.dart';

class ParametrosEntrenamiento extends StatefulWidget {
  final int idRadioButton;

  const ParametrosEntrenamiento({super.key, required this.idRadioButton});

  @override
  State<ParametrosEntrenamiento> createState() =>
      _ParametrosEntrenamientoState();
}

class _ParametrosEntrenamientoState extends State<ParametrosEntrenamiento> {
  final _formKey = GlobalKey<FormState>();

  final _porcentajeDatosCtrl = TextEditingController();
  final _iteracionesCtrl = TextEditingController();
  final _errorMaximoCtrl = TextEditingController();
  final _tasaAprendizajeCtrl = TextEditingController();

  InputDecoration _decoracionCampo(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.blue.shade50, // Fondo azul claro
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Parámetros de entrenamiento"),
        backgroundColor: Colors.blue.shade600,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                )
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Parametros",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),

                  const SizedBox(height: 20),

                  TextFormField(
                    controller: _porcentajeDatosCtrl,
                    decoration: _decoracionCampo("% de datos"),
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        v == null || v.isEmpty ? "Ingrese un valor" : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _iteracionesCtrl,
                    decoration: _decoracionCampo("Cantidad de iteraciones"),
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        v == null || v.isEmpty ? "Ingrese un valor" : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _errorMaximoCtrl,
                    decoration: _decoracionCampo("Error máximo"),
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        v == null || v.isEmpty ? "Ingrese un valor" : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _tasaAprendizajeCtrl,
                    decoration: _decoracionCampo("Tasa de aprendizaje"),
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        v == null || v.isEmpty ? "Ingrese un valor" : null,
                  ),

                  const SizedBox(height: 25),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          try {
                            final _controlador = enlace.Controlador();
                            final mensaje = await _controlador.validarYProcesar(
                              idRadioButton: widget.idRadioButton,
                              porcentajeDatos: int.parse(_porcentajeDatosCtrl.text),
                              cantidadIteraciones: int.parse(_iteracionesCtrl.text),
                              errorMaximo: double.parse(_errorMaximoCtrl.text),
                              tasaAprendizaje: double.parse(_tasaAprendizajeCtrl.text),
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VistaFinal(resultado: mensaje),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error al procesar datos: $e')),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Por favor, complete todos los campos correctamente.')),
                          );
                        }
                      },
                      child: const Text("Siguiente",
                          style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
