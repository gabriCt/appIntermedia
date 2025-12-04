import 'dart:io'; // Para manejar imágenes desde archivos locales
import 'package:flutter/material.dart';
import '../models/comida.dart';           // Modelo Comida
import '../db/database_helper.dart';      // Acceso a la base de datos
import 'pantalla_editar_comida.dart';     // Pantalla para editar la comida

/// Pantalla que muestra los detalles completos de una comida
class PantallaInfoComida extends StatelessWidget {
  final Comida comida; // Recibe la comida a mostrar

  const PantallaInfoComida({super.key, required this.comida});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Barra superior con título
      appBar: AppBar(
        title: Text("Detalles del platillo"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // IMAGEN DEL PLATILLO
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: comida.imagePath != null
                    ? Image.file(
                        File(comida.imagePath!),      // Muestra la imagen si existe
                        height: 200,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        height: 200,
                        width: double.infinity,
                        color: Colors.grey[300],       // Fondo gris si no hay imagen
                        child: Icon(Icons.fastfood, size: 80, color: Colors.grey[700]),
                      ),
              ),
            ),

            SizedBox(height: 20),

            // HORA DEL PLATILLO
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.purple[50],           // Fondo morado claro
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                comida.time,                         // Hora (ej. 14:00)
                style: TextStyle(
                  color: Colors.purple,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            SizedBox(height: 20),

            // NOMBRE DEL PLATILLO
            Text(
              comida.title,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 10),

            // DESCRIPCIÓN DEL PLATILLO
            Text(
              comida.descripcion.isEmpty ? "Sin descripción" : comida.descripcion,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),

            Spacer(), // Empuja los botones hacia abajo

            // FILA DE BOTONES: ELIMINAR / EDITAR
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // BOTÓN ELIMINAR
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.red,
                  ),
                  child: Text("Eliminar"),
                  onPressed: () async {
                    // Muestra un diálogo de confirmación antes de eliminar
                    final confirmar = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text("Eliminar comida"),
                        content: Text("¿Estás seguro de eliminar este platillo?"),
                        actions: [
                          TextButton(
                            child: Text("No"),
                            onPressed: () => Navigator.pop(context, false),
                          ),
                          TextButton(
                            child: Text("Sí"),
                            onPressed: () => Navigator.pop(context, true),
                          ),
                        ],
                      ),
                    );

                    if (confirmar == true) {
                      // Elimina la comida de la base de datos
                      await DatabaseHelper.instance.delete(comida.id!);
                      Navigator.pop(context, true); // Regresa y refresca la lista
                    }
                  },
                ),

                // BOTÓN EDITAR
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                  child: Text("Editar"),
                  onPressed: () async {
                    // Navega a la pantalla de edición
                    final actualizado = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PantallaEditarComida(comida: comida),
                      ),
                    );

                    if (actualizado == true) {
                      Navigator.pop(context, true); // Vuelve y refresca la lista
                    }
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
