import 'package:flutter/material.dart';

import '../db/database_helper.dart';   // Acceso a la base de datos
import '../models/comida.dart';        // Modelo Comida
import 'pantalla_agregar_receta.dart'; // Pantalla para agregar receta
import 'editar_receta.dart';           // PantallaEditarReceta

/// Pantalla que muestra todas las recetas guardadas
class PantallaRecetario extends StatefulWidget {
  const PantallaRecetario({super.key});

  @override
  State<PantallaRecetario> createState() => _PantallaRecetarioState();
}

class _PantallaRecetarioState extends State<PantallaRecetario> {

  /// Fuerza la reconstrucción de la pantalla para recargar datos
  void _recargar() {
    setState(() {});
  }

  /// Recorta la descripción a 50 caracteres y añade "..." si es más larga
  String _recorte(String texto) {
    if (texto.length <= 50) return texto;
    return texto.substring(0, 50) + "...";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Barra superior
      appBar: AppBar(
        title: Text("Recetario"),
        leading: BackButton(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
      ),

      // Cuerpo: FutureBuilder para leer todas las recetas
      body: FutureBuilder<List<Comida>>(
        future: DatabaseHelper.instance.readAllMeals(), // Lee TODAS las recetas
        builder: (context, snapshot) {

          // 1. Estado: cargando
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final recetas = snapshot.data!;

          // 2. Estado: no hay recetas
          if (recetas.isEmpty) {
            return Center(
              child: Text("No hay recetas aún."),
            );
          }

          // 3. Estado: hay recetas
          return ListView(
            padding: EdgeInsets.all(16),

            children: [

              // CUADRO CON LISTA DE RECETAS
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFFF8EEFF), // Morado muy claro
                  borderRadius: BorderRadius.circular(12),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  // Cada receta se mapea a un GestureDetector
                  children: recetas.map((receta) {
                    return GestureDetector(
                      onTap: () async {
                        // Abrir la pantalla de editar receta
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PantallaEditarReceta(comida: receta),
                          ),
                        );

                        // Si se editaron cambios, recargar pantalla
                        if (result == true) _recargar();
                      },

                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Nombre de la receta
                            Text(
                              receta.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            SizedBox(height: 4),

                            // Descripción recortada
                            Text(
                              _recorte(receta.descripcion),
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                            ),

                            SizedBox(height: 10),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              SizedBox(height: 30),

              // BOTÓN PARA AGREGAR NUEVA RECETA
              Center(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    // Navega a PantallaAgregarReceta
                    final ok = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PantallaAgregarReceta(),
                      ),
                    );

                    // Si se agregó algo, recargar lista
                    if (ok == true) _recargar();
                  },

                  icon: Icon(Icons.add_circle_outline, color: Colors.purple),
                  label: Text(
                    "Agregar comida",
                    style: TextStyle(color: Colors.black87),
                  ),

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[100],
                    elevation: 0,
                    padding: EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 80),
            ],
          );
        },
      ),
    );
  }
}
