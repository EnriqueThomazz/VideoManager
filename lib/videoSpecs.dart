import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import 'alertas.dart';
import 'database/conection.dart';

class VideoSpecs extends StatefulWidget {
  Map<String, dynamic> video = {};
  int acessMode;
  VideoSpecs(this.video, this.acessMode, {super.key});

  @override
  State<VideoSpecs> createState() => _VideoSpecsState();
}

class _VideoSpecsState extends State<VideoSpecs> {
  TextEditingController _ctrlName = TextEditingController();
  TextEditingController _ctrlType = TextEditingController();
  TextEditingController _ctrlRelease = TextEditingController();
  TextEditingController _ctrlDuration = TextEditingController();
  TextEditingController _ctrlAge = TextEditingController();
  TextEditingController _ctrlDescription = TextEditingController();

  IconData _icon = Icons.edit;

  bool _allowEdit = false;

  Widget specialTxtField(TextEditingController ctrl, double size,
      {FontWeight weight = FontWeight.normal}) {
    InputBorder _border = InputBorder.none;
    if (_allowEdit)
      _border = const OutlineInputBorder(
          borderSide: BorderSide(width: 3, color: Colors.deepPurple));

    return TextField(
      controller: ctrl,
      enabled: _allowEdit,
      textAlign: TextAlign.center,
      maxLines: null,
      style: TextStyle(
          color: Colors.deepPurple, fontWeight: weight, fontSize: size),
      decoration: InputDecoration(
          enabledBorder: _border, focusedBorder: _border, border: _border),
    );
  }

  _inicializar() {
    _ctrlName.text = widget.video["name"];
    _ctrlRelease.text = widget.video["releaseDate"];
    _ctrlDuration.text = widget.video["durationMinutes"].toString();
    _ctrlAge.text = widget.video["ageRestriction"];
    _ctrlDescription.text = widget.video["description"];

    if (widget.video["type"] == 0) {
      _ctrlType.text = "Filme";
    } else {
      _ctrlType.text = "Série";
    }
  }

  _showError() {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(
              "Verifique a estrutura dos dados e tente novamente.",
              style: TextStyle(color: Colors.red),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple),
                child: const Text("Fechar"),
              ),
            ],
          );
        });
  }

  _updateVideo() async {
    Database? db = await Conexao.get();

    try {
      widget.video["name"] = _ctrlName.text;
      widget.video["releaseDate"] = _ctrlRelease.text;
      widget.video["durationMinutes"] = _ctrlDuration.text;
      widget.video["ageRestriction"] = _ctrlAge.text;
      widget.video["description"] = _ctrlDescription.text;
      if (_ctrlType.text == "Filme") {
        widget.video["type"] = 0;
      } else {
        // O acento n tava indo no meu emulador
        if (_ctrlType.text == "Série" || _ctrlType.text == "Serie") {
          widget.video["type"] = 1;
        } else {
          throw Exception();
        }
      }
    } on Exception {
      _showError();
    }

    int response = await db!.update("video", widget.video,
        where: "id=?", whereArgs: [widget.video["id"]]);

    print("Atualizada: $response");
  }

  @override
  Widget build(BuildContext context) {
    _inicializar();
    return Scaffold(
        appBar: AppBar(
          title: const Text("Detalhes"),
          backgroundColor: Colors.deepPurple,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.deepPurple,
          onPressed: () {
            if (widget.acessMode == 1) {
              if (_allowEdit) {
                _updateVideo();
                setState(() {
                  _allowEdit = false;
                  _icon = Icons.edit;
                });
              } else {
                // Liberar modificação
                setState(() {
                  _allowEdit = true;
                  _icon = Icons.save;
                });
              }
            } else {
              erroAcesso(context);
            }
          },
          child: Icon(_icon),
        ),
        body: Center(
          child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  specialTxtField(_ctrlName, 30, weight: FontWeight.bold),
                  specialTxtField(_ctrlType, 20),
                  Divider(thickness: 3, color: Colors.deepPurple),
                  const Text("Data de Lançamento",
                      style: TextStyle(fontSize: 20)),
                  specialTxtField(_ctrlRelease, 20),
                  Divider(thickness: 3, color: Colors.deepPurple),
                  const Text("Duração (minutos)",
                      style: TextStyle(fontSize: 20)),
                  specialTxtField(_ctrlDuration, 20),
                  Divider(thickness: 3, color: Colors.deepPurple),
                  const Text("Classificação Indicativa",
                      style: TextStyle(fontSize: 20)),
                  specialTxtField(_ctrlAge, 20),
                  Divider(thickness: 3, color: Colors.deepPurple),
                  const Text("Descrição", style: TextStyle(fontSize: 20)),
                  SizedBox(
                    height: 200,
                    child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: specialTxtField(_ctrlDescription, 20)),
                  )
                ],
              )),
        ));
  }
}
