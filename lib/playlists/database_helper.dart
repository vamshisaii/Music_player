import 'dart:io';
import 'package:music_player/playlists/playlist.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

// database table and column names
final String tablePlaylists = 'Playlists';
final String columnId = '_id';
final String columnPlaylistName = 'playlist_name';
final String columnListSongs = 'list_of_songs';

// singleton class to manage the database
class DatabaseHelper {
  // This is the actual database filename that is saved in the docs directory.
  static final _databaseName = "playlistDatabase.db";
  // Increment this version when you need to change the schema.
  static final _databaseVersion = 6;

  // Make this a singleton class.
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // Only allow a single open connection to the database.
  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  // open the database
  _initDatabase() async {
    // The path_provider plugin gets the right directory for Android or iOS.
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    // Open the database. Can also add an onUpdate callback parameter.
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  // SQL string to create the database
  Future _onCreate(Database db, int version) async {
    await db.execute('''
                CREATE TABLE $tablePlaylists (
                  $columnId INTEGER PRIMARY KEY,
                  $columnPlaylistName TEXT NOT NULL,
                  $columnListSongs TEXT)
              ''');
    //  $columnListSongs JSON NOT NULL
  }

  // Database helper methods:

  Future<int> insert(Playlist playlist) async {
    Database db = await database;
    int id = await db.insert(tablePlaylists, playlist.toJson());
    return id;
  }

  Future<Playlist> queryWord(int id) async {
    Database db = await database;

    List<Map> maps = await db.query(tablePlaylists,
        columns: [
          columnId,
          columnPlaylistName,
        ],
        where: '$columnId = ?',
        whereArgs: [id]);
    if (maps.length > 0) {
      return Playlist.fromJson(maps.first);
    }
    return null;
  }

  Future<List<Playlist>> playlists() async {
    List<Playlist> list = List<Playlist>();
    Database db = await database;

    List<Map> maps =
        await db.query(tablePlaylists, columns: [columnId, columnPlaylistName]);
    if (maps.length > 0) {
      maps.forEach((element) {
        list.add(Playlist.fromJson(element));
      });
      return list;
    }
    return null;
  }

  Future updatePlaylist(Playlist list) async {
    Database db = await database;
    await db.update(tablePlaylists, list.toJson(),
        where: '$columnPlaylistName = ?', whereArgs: [list.playlistName]);
        print('updated playlist :$columnListSongs');
  }

  Future<Playlist> songList(Playlist playlist) async {
    Database db = await database;
    List<Map> maps = await db.query(tablePlaylists,
        columns: [columnId, columnPlaylistName, columnListSongs],
        where: '$columnPlaylistName = ?',
        whereArgs: [playlist.playlistName]);
    if (maps.length > 0) {
      print(maps.first);
      return Playlist.fromJson(maps.first);
     /* maps.map((element) {
        songs=element[columnListSongs];
        print(element);
      });*/
    }
    return null;
  }

  // TODO: queryAllWords()
  // TODO: delete(int id)
  // TODO: update(Word word)
}
