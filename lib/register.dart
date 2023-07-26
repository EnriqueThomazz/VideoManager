import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import 'database/conection.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  TextEditingController _ctrlNome = TextEditingController();
  TextEditingController _ctrlEmail = TextEditingController();
  TextEditingController _ctrlSenha = TextEditingController();
  TextEditingController _ctrlSenhaRep = TextEditingController();
  String _msg = '';

  _registrar() async {
    Database? db = await Conexao.get();
    String nome = _ctrlNome.text;
    String email = _ctrlEmail.text;
    String senha = _ctrlSenha.text;
    String senhaRep = _ctrlSenhaRep.text;

    if (senha != senhaRep) {
      setState(() {
        _msg = "As senhas não coincidem";
      });
      return;
    } else {
      setState(() {
        _msg = "";
      });
    }

    List<Map<String, dynamic>> resp =
        await db!.rawQuery("select * from user where email = '$email';");

    if (resp.length > 0) {
      setState(() {
        _msg = "Usuário já cadastrado";
      });
      return;
    }

    Map<String, dynamic> user = Map();
    user["name"] = nome;
    user["email"] = email;
    user["password"] = senha;

    int id = await db.insert("user", user);

    print("ID = $id inserido!");

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(
              "Usuário cadastrado com sucesso!",
              style: TextStyle(color: Colors.deepPurple),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Ok"),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Registro"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Image.asset("images/logo.png"),
            SizedBox(
              height: 400,
              child: Column(children: [
                Text(
                  _msg,
                  style: TextStyle(color: Colors.red),
                ),
                Text("Nome"),
                SizedBox(
                  width: 300,
                  child: TextField(
                    controller: _ctrlNome,
                    decoration: InputDecoration(border: OutlineInputBorder()),
                  ),
                ),
                Text("E-mail"),
                SizedBox(
                  width: 300,
                  child: TextField(
                    controller: _ctrlEmail,
                    decoration: InputDecoration(border: OutlineInputBorder()),
                  ),
                ),
                Text("Senha"),
                SizedBox(
                  width: 300,
                  child: TextField(
                    controller: _ctrlSenha,
                    obscureText: true,
                    decoration: InputDecoration(border: OutlineInputBorder()),
                  ),
                ),
                Text("Repita a senha"),
                SizedBox(
                  width: 300,
                  child: TextField(
                    controller: _ctrlSenhaRep,
                    obscureText: true,
                    decoration: InputDecoration(border: OutlineInputBorder()),
                  ),
                ),
                ElevatedButton(
                  onPressed: _registrar,
                  child: Text("Registrar"),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple),
                )
              ]),
            )
          ],
        ),
      ),
    );
  }
}
