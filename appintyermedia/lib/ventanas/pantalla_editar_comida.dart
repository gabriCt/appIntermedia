import 'dart:io';                       // Para manejar archivos de imagen
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';         // Para seleccionar imágenes de la galería
import 'package:path_provider/path_provider.dart';      // Para obtener directorios locales
import 'package:path/path.dart' as path;                // Para manipular rutas de archivos

import '../models/comida.dart';           // Modelo Comida
import '../db/database_helper.dart';      // Acceso a la base de datos

/// Pantalla para editar los detalles de una comida existente
class PantallaEditarComida extends StatefulWidget {
  final Comida comida;                   // Recibe la comida a editar

  const PantallaEditarComida({super.key, required this.comida});

  @override
  State<PantallaEditarComida> createState() => _PantallaEditarComidaState();
}

class _PantallaEditarComidaState extends State<PantallaEditarComida> {
  // Controladores para los TextFields
  late TextEditingController _tituloController;
  late TextEditingController _descController;
  late TextEditingController _horaController;

  File? _nuevaImagen;                    // Para almacenar la nueva imagen seleccionada

  /// Inicializa los controladores con los datos existentes
  @override
  void initState() {
    super.initState();

    _tituloController = TextEditingController(text: widget.comida.title);
    _descController = TextEditingController(text: widget.comida.descripcion);
    _horaController = TextEditingController(text: widget.comida.time);
  }

  /// Función para seleccionar una imagen de la galería
  Future<void> _seleccionarImagen() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        _nuevaImagen = File(picked.path); // Guardamos temporalmente la imagen seleccionada
      });
    }
  }

  /// Guarda los cambios en la base de datos
  Future<void> _guardarCambios() async {
    String? rutaImagenFinal = widget.comida.imagePath; // Ruta original

    // Si se seleccionó una nueva imagen, guardarla en la carpeta de la app
    if (_nuevaImagen != null) {
      final dir = await getApplicationDocumentsDirectory(); // Directorio local
      final nombreArchivo = '${DateTime.now().millisecondsSinceEpoch}.jpg'; // Nombre único

      // Copiar la imagen al directorio local
      final nueva = await _nuevaImagen!.copy(path.join(dir.path, nombreArchivo));

      rutaImagenFinal = nueva.path; // Actualizar ruta
    }

    // Crear un objeto Comida actualizado
    final comidaActualizada = Comida(
      id: widget.comida.id,
      title: _tituloController.text,
      descripcion: _descController.text,
      time: _horaController.text,
      diaSemana: widget.comida.diaSemana,
      imagePath: rutaImagenFinal,
    );

    // Guardar cambios en la base de datos
    await DatabaseHelper.instance.update(comidaActualizada);

    // Volver a la pantalla anterior indicando que hubo cambios
    Navigator.pop(context, true);
  }

  /// Construye la interfaz de la pantalla
  @override
  Widget build(BuildContext context) {
    // Decidir qué imagen mostrar: la nueva seleccionada o la existente
    final imagenMostrar =
        _nuevaImagen != null
            ? _nuevaImagen!
            : (widget.comida.imagePath != null ? File(widget.comida.imagePath!) : null);

    return Scaffold(
      // Barra superior
      appBar: AppBar(
        title: Text("Editar detalles"),
        leading: BackButton(color: Colors.black),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      // Contenido principal: formulario de edición
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campo para el nombre
            Text("Nombre", style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: _tituloController,
              decoration: InputDecoration(hintText: "Nombre del platillo"),
            ),
            SizedBox(height: 20),

            // Campo para la descripción
            Text("Descripción", style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: _descController,
              maxLines: 3,
              decoration: InputDecoration(hintText: "Descripción del platillo"),
            ),
            SizedBox(height: 20),

            // Campo para la hora
            Text("Hora", style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: _horaController,
              decoration: InputDecoration(hintText: "Hora (ej. 14:00)"),
            ),
            SizedBox(height: 20),

            // Campo para la imagen
            Text("Imagen", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),

            GestureDetector(
              onTap: _seleccionarImagen, // Seleccionar nueva imagen
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: imagenMostrar != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.file(imagenMostrar, fit: BoxFit.cover),
                      )
                    : Center(
                        child: Icon(Icons.add_photo_alternate_outlined, size: 40),
                      ),
              ),
            ),
            SizedBox(height: 40),

            // Botón para guardar cambios
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _guardarCambios, // Llama a la función para guardar
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: Text("Guardar", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
