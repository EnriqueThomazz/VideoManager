import 'package:flutter/material.dart';
import 'package:video_manager/videos.dart';

class Home extends StatelessWidget {
  String name;
  // 1 -> Usuario, 0 -> Convidado
  int acessMode;

  Home(this.name, this.acessMode, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.logout),
              onPressed: () {
                Navigator.pop(context);
              })
        ],
        title: Text("Bem vindo(a), $name"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        ElevatedButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: ((context) => Videos(acessMode))));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
            child: Image.asset("images/videos.png")),
        Text(
          "Meus Videos",
          style: TextStyle(
              color: Colors.deepPurple,
              fontWeight: FontWeight.bold,
              fontSize: 20),
        )
      ])),
    );
  }
}
