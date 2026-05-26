import 'package:flutter/material.dart';

class TreinosView extends StatelessWidget {
  const TreinosView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.fitness_center, size: 80, color: Colors.grey),
          SizedBox(height: 20),
          Text('Tela de Treinos Personalizados', style: TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}