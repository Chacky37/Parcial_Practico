import 'dart:math';

void main() {
  // Crear matrices de ejemplo
  List<Map<String, double>> matrizValores = [
    {'v_00': 1.0, 'v_01': 2.0, 'v_02': 3.0},
    {'v_10': 4.0, 'v_11': 5.0, 'v_12': 6.0},
    {'v_20': 7.0, 'v_21': 8.0, 'v_22': 9.0},
  ];

  List<Map<String, double>> matrizPesos = [
    {'w_00': 0.5},
    {'w_10': 0.25},
    {'w_20': -0.1},
  ];

  List<Map<String, double>> matrizUmbral = [
    {'u_00': 0.0},
    {'u_10': 0.0},
    {'u_20': 0.0},
  ];

  // Convertir Map a List<List<double>>
  List<List<double>> valores = matrizValores
      .map((m) => m.values.map((e) => e.toDouble()).toList())
      .toList();

  List<List<double>> pesos = matrizPesos
      .map((m) => m.values.map((e) => e.toDouble()).toList())
      .toList();

  List<double> resultados = [];

  // Calcular la salida
  for (int i = 0; i < valores.length; i++) {
    double suma = 0;

    for (int j = 0; j < valores[i].length; j++) {
      // multiplicar valor de la fila por el peso correspondiente de la columna
      suma += valores[i][j] * pesos[j][0];
      print(suma);
    }

    resultados.add(suma);
  }

  // Imprimir matrices y resultados
  print('Matriz Valores:');
  print(valores);
  print('\nMatriz Pesos:');
  print(pesos);
  print('\nResultados:');
  print(resultados);
}
