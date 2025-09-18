import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:app_perceptron_ia/Models/perceptron_models.dart';

class Controlador {
  final ModeloFirebase _modelo = ModeloFirebase();
  final Random _random = Random();

  //Selecciona los archivo
  Future<int> procesarArchivo(Uint8List fileBytes, String fileName) async {
    try {
      // 1. Convertir bytes a String
      String contenido = String.fromCharCodes(fileBytes);

      // 2. Parsear el JSON
      final dynamic data = jsonDecode(contenido);

      // 3. Extraer el nombre del archivo (sin extensión)
      String nombreColeccion = fileName.split('.').first;

      // 4. Guardar en Firestore en la colección con nombre igual al nombre del archivo
      await _modelo.guardarJsonEnNuevaColeccion(data, nombreColeccion);

      // Si data es lista, devolver cantidad, si es único JSON devolver 1
      if (data is List) {
        return data.length;
      } else {
        return 1;
      }
    } catch (e) {
      throw Exception("Error al procesar el archivo $fileName: $e");
    }
  }
  
  Future<List<Map<String, dynamic>>> obtenerDatosMatriz(String nombreColeccion) async {
    return await _modelo.guardarinformacionDatosMatriz(nombreColeccion);
  }

  // 🔹 Función principal: valida los parámetros antes de procesar los datos
Future<Map<String, dynamic>> validarYProcesar({
  required int idRadioButton,
  required int porcentajeDatos,
  required int cantidadIteraciones,
  required double errorMaximo,
  required double tasaAprendizaje,
}) async {
  // Validación: El porcentaje de datos debe ser múltiplo de 10
  if (porcentajeDatos % 10 != 0) {
    throw Exception("El porcentaje de datos debe ser divisible entre 10");
  }

  // Validación: El error máximo permitido debe estar en el rango (0 - 0.1)
  if (errorMaximo < 0 || errorMaximo > 0.1) {
    throw Exception("El error máximo debe estar entre 0 y 0.1");
  }

  // Validación: La tasa de aprendizaje debe estar entre (0 - 1]
  if (tasaAprendizaje <= 0 || tasaAprendizaje > 1) {
    throw Exception("La tasa de aprendizaje debe estar entre 0 y 1, sin incluir 0");
  }

  // Si todas las validaciones pasan, se llama a procesarDatos
  return await procesarDatos(
    idRadioButton: idRadioButton,
    porcentajeDatos: porcentajeDatos,
    cantidadIteraciones: cantidadIteraciones,
    errorMaximo: errorMaximo,
    tasaAprendizaje: tasaAprendizaje,
  );
}

// 🔹 Procesa los datos según la colección seleccionada y los parámetros dados
Future<Map<String, dynamic>> procesarDatos({
  required int idRadioButton,
  required int porcentajeDatos,
  required int cantidadIteraciones,
  required double errorMaximo,
  required double tasaAprendizaje,
}) async {
  // 1. Determinar la colección en función del radio button seleccionado
  String coleccion;
  if (idRadioButton == 1) {
    coleccion = "dataset1_3entradas";
  } else if (idRadioButton == 2) {
    coleccion = "dataset2_4entradas";
  } else if (idRadioButton == 3) {
    coleccion = "dataset3_academico";
  } else {
    throw Exception("ERROR: idRadioButton inválido");
  }

  // 2. Obtener datos desde la colección seleccionada
  final List<Map<String, dynamic>> datos = await obtenerDatosMatriz(coleccion);

  // Si no hay datos en la colección, retornar estructura vacía
  if (datos.isEmpty) {
    return {
      "coleccion": coleccion,
      "entradas": [],
      "salidas": [],
      "totalPatrones": 0,
      "datosSeleccionados": [],
      "cantidadFilasUsar": 0,
    };
  }

  // 3. Identificar entradas y salidas del dataset
  final todasLasClaves = datos.first.keys.toList();

  // Variables de entrada (todo lo que no sea salida, aprueba o index)
  final entradas = todasLasClaves
      .where((clave) =>
          clave.toLowerCase() != "salida" &&
          clave.toLowerCase() != "aprueba" &&
          clave.toLowerCase() != "index")
      .toList();

  // Variables de salida (solo "salida" o "aprueba")
  final salidas = todasLasClaves
      .where((clave) =>
          (clave.toLowerCase() == "salida" ||
           clave.toLowerCase() == "aprueba") &&
          clave.toLowerCase() != "index")
      .toList();

  final countEntradas = entradas.length;
  final countSalidas = salidas.length;

  // 4. Contar patrones (filas del dataset)
  final totalPatrones = datos.length;

  // 5. Calcular cuántas filas usar en base al porcentaje indicado
  final cantidadFilasUsar = (totalPatrones * (porcentajeDatos / 100)).floor();
  final datosSeleccionados = datos.take(cantidadFilasUsar).toList();

  // 6. Verificar si ya existen pesos y umbral en Firebase
  final pesosExistentes = await _modelo.obtenerDatosPesos(coleccion);
  final umbralExistente = await _modelo.obtenerDatosUmbral(coleccion);

  // Si no existen pesos ni umbral, los generamos y guardamos
  if (pesosExistentes.isEmpty || umbralExistente.isEmpty) {
    await generarMatrizPesosyUmbral(countEntradas, countSalidas, coleccion);
  }

  // 7. Entrenar el modelo → calcular salidas usando perceptrón
  List<double> pasar_salida = await calcularSalida(
    nombreColeccion: coleccion,
    matrizFiltrada: datosSeleccionados,
    alfa: tasaAprendizaje,
    q_interaciones: cantidadIteraciones,
    maximo_error_permitido: errorMaximo,
  );

  int cantidadElementos = pasar_salida.length;

  // 8. Retornar resultados como mapa
  return {
    "coleccion": coleccion,
    "entradas": entradas,
    "numero entradas": countEntradas,
    "salidas": salidas,
    "numero salidas": countSalidas,
    "cantidad_de_patrones_antiguo": totalPatrones,
    "nueva_cantidad_patrones": cantidadFilasUsar,
    "cantidad_interanciones_final": cantidadElementos,
    "listado_puntos": pasar_salida,
    "cantidadIteraciones": cantidadIteraciones,
    "errorMaximo": errorMaximo,
    "tasaAprendizaje": tasaAprendizaje,
  };
}


