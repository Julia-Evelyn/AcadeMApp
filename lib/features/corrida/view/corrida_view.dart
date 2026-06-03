import 'package:flutter/material.dart';

class CorridaView extends StatelessWidget {
  const CorridaView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.directions_run, size: 80, color: Colors.grey),
          SizedBox(height: 20),
          Text('Tela de Corrida e GPS (Futuro)', style: TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}