import 'dart:async';

import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:music_player/models/songInfo_playlist.dart';
import 'package:music_player/playlists/database_helper.dart';
import 'package:music_player/playlists/playlist.dart';

class PlaylistBloc {
  String playlistName;
  final StreamController<String> _playlistNameController =
      StreamController<String>();

  Stream<String> get playListName => _playlistNameController.stream;

  void updateName(String name) {
    _playlistNameController.add(name);
    playListName.listen((event) {
      print(event);
      playlistName = event;
    });
  }

  void dispose() {
    _playlistNameController.close();
  }

  void addNewPlaylist() async {
    Playlist playlist = Playlist(playlistName: playlistName);

    DatabaseHelper helper = DatabaseHelper.instance;
    int id = await helper.insert(playlist);
    print('inserted row: $id');
  }

  void readFromDatabase() async {
    DatabaseHelper helper = DatabaseHelper.instance;
    int rowId = 1;
    Playlist playlist = await helper.queryWord(rowId);
    if (playlist == null)
      print('row is empty');
    else
      print('read row $rowId: ${playlist.playlistName}');
  }

  Future<void> addSongsToPlaylist(SongInfo song, Playlist playlist) async {
    DatabaseHelper helper = DatabaseHelper.instance;
    // Playlist readSongs=await helper.songList(playlist);

    //playlist.songs.add(song);
    SongInfoPlaylist songForPlaylist = SongInfoPlaylist(song: song,fromJson: false);
    Playlist list=await helper.songList(playlist);

    list.songs.add(songForPlaylist);
    await helper.updatePlaylist(list);
    readFromDatabase();
    // await helper.songList(playlist);
  }

  Future<List<SongInfoPlaylist>> readPlaylistSongs(Playlist playlist) async {
    DatabaseHelper helper = DatabaseHelper.instance;
    Playlist list = await helper.songList(playlist);

    return list.songs;
  }
}
