import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'scriptsSQL.dart';

class Conexao {
  // ignore: prefer_typing_uninitialized_variables
  static Database? _db;

  static Future<Database?> get() async {
    // Se nao existe, criamos
    if (_db == null) {
      final path = join(await getDatabasesPath(), 'banco_videos');

      _db = await openDatabase(path, version: 1, onCreate: (db, version) async {
        await db.execute(createUserT());
        await db.execute(createGenreT());
        await db.execute(createVideoT());
        await db.execute(createVideoGenreT());

        // Por algum motivo n posso executar um comando grandão, tem que ser
        // passo a passo
        for (int i = 0; i < userData.length; i++) {
          await db.execute(userData[i]);
        }

        for (int i = 0; i < genreData.length; i++) {
          await db.execute(genreData[i]);
        }

        for (int i = 0; i < videoData.length; i++) {
          await db.execute(videoData[i]);
        }

        for (int i = 0; i < video_genreData.length; i++) {
          await db.execute(video_genreData[i]);
        }
      });
    }

    return _db;
  }
}
