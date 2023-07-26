import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import 'database/conection.dart';

class AddVideo extends StatefulWidget {
  const AddVideo({super.key});

  @override
  State<AddVideo> createState() => _AddVideoState();
}

class _AddVideoState extends State<AddVideo> {
  TextEditingController _ctrlName = TextEditingController();
  TextEditingController _ctrlType = TextEditingController();
  TextEditingController _ctrlRelease = TextEditingController();
  TextEditingController _ctrlDuration = TextEditingController();
  TextEditingController _ctrlAge = TextEditingController();
  TextEditingController _ctrlDescription = TextEditingController();

  List _listaGeneros = [];
  final Map<String, bool?> _filtroGenero = {};

  Widget specialTxtField(TextEditingController ctrl, double size,
      {FontWeight weight = FontWeight.normal}) {
    InputBorder _border = const OutlineInputBorder(
        borderSide: BorderSide(width: 3, color: Colors.deepPurple));

    return TextField(
      controller: ctrl,
      enabled: true,
      textAlign: TextAlign.center,
      maxLines: null,
      style: TextStyle(
          color: Colors.deepPurple, fontWeight: weight, fontSize: size),
      decoration: InputDecoration(
          enabledBorder: _border, focusedBorder: _border, border: _border),
    );
  }

  Widget specialTxt(String msg, double size,
      {FontWeight weight = FontWeight.normal}) {
    return Text(
      msg,
      style: TextStyle(
          color: Colors.deepPurple, fontSize: size, fontWeight: weight),
    );
  }

  List<Map<String, dynamic>> mapModificavel(List<Map<String, dynamic>> mapDB) {
    return List<Map<String, dynamic>>.generate(
        mapDB.length, (index) => Map<String, dynamic>.from(mapDB[index]),
        growable: true);
  }

  _recuperaGeneros() async {
    Database? db = await Conexao.get();

    List<Map<String, dynamic>> resp =
        await db!.rawQuery("select * from genre;");

    List generos = mapModificavel(resp);

    setState(() {
      _listaGeneros = generos;
    });

    for (int i = 0; i < _listaGeneros.length; i++) {
      _filtroGenero[_listaGeneros[i]["name"]] = false;
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

  _addVideoGenre(int videoId) async {
    Database? db = await Conexao.get();
    for (int i = 0; i < _listaGeneros.length; i++) {
      // Se o genero foi selecionado, então adiciona
      if (_filtroGenero[_listaGeneros[i]["name"]] == true) {
        Map<String, dynamic> video_genre = {};
        video_genre["videoid"] = videoId;
        video_genre["genreid"] = _listaGeneros[i]["id"];
        int id = await db!.insert("video_genre", video_genre);
        print("Video e Genero = $id inserido!");
      }
    }
  }

  _addVideo() async {
    Database? db = await Conexao.get();

    Map<String, dynamic> video = {};
    video["name"] = _ctrlName.text;
    video["description "] = _ctrlDescription.text;

    // Default é cadastrar como série
    if (_ctrlType.text == "Filme") {
      video["type "] = 0;
    } else {
      video["type "] = 1;
    }

    video["ageRestriction "] = _ctrlAge.text;
    video["durationMinutes "] = _ctrlDuration.text;
    video["thumbnailImageId  "] = "default";
    video["releaseDate "] = _ctrlRelease.text;

    try {
      int id = await db!.insert("video", video);
      print("Video = $id inserido!");
      _addVideoGenre(id);
    } on Exception {
      _showError();
    }
  }

  Future<dynamic> _addGeneros() {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(
              "Gêneros",
              style: TextStyle(color: Colors.deepPurple),
            ),
            content: Column(
              children: [
                SingleChildScrollView(
                    child: SizedBox(
                  width: double.maxFinite,
                  height: 500,
                  child: ListView.builder(
                      itemCount: _listaGeneros.length,
                      itemBuilder: (context, index) {
                        final item = _listaGeneros[index];

                        return CheckboxListTile(
                          title: Text(item["name"]),
                          value: _filtroGenero[item["name"]],
                          activeColor: Colors.deepPurple,
                          onChanged: (newVal) {
                            setState(() {
                              _filtroGenero[item["name"]] = newVal;
                            });

                            Navigator.pop(context);
                            _addGeneros();
                          },
                        );
                      }),
                )),
              ],
            ),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple),
                  child: const Text("Salvar")),
            ],
          );
        });
  }

  @override
  void initState() {
    super.initState();

    _recuperaGeneros();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Adicionar vídeo"),
        backgroundColor: Colors.deepPurple,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        onPressed: () {
          _addVideo();
          Navigator.pop(context);
        },
        child: Icon(Icons.save),
      ),
      body: Center(
          child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            specialTxt("Título", 20),
            specialTxtField(_ctrlName, 20),
            const Divider(thickness: 3, color: Colors.deepPurple),
            specialTxt("Tipo", 20),
            specialTxtField(_ctrlType, 20),
            const Divider(thickness: 3, color: Colors.deepPurple),
            specialTxt("Data de Lançamento", 20),
            specialTxtField(_ctrlRelease, 20),
            const Divider(thickness: 3, color: Colors.deepPurple),
            specialTxt("Duração (minutos)", 20),
            specialTxtField(_ctrlDuration, 20),
            const Divider(thickness: 3, color: Colors.deepPurple),
            specialTxt("Classificação Indicativa", 20),
            specialTxtField(_ctrlAge, 20),
            const Divider(thickness: 3, color: Colors.deepPurple),
            specialTxt("Descrição", 20),
            specialTxtField(_ctrlDescription, 20),
            const Divider(thickness: 3, color: Colors.deepPurple),
            ElevatedButton(
              onPressed: () {
                _addGeneros();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white60),
              child: specialTxt("Gêneros", 20),
            ),
            const Divider(thickness: 3, color: Colors.deepPurple),
          ],
        ),
      )),
    );
  }
}