  Future<void> generarMatrizPesosyUmbral(
    int countEntradas, int countSalidas, String nombreColeccion) async {
  // -------------------------------
  // Matriz completa: entradas x salidas
  // -------------------------------
   List<List<double>> matrizCompleta = [];

   for (int i = 0; i < countEntradas; i++) {
    List<double> fila = [];
    for (int j = 0; j < countSalidas; j++) {
      double valor = -1 + _random.nextDouble() * 2; // Aleatorio entre -1 y 1
      double valorConDosDecimales = double.parse(valor.toStringAsFixed(2));
      fila.add(valorConDosDecimales);
    }
    matrizCompleta.add(fila);
  }

  List<Map<String, dynamic>> matrizpeso = [];
  for (int i = 0; i < matrizCompleta.length; i++) {
    Map<String, dynamic> filaMap = {};
    for (int j = 0; j < matrizCompleta[i].length; j++) {
      filaMap['w_$i$j'] = matrizCompleta[i][j];
    }
    matrizpeso.add(filaMap);
  }

  // -------------------------------
  // Matriz solo salidas: salidas x 1
  // -------------------------------
  List<List<double>> matrizSalidas = [];
  for (int i = 0; i < countSalidas; i++) {
    double valor = -1 + _random.nextDouble() * 2;
    double valorConDosDecimales = double.parse(valor.toStringAsFixed(2));
    matrizSalidas.add([valorConDosDecimales]);
  }

  List<Map<String, dynamic>> matrizumbral = [];
  for (int i = 0; i < matrizSalidas.length; i++) {
    Map<String, dynamic> filaMap = {};
    filaMap['u_${i}0'] = matrizSalidas[i][0];
    matrizumbral.add(filaMap);
  }

  // -------------------------------
  // Guardar ambas matrices en Firebase
  // -------------------------------
  await _modelo.guardarMatrizPesos(matrizpeso, nombreColeccion);
  await _modelo.guardarMatrizUmbral(matrizumbral, nombreColeccion);
 
    }


Future<List<double>> calcularSalida({
  required String nombreColeccion,
  required List<Map<String, dynamic>> matrizFiltrada,
  required double alfa,
  required int q_interaciones,
  required double maximo_error_permitido,
}) async {
  //  Obtener los pesos y el umbral almacenados en Firebase
  final datosMatrizPeso = await _modelo.obtenerDatosPesos(nombreColeccion);
  final datosDeMatrizUmbral = await _modelo.obtenerDatosUmbral(nombreColeccion);

  //  Lista para almacenar los errores RMS de cada ciclo
  List<double> erroresPorCiclo = [];

  //  Convertir los pesos recuperados en una matriz de doubles
  List<List<double>> matrizPesos = datosMatrizPeso
      .map((map) => map.values.map((e) => e as double).toList())
      .toList();

  //  Convertir el umbral recuperado en un vector de doubles
  List<double> umbral = datosDeMatrizUmbral
      .expand((map) => map.values.map((e) => e as double))
      .toList();

  //  Construir la matriz de entradas eliminando columnas irrelevantes
  List<List<double>> matrizFinalDatosSeleccionados = matrizFiltrada.map((map) {
    return map.entries
        .where((e) =>
            e.key != 'index' && e.key != 'salida' && e.key != 'aprueba')
        .map((e) => (e.value as num).toDouble())
        .toList();
  }).toList();

  //  Número de entradas y tamaño del dataset
  int nEntradas = matrizFinalDatosSeleccionados[0].length;
  int datasetLength = matrizFinalDatosSeleccionados.length;

  //  Función que calcula la salida neta del perceptrón (suma ponderada - umbral)
  double salida(List<double> entrada) {
    double suma = 0;
    for (int k = 0; k < nEntradas; k++) {
      suma += entrada[k] * matrizPesos[k][0];
    }
    return suma - umbral[0];
  }

  //  Función de activación (umbral: devuelve 1 si es >= 0, sino 0)
  int funcionActivacion(double valor) => valor >= 0 ? 1 : 0;

  //  Vector de salidas esperadas (se toma "salida" o "aprueba")
  List<int> datasetSalidas = matrizFiltrada
      .map<int>((map) {
        final valor = map['salida'] ?? map['aprueba'];
        return (valor ?? 0 as num).toInt();
      })
      .toList();

  //  Bucle principal de entrenamiento (hasta q_interaciones o alcanzar el error permitido)
  for (int iter = 0; iter < q_interaciones; iter++) {
    double sumaErrorCuadrado = 0;

    //  Recorre cada ejemplo del dataset
    for (int i = 0; i < datasetLength; i++) {
      // Calcular salida neta y aplicar función de activación
      double salidaReal = salida(matrizFinalDatosSeleccionados[i]);
      int salidaPredicha = funcionActivacion(salidaReal);

      // Calcular error: esperado - predicho
      int error = datasetSalidas[i] - salidaPredicha;

      // Ajustar pesos según la regla del perceptrón
      for (int j = 0; j < nEntradas; j++) {
        matrizPesos[j][0] += alfa * error * matrizFinalDatosSeleccionados[i][j];
      }

      //  Ajustar umbral
      umbral[0] -= alfa * error;

      // 🔹 Acumular el error cuadrático
      sumaErrorCuadrado += error * error;
    }

    // 🔹 Calcular RMS (raíz del error cuadrático medio) de esta iteración
    double rms = sqrt(sumaErrorCuadrado / datasetLength);

    // Guardar el error en la lista
    erroresPorCiclo.add(rms);

    // 🔹 Si el error es menor al permitido, guardar y terminar
    if (rms <= maximo_error_permitido) {
      List<double> erroresPrevios = await _modelo.obtenerErrores(nombreColeccion);
      erroresPrevios.addAll(erroresPorCiclo);

      // Limpiar datos viejos en Firebase
      await _modelo.eliminarErrores(nombreColeccion);
      await _modelo.eliminarMatrizPesos(nombreColeccion);
      await _modelo.eliminarMatrizUmbral(nombreColeccion);

      return erroresPrevios; // Devuelve todos los errores acumulados
    }
  }

  // 🔹 Si no se alcanzó el error permitido, recuperar errores previos y agregarlos
  List<double> erroresfirebase = await _modelo.obtenerErrores(nombreColeccion);

  // Agregar los errores actuales a los anteriores
  erroresfirebase.addAll(erroresPorCiclo);

  // Guardar los errores en Firebase
  await _modelo.guardarErrores(nombreColeccion, erroresfirebase);

  // Retornar la lista actualizada
  return erroresfirebase;
}

}