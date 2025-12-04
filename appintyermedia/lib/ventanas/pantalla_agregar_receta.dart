import 'package:flutter/material.dart';

import '../models/comida.dart';          // Modelo de la receta/comida
import '../db/database_helper.dart';     // Base de datos local (SQLite)

/// Pantalla para agregar una nueva receta
class PantallaAgregarReceta extends StatefulWidget {
  const PantallaAgregarReceta({super.key});

  @override
  State<PantallaAgregarReceta> createState() => _PantallaAgregarRecetaState();
}

class _PantallaAgregarRecetaState extends State<PantallaAgregarReceta> {
  // Controladores para capturar el texto de los TextFields
  final _tituloController = TextEditingController();
  final _descController = TextEditingController();

  /// Función que guarda la receta en la base de datos
  Future<void> _guardarReceta() async {
    // Validación: el nombre no puede estar vacío
    if (_tituloController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("El nombre no puede estar vacío")),
      );
      return; // Salir de la función si no hay título
    }

    // Crear un objeto Comida con los datos ingresados
    final nuevaReceta = Comida(
      title: _tituloController.text,     // Nombre del platillo
      descripcion: _descController.text, // Descripción del platillo
      time: "00:00",                     // Campo requerido por el modelo (no usado)
      diaSemana: "Receta",               // Categoría genérica para recetas
      imagePath: null,                   // Sin imagen por ahora
    );

    // Guardar la receta en la base de datos
    await DatabaseHelper.instance.create(nuevaReceta);

    // Volver a la pantalla anterior y devolver true (indica que se guardó algo)
    Navigator.pop(context, true);
  }

  /// Liberar los controladores cuando la pantalla se destruye
  @override
  void dispose() {
    _tituloController.dispose();
    _descController.dispose();
    super.dispose();
  }

  /// Construye la interfaz de la pantalla
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Barra superior
      appBar: AppBar(
        title: Text("Agregar receta"),
        leading: BackButton(color: Colors.black),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      // Contenido principal: formulario para ingresar datos
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Campo para el nombre de la receta
            _etiqueta("Nombre"),
            TextField(
              controller: _tituloController,
              decoration: _decoracionInput("Nombre del platillo"),
            ),
            SizedBox(height: 20),

            // Campo para la descripción
            _etiqueta("Descripción"),
            TextField(
              controller: _descController,
              maxLines: 3,
              decoration: _decoracionInput("Descripción del platillo"),
            ),
            SizedBox(height: 40),

            // Botón para guardar la receta
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _guardarReceta, // Llama a la función para guardar
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  )
                ),
                child: Text(
                  "Guardar",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  /// Widget auxiliar para mostrar etiquetas sobre los TextFields
  Widget _etiqueta(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  /// Estilo de los TextFields
  InputDecoration _decoracionInput(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400]),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.black),
      ),
    );
  }
}
