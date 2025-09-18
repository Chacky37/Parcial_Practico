import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class VistaFinal extends StatelessWidget {
  final Map<String, dynamic> resultado;

  const VistaFinal({super.key, required this.resultado});

  @override
  Widget build(BuildContext context) {
    final coleccion = resultado["coleccion"];
    final entradas = resultado["entradas"] as List<String>;
    final cantidad_entradas = resultado["numero entradas"];
    final salidas = resultado["salidas"] as List<String>;
    final cantidad_salidas = resultado["numero salidas"];
    final totalPatrones = resultado["cantidad_de_patrones_antiguo"];
    final cantidadFilasUsar = resultado["nueva_cantidad_patrones"];
    final cantidad_interanciones_final = resultado["cantidad_interanciones_final"];
    final cantidadIteraciones = resultado["cantidadIteraciones"];
    final errorMaximo = resultado["errorMaximo"];
    final tasaAprendizaje = resultado["tasaAprendizaje"];
    final List<double> puntos = List<double>.from(resultado["listado_puntos"]);

    final List<FlSpot> spots = List.generate(
      puntos.length,
      (i) => FlSpot(i.toDouble() + 1, puntos[i]),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Vista Final"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        color: Colors.blue.shade50,
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _seccionInformacion(
                "Información General",
                [
                  "Colección: $coleccion",
                  "Entradas: ${entradas.join(", ")}",
                  "Cantidad de Entradas: $cantidad_entradas",
                  "Salidas: ${salidas.join(", ")}",
                  "Cantidad de Salidas: $cantidad_salidas",
                  "Total de patrones: $totalPatrones",
                  "Nueva cantidad de patrones: $cantidadFilasUsar",
                  "Iteraciones inicial: $cantidadIteraciones",
                  "Error máximo: $errorMaximo",
                  "Tasa de aprendizaje: $tasaAprendizaje",
                  "Cantidad de interacion final: $cantidad_interanciones_final",
                ],
              ),
              _seccionGrafico(spots),
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
            Text(
              titulo,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
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
            height: 300,
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
                      interval: 1, // 🔹 cada punto = 1 iteración
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
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toStringAsFixed(2), // 🔹 muestra el error real
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                minX: 1,
                maxX: spots.length.toDouble(), // 🔹 ajusta al número de iteraciones
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.grey.shade400),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: false,
                    barWidth: 2,
                    dotData: FlDotData(show: true),
                    color: Colors.blueAccent,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _seccionDatosSeleccionados(List<Map<String, dynamic>> datos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Datos seleccionados",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ...datos.map((fila) {
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.symmetric(vertical: 4),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: fila.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text("${entry.key}: ${entry.value}"),
                    );
                  }).toList(),
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}
