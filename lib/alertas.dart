import 'package:flutter/material.dart';

erroAcesso(context) {
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Você não tem permissão para fazer isso. Experimente se cadastrar no sistema.",
            style: TextStyle(color: Colors.red),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
              child: const Text("Fechar"),
            ),
          ],
        );
      });
}
