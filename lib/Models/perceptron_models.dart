import 'package:cloud_firestore/cloud_firestore.dart';

class ModeloFirebase {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

 //Guarda los Json
 Future<void> guardarJsonEnNuevaColeccion(
      dynamic data, String collectionName) async {
    try {
      if (data is Map<String, dynamic>) {
        // Guardar JSON único en la colección con id fijo 'doc_0'
        await _db.collection(collectionName).doc('doc_0').set({
          ...data,
          "index": 0, // único documento => índice 0
        });
      } else if (data is List) {
        // Guardar cada elemento del listado como documento separado con id 'doc_i'
        for (int i = 0; i < data.length; i++) {
          var item = data[i];
          if (item is Map<String, dynamic>) {
            await _db.collection(collectionName).doc('doc_$i').set({
              ...item,
              "index": i, // posición en la lista
            });
          }
        }
      } else {
        throw Exception("Formato de JSON no soportado");
      }
    } catch (e) {
      throw Exception("Error al guardar en Firestore: $e");
    }
  }
 
 // Obtiene todos los documentos de una colección
 Future<List<Map<String, dynamic>>> guardarinformacionDatosMatriz(String nombreColeccion) async {
  try {
    if (nombreColeccion == "dataset1_3entradas") {
      final snapshot = await _db.collection(nombreColeccion).orderBy("index").get();
      return snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        return {
          'index': data['index'],
          'x1': data['x1'],
          'x2': data['x2'],
          'x3': data['x3'],
          'salida': data['salida'],
        };
      }).toList();
    } else if (nombreColeccion == "dataset2_4entradas") {
      final snapshot = await _db.collection(nombreColeccion).orderBy("index").get();
      return snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        return {
          'index': data['index'],
          'x1': data['x1'],
          'x2': data['x2'],
          'x3': data['x3'],
          'x4': data['x4'],
          'salida': data['salida'],
        };
      }).toList();
    } else if (nombreColeccion == "dataset3_academico") {
      final snapshot = await _db.collection(nombreColeccion).orderBy("index").get();
      return snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        return {
          'index': data['index'],
          'horas_estudio': data['horas_estudio'],
          'asistencia': data['asistencia'],
          'participacion': data['participacion'],
          'aprueba': data['aprueba'],
        };
      }).toList();
    } else {
      return [];
    }
  } catch (e) {
    throw Exception("Error al obtener datos: $e");
  }
}

 Future<List<Map<String, dynamic>>> obtenerDatosPesos(String nombreColeccion) async {
  try {
    final snapshot = await _db.collection("pesos_$nombreColeccion").get();
    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  } catch (e) {
    throw Exception("Error al obtener datos de pesos_$nombreColeccion: $e");
  }
}

 Future<List<Map<String, dynamic>>> obtenerDatosUmbral(String nombreColeccion) async {
  try {
    final snapshot = await _db.collection("umbral_$nombreColeccion").get();
    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  } catch (e) {
    throw Exception("Error al obtener datos de umbral_$nombreColeccion: $e");
  }
}

 Future<void> guardarMatrizPesos(
    List<Map<String, dynamic>> matriz,
    String nombreColeccionOriginal,
  ) async {
    final nombreColeccionPesos = "pesos_$nombreColeccionOriginal";
    final coleccionRef = _db.collection(nombreColeccionPesos);

    for (int i = 0; i < matriz.length; i++) {
      final fila = matriz[i];
      await coleccionRef.doc(i.toString()).set(fila, SetOptions(merge: true));
    }
  }

 Future<void> guardarMatrizUmbral(
    List<Map<String, dynamic>> matriz,
    String nombreColeccionOriginal,
  ) async {
    final nombreColeccionPesos = "umbral_$nombreColeccionOriginal";
    final coleccionRef = _db.collection(nombreColeccionPesos);

    for (int i = 0; i < matriz.length; i++) {
      final fila = matriz[i];
      await coleccionRef.doc(i.toString()).set(fila, SetOptions(merge: true));
    }
  }

Future<void> eliminarMatrizPesos(String nombreColeccionOriginal) async {
  final nombreColeccionPesos = "pesos_$nombreColeccionOriginal";
  final coleccionRef = _db.collection(nombreColeccionPesos);

  final snapshot = await coleccionRef.get();
  for (var doc in snapshot.docs) {
    await doc.reference.delete();
  }
}

Future<void> eliminarMatrizUmbral(String nombreColeccionOriginal) async {
  final nombreColeccionUmbral = "umbral_$nombreColeccionOriginal";
  final coleccionRef = _db.collection(nombreColeccionUmbral);

  final snapshot = await coleccionRef.get();
  for (var doc in snapshot.docs) {
    await doc.reference.delete();
  }
}

Future<void> guardarErrores(String nombreColeccion, List<double> nuevosErrores) async {
  final String coleccion = "erro_$nombreColeccion";
  final docRef = _db.collection(coleccion).doc("errores_doc");

  final snapshot = await docRef.get();

  List<dynamic> erroresExistentes = [];
  if (snapshot.exists) {
    erroresExistentes = snapshot.data()?["errores"] ?? [];
  }

  // 🔹 Combinar los errores viejos + nuevos
  erroresExistentes.addAll(nuevosErrores);

  await docRef.set({
    "errores": erroresExistentes,
  });
}

  Future<void> eliminarErrores(String nombreColeccion) async {
  try {
    // 🔹 Nombre de la colección dinámica
    final String coleccion = "erro_$nombreColeccion";

    // 🔹 Obtener todos los documentos de esa colección
    final querySnapshot = await _db.collection(coleccion).get();

    // 🔹 Eliminar cada documento
    for (var doc in querySnapshot.docs) {
      await _db.collection(coleccion).doc(doc.id).delete();
    }
  } catch (e) {
    rethrow;
  }
}

  Future<List<double>> obtenerErrores(String nombreColeccion) async {

    try {
      final String coleccion = "erro_$nombreColeccion";

      final query = await _db.collection(coleccion).get();

      // Si no hay documentos en la colección
      if (query.docs.isEmpty) {
        return [];
      }

      // Tomar todos los errores (puede haber varios documentos)
      List<double> errores = [];

      for (var doc in query.docs) {
        final data = doc.data();
        if (data["errores"] != null) {
          errores.addAll(List<double>.from(data["errores"]));
        }
      }

      return errores;
    } catch (e) {
      rethrow;
    }
  }

}
