import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:app_perceptron_ia/Controllers/perceptron_controllers.dart' as enlace;

class VistaEntrenamientoFinal extends StatefulWidget {
  final int idRadioButton;

  const VistaEntrenamientoFinal({super.key, required this.idRadioButton});

  @override
  State<VistaEntrenamientoFinal> createState() => _VistaEntrenamientoFinalState();
}

class _VistaEntrenamientoFinalState extends State<VistaEntrenamientoFinal> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para parámetros
  final _porcentajeDatosCtrl = TextEditingController();
  final _iteracionesCtrl = TextEditingController();
  final _errorMaximoCtrl = TextEditingController();
  final _tasaAprendizajeCtrl = TextEditingController();

  Map<String, dynamic>? _resultado; // 🔹 Aquí guardaremos el resultado del controlador
  List<FlSpot> _spots = [];

  InputDecoration _decoracionCampo(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.blue.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  Future<void> _procesarDatos() async {
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

        final List<double> puntos = List<double>.from(mensaje["listado_puntos"]);
        setState(() {
          _resultado = mensaje;
          _spots = List.generate(
            puntos.length,
            (i) => FlSpot(i.toDouble() + 1, puntos[i]),
          );
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al procesar datos: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Entrenamiento y Resultados"),
        backgroundColor: Colors.blue.shade600,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 🔹 Formulario de parámetros
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const Text("Parámetros de Entrenamiento",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                        const SizedBox(height: 20),
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
                            onPressed: _procesarDatos,
                            child: const Text("Procesar",
                                style: TextStyle(fontSize: 16, color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 🔹 Resultados
              if (_resultado != null) ...[
                _seccionInformacion("Información General", [
                  "Colección: ${_resultado!["coleccion"]}",
                  "Entradas: ${(_resultado!["entradas"] as List).join(", ")}",
                  "Cantidad de Entradas: ${_resultado!["numero entradas"]}",
                  "Salidas: ${(_resultado!["salidas"] as List).join(", ")}",
                  "Cantidad de Salidas: ${_resultado!["numero salidas"]}",
                  "Total de patrones: ${_resultado!["cantidad_de_patrones_antiguo"]}",
                  "Nueva cantidad de patrones: ${_resultado!["nueva_cantidad_patrones"]}",
                  "Iteraciones inicial: ${_resultado!["cantidadIteraciones"]}",
                  "Error máximo: ${_resultado!["errorMaximo"]}",
                  "Tasa de aprendizaje: ${_resultado!["tasaAprendizaje"]}",
                  "Cantidad de interacción final: ${_resultado!["cantidad_interanciones_final"]}",
                ]),
                _seccionGrafico(_spots),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _seccionInformacion(String titulo, List<String> datos) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(color: Colors.blueAccent),
            ...datos.map((d) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Text(d),
                )),
          ],
        ),
      ),
    );
  }

 Widget _seccionGrafico(List<FlSpot> spots) {
  const double chartHeight = 300;

  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    elevation: 4,
    margin: const EdgeInsets.symmetric(vertical: 8),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Gráfico de Error vs Iteraciones",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: chartHeight,
            child: LayoutBuilder(builder: (context, constraints) {
              final double width = constraints.maxWidth;

              // --- Si necesitas, ajusta estos valores para que coincidan con tus títulos/reservados
              const double leftReserved = 40; // coincide con leftTitles.reservedSize
              const double bottomReserved = 30; // coincide con bottomTitles.reservedSize
              const double topReserved = 16;
              const double rightReserved = 16;

              final double minX = 1;
              final double maxX = spots.isNotEmpty ? spots.length.toDouble() : 1;
              final double minY = 0;
              final double maxY = spots.isNotEmpty
                  ? (spots.map((e) => e.y).reduce((a, b) => a > b ? a : b) * 1.1)
                  : 1;

              // Prevenciones contra división por cero
              final double dx = (maxX - minX).abs() < 1e-9 ? 1.0 : (maxX - minX);
              final double dy = (maxY - minY).abs() < 1e-9 ? 1.0 : (maxY - minY);

              final double chartWidth = width - leftReserved - rightReserved;
              final double chartInnerHeight = chartHeight - topReserved - bottomReserved;

              return Stack(
                children: [
                  // Línea base: el gráfico
                  SizedBox(
                    width: width,
                    height: chartHeight,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(show: true, drawVerticalLine: true),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            axisNameWidget: const Text("Iteraciones",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14)),
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 1,
                              reservedSize: bottomReserved,
                              getTitlesWidget: (value, meta) {
                                if (value % 1 == 0) {
                                  return Text(
                                    value.toInt().toString(),
                                    style: const TextStyle(fontSize: 10),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            axisNameWidget: const Text("Error",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14)),
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: leftReserved,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value.toStringAsFixed(2),
                                  style: const TextStyle(fontSize: 10),
                                );
                              },
                            ),
                          ),
                          rightTitles:
                              AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles:
                              AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        minX: minX,
                        maxX: maxX,
                        minY: minY,
                        maxY: maxY,
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(color: Colors.grey.shade400),
                        ),

                        // No queremos tooltips interactivos
                        lineTouchData: LineTouchData(enabled: false),

                        lineBarsData: [
                          LineChartBarData(
                            spots: spots,
                            isCurved: false,
                            barWidth: 2,
                            color: Colors.blueAccent,
                            belowBarData: BarAreaData(
                              show: true,
                              color: Colors.blueAccent.withOpacity(0.3),
                            ),
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) {
                                return FlDotCirclePainter(
                                  radius: 3,
                                  color: Colors.blueAccent,
                                  strokeWidth: 0,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Overlay: etiquetas fijas sobre cada punto
                  for (int i = 0; i < spots.length; i++) ...[
                    Builder(builder: (_) {
                      final FlSpot s = spots[i];
                      final double xPercent = ((s.x - minX) / dx).clamp(0.0, 1.0);
                      final double yPercent = ((s.y - minY) / dy).clamp(0.0, 1.0);

                      final double px = leftReserved + xPercent * chartWidth;
                      final double py = topReserved + (1 - yPercent) * chartInnerHeight;

                      // Ajustes para centrar la etiqueta sobre el punto
                      const double labelWidth = 48;
                      const double labelHeight = 18;
                      final double left = (px - labelWidth / 2).clamp(0.0, width - labelWidth);
                      final double top = (py - labelHeight - 6).clamp(0.0, chartHeight - labelHeight);

                      return Positioned(
                        left: left,
                        top: top,
                        child: Container(
                          width: labelWidth,
                          height: labelHeight,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 2,
                                offset: const Offset(0, 1),
                              )
                            ],
                          ),
                          child: Text(
                            s.y.toStringAsFixed(2),
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }),
                  ],
                ],
              );
            }),
          ),
        ],
      ),
    ),
  );
}
}