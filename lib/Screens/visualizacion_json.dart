import 'package:app_perceptron_ia/Screens/Parametro_Entrenamiento.dart';
import 'package:app_perceptron_ia/Screens/extraer_json.dart';
import 'package:app_perceptron_ia/Screens/pruebba.dart';
import 'package:flutter/material.dart';
import 'package:app_perceptron_ia/Controllers/perceptron_controllers.dart';

class VistaJson extends StatefulWidget {
  const VistaJson({super.key});

  @override
  State<VistaJson> createState() => _VistaJsonState();
}

class _VistaJsonState extends State<VistaJson> {
  final Controlador _controlador = Controlador();

  String? _coleccionSeleccionada;
  List<Map<String, dynamic>> _datos = [];
  bool _cargando = false;

  final List<String> _coleccionesDisponibles = [
    "dataset1_3entradas",
    "dataset2_4entradas",
    "dataset3_academico"
  ];

  Future<void> _cargarDatos(String coleccion) async {
    setState(() {
      _cargando = true;
      _datos = [];
    });

    try {
      final data = await _controlador.obtenerDatosMatriz(coleccion);
      setState(() {
        _datos = data;
        _cargando = false;
      });
    } catch (e) {
      setState(() => _cargando = false);
      debugPrint("Error cargando datos: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al cargar datos")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final columnas = _datos.isNotEmpty
        ? _datos.expand((e) => e.keys).toSet().toList()
        : <String>[];

    return Scaffold(
      appBar: AppBar(title: const Text("Consultar colecciones")),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // 🔹 Selección de colección
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    const Text(
                      "Seleccione una colección",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    ..._coleccionesDisponibles.map((coleccion) {
                      return RadioListTile<String>(
                        title: Text(coleccion),
                        value: coleccion,
                        groupValue: _coleccionSeleccionada,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _coleccionSeleccionada = value);
                            _cargarDatos(value);
                          }
                        },
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),

            const Divider(),

            // 🔹 Tabla de datos
            Expanded(
              child: _cargando
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 12),
                          Text("Cargando datos..."),
                        ],
                      ),
                    )
                  : _datos.isEmpty
                      ? const Center(child: Text("No hay datos para mostrar"))
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: DataTable(
                              headingRowColor: MaterialStateProperty.all(
                                Colors.blue.shade100,
                              ),
                              border: TableBorder.all(
                                  color: Colors.grey.shade400),
                              columns: columnas
                                  .map((col) => DataColumn(
                                        label: Text(
                                          col,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ))
                                  .toList(),
                              rows: _datos.map((fila) {
                                return DataRow(
                                  cells: columnas.map((col) {
                                    return DataCell(
                                      Text(fila[col]?.toString() ?? ""),
                                    );
                                  }).toList(),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
            ),

            const Divider(),

            // 🔹 Botones inferiores
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  // Botón Añadir JSON
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text("Añadir JSON"),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const VistaArchivos(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: const Color.fromARGB(255, 98, 188, 231),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Botón Siguiente
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text("Siguiente"),
                      onPressed: _coleccionSeleccionada == null
                          ? null
                          : () {
                              final idRadioButton =
                                  _coleccionesDisponibles.indexOf(
                                          _coleccionSeleccionada!) +
                                      1;

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      VistaEntrenamientoFinal(
                                    idRadioButton: idRadioButton,
                                  ),
                                ),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
