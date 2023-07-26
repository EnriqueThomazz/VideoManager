import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:video_manager/videoSpecs.dart';

import 'addVideo.dart';
import 'alertas.dart';
import 'database/conection.dart';

class Videos extends StatefulWidget {
  int acessMode;
  Videos(this.acessMode, {super.key});

  @override
  State<Videos> createState() => _VideosState();
}

class _VideosState extends State<Videos> {
  List _listaVideos = [];
  List _listaGeneros = [];
  final Map _filtroTipo = {"filmes": true, "series": true};
  final Map<String, bool?> _filtroGenero = {};

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

  // Construção da query pra buscar videos por filtros
  // ta bem feio...
  String _getQuery() {
    String query = '''select * from video where id in
                      (select v.id from video v join video_genre vr on v.id = vr.videoid
                                         join genre g on vr.genreid = g.id''';

    if (_filtroGenero.containsValue(true)) {
      // Se tiver criterio pra filtrar, adiciona a clausula where
      query += " where ";
    } else {
      // Se não tiver criterio pra filtrar, vira uma query padrao
      query = "select * from video";
    }

    // Pra cada item do filtro, se for true a gnt adiciona um criterio
    // na clausula where seguido de um or
    _filtroGenero.forEach((key, value) {
      if (value == true) {
        query += "g.name = '$key' or ";
      }
    });

    // Se a gnt filtrou, temos que adicionar um false no final
    // Pra preencher o ultimo or
    if (_filtroGenero.containsValue(true)) {
      query += "false)";
    }

    // Se não selecionar nem filmes nem séries, mostra os dois
    if (_filtroTipo.containsValue(false)) {
      if ((_filtroTipo["filmes"] == true || _filtroTipo["series"] == true)) {
        if (_filtroGenero.containsValue(true)) {
          query += " and ";
        } else {
          query += " where ";
        }
      }

      if (_filtroTipo["filmes"] == true && _filtroTipo["series"] == false) {
        query += "type = 0";
      } else {
        if (_filtroTipo["filmes"] == false && _filtroTipo["series"] == true) {
          query += "type = 1";
        }
      }
    }

    // Ponto e virgula pra finalizar a query
    query += ";";

    //print(query);
    return query;
  }

  _recuperaVideos() async {
    Database? db = await Conexao.get();

    String query = _getQuery();

    List<Map<String, dynamic>> resp = await db!.rawQuery(query);

    List videos = mapModificavel(resp);

    setState(() {
      _listaVideos = videos;
    });
  }

  _removeVideo(int id) async {
    Database? db = await Conexao.get();

    int response = await db!.delete("video", where: "id=?", whereArgs: [id]);

    _recuperaVideos();

    print("Videos deletados: $response");

    // Deletando de video_genre
    response =
        await db.delete("video_genre", where: "videoid=?", whereArgs: [id]);

    print("Video_Generos deletados: $response");
  }

  // Filtros
  Future<dynamic> _showFilter() {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(
              "Filtrar",
              style: TextStyle(color: Colors.deepPurple),
            ),
            content: Column(
              children: [
                const Text(
                  "Tipo",
                  style: TextStyle(
                      color: Colors.deepPurple, fontWeight: FontWeight.bold),
                ),
                CheckboxListTile(
                  title: const Text("Filmes"),
                  value: _filtroTipo["filmes"],
                  activeColor: Colors.deepPurple,
                  onChanged: (newVal) {
                    setState(() {
                      _filtroTipo["filmes"] = newVal;
                    });

                    _recuperaVideos();

                    Navigator.pop(context);
                    _showFilter();
                  },
                ),
                CheckboxListTile(
                  title: const Text("Séries"),
                  value: _filtroTipo["series"],
                  activeColor: Colors.deepPurple,
                  onChanged: (newVal) {
                    setState(() {
                      _filtroTipo["series"] = newVal;
                    });

                    _recuperaVideos();

                    Navigator.pop(context);
                    _showFilter();
                  },
                ),
                const Text(
                  "Categorias",
                  style: TextStyle(
                      color: Colors.deepPurple, fontWeight: FontWeight.bold),
                ),
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

                            _recuperaVideos();

                            Navigator.pop(context);
                            _showFilter();
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
    _recuperaVideos();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Meus Vídeos"),
        backgroundColor: Colors.deepPurple,
        actions: <Widget>[
          IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () {
                _showFilter();
              })
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        onPressed: () {
          if (widget.acessMode == 1) {
            Navigator.push(
                context, MaterialPageRoute(builder: ((context) => AddVideo())));
          } else {
            erroAcesso(context);
          }
        },
        child: const Icon(Icons.add),
      ),
      body: Container(
        padding: const EdgeInsets.all(32),
        child: Column(children: [
          Expanded(
              child: ListView.builder(
                  itemCount: _listaVideos.length,
                  itemBuilder: (context, index) {
                    final item = _listaVideos[index];

                    return ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: ((context) =>
                                    VideoSpecs(item, widget.acessMode))));
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurpleAccent),
                      child: ListTile(
                        isThreeLine: true,
                        title: Text(item["name"]),
                        subtitle: Text(item["releaseDate"]),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            if (widget.acessMode == 1) {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text(
                                        "Deseja apagar ${item["name"]}?",
                                        style: const TextStyle(
                                            color: Colors.deepPurple),
                                      ),
                                      actions: [
                                        ElevatedButton(
                                          onPressed: () {
                                            _removeVideo(item["id"]);
                                            Navigator.pop(context);
                                          },
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.deepPurple),
                                          child: const Text("Sim"),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.deepPurple),
                                          child: const Text("Não"),
                                        ),
                                      ],
                                    );
                                  });
                            } else {
                              erroAcesso(context);
                            }
                          },
                        ),
                      ),
                    );
                  }))
        ]),
      ),
    );
  }
}
