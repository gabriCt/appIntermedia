import 'dart:io'; // Para mostrar imágenes desde archivos locales
import 'package:flutter/material.dart';
import '../db/database_helper.dart'; // Acceso a la base de datos
import '../models/comida.dart';      // Modelo Comida
import 'dia.dart' hide Comida;       // Importamos PantallaDetalleDia
import 'pantalla_recetario.dart';    // Pantalla del recetario

/// Pantalla principal de la app que muestra los días de la semana y un resumen de comidas
class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  // Lista de días de la semana
  final List<String> diasSemana = [
    "Lunes",
    "Martes",
    "Miércoles",
    "Jueves",
    "Viernes",
    "Sábado",
    "Domingo",
  ];

  /// Refresca la pantalla al volver de editar o agregar comidas
  void _refrescar() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Organizador de comidas")),

      body: Column(
        children: [
          Expanded(
            // Lista de días de la semana
            child: ListView.builder(
              padding: EdgeInsets.all(10),
              itemCount: diasSemana.length,
              itemBuilder: (context, index) {
                final nombreDia = diasSemana[index];
                final numeroDia = index + 1;

                // FutureBuilder para consultar si hay comidas en ese día
                return FutureBuilder<List<Comida>>(
                  future: DatabaseHelper.instance.readMealsByDay(nombreDia),
                  builder: (context, snapshot) {
                    // Icono o imagen a mostrar en la derecha
                    Widget widgetDerecha = Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey[300],
                    );

                    // Si hay comidas, mostramos la primera imagen
                    if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      final comida = snapshot.data!.first;

                      if (comida.imagePath != null) {
                        widgetDerecha = CircleAvatar(
                          radius: 20,
                          backgroundImage: FileImage(File(comida.imagePath!)),
                        );
                      } else {
                        widgetDerecha = CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.orange[100],
                          child: Icon(
                            Icons.restaurant,
                            color: Colors.orange,
                            size: 20,
                          ),
                        );
                      }
                    }

                    // Card de cada día
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: InkWell(
                        onTap: () async {
                          // Navega a la pantalla de detalle del día
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PantallaDetalleDia(nombreDia: nombreDia),
                            ),
                          );
                          _refrescar(); // Refresca al volver
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              // Círculo con número del día
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: snapshot.hasData && snapshot.data!.isNotEmpty
                                      ? Colors.purple
                                      : Colors.purple[50],
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    "$numeroDia",
                                    style: TextStyle(
                                      color: snapshot.hasData && snapshot.data!.isNotEmpty
                                          ? Colors.white
                                          : Colors.purple,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(width: 15),

                              // Nombre del día y título de la primera comida si existe
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      nombreDia,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    if (snapshot.hasData && snapshot.data!.isNotEmpty)
                                      Text(
                                        snapshot.data!.first.title,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                  ],
                                ),
                              ),

                              // Imagen o ícono a la derecha
                              widgetDerecha,
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // BOTÓN PARA VER EL RECETARIO
          Padding(
            padding: const EdgeInsets.only(bottom: 20, top: 10),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                // Navega a la pantalla del recetario
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PantallaRecetario()),
                );
              },
              child: Text("Ver recetario", style: TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }
}
