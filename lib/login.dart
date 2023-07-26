import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:video_manager/database/conection.dart';

import 'database/scriptsSQL.dart';
import 'home.dart';
import 'register.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String _msg = '';
  TextEditingController _ctrlEmail = TextEditingController();
  TextEditingController _ctrlSenha = TextEditingController();

  _logar() async {
    Database? db = await Conexao.get();

    String email = _ctrlEmail.text;
    String senha = _ctrlSenha.text;

    List<Map<String, dynamic>> resp = await db!.rawQuery(recuperaUser(email));
    print(resp);

    if (resp.isEmpty) {
      setState(() {
        _msg = "Usuário não encontrado.";
      });
      return;
    }

    if (senha == resp[0]['password']) {
      Navigator.push(context,
          MaterialPageRoute(builder: ((context) => Home(resp[0]["name"], 1))));
    } else {
      setState(() {
        _msg = "Senha incorreta";
      });
      return;
    }

    setState(() {
      _msg = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    // Pra limpar os campos
    setState(() {
      _ctrlEmail.clear();
      _ctrlSenha.clear();
    });
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bem vindo(a)"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child:
            Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          Image.asset("images/logo.png"),
          SizedBox(
            height: 400,
            child: Column(children: [
              Text(
                _msg,
                style: const TextStyle(color: Colors.red),
              ),
              const Text("E-mail"),
              SizedBox(
                width: 300,
                child: TextField(
                  controller: _ctrlEmail,
                  decoration:
                      const InputDecoration(border: OutlineInputBorder()),
                ),
              ),
              const Text("Senha"),
              SizedBox(
                width: 300,
                child: TextField(
                  controller: _ctrlSenha,
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: _logar,
                child: const Text("Logar"),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple),
              ),
              TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: ((context) => const Register())));
                  },
                  child: const Text(
                    "Registre-se",
                    style: TextStyle(color: Colors.deepPurple),
                  )),
              TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: ((context) => Home("Convidado(a)", 0))));
                  },
                  child: const Text(
                    "Entrar como convidado",
                    style: TextStyle(color: Colors.deepPurple),
                  ))
            ]),
          ),
        ]),
      ),
    );
  }
}
