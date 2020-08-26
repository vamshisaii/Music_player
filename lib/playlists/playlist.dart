// data model class
import 'dart:convert';

import 'package:music_player/models/songInfo_playlist.dart';

import 'database_helper.dart';

class Playlist {
  final int id;
  final String playlistName;
  final List<SongInfoPlaylist> songs;

  //List<SongInfo> playlist;

  Playlist({this.id, this.playlistName, this.songs});
  // convenience constructor to create a Playlist object
  factory Playlist.fromJson(dynamic map) {
    var json = map[columnListSongs];
    print('$json json data');

    List<SongInfoPlaylist> list;
    if (json!= null) {
          var songsJson = jsonDecode(json) as List;

      print('json is  null $json');
         if(songsJson!=null) list = songsJson.map((e) => SongInfoPlaylist.fromJson(e)).toList();
         if(list==null)list=[];

    } 
  //  else if(json=="null") print('json is null string');
    return Playlist(
      id: map[columnId],
      playlistName: map[columnPlaylistName],
      songs: list,
    );
    //   playlist = map[columnListSongs];
  }

  // convenience method to create a Map from this Word object
  Map<String, dynamic> toJson() {
    //print(songs);
    //print(jsonEncode(songs));
    var map = <String, dynamic>{
      columnPlaylistName: playlistName,
      columnListSongs: jsonEncode(songs),

      //     columnListSongs: playlist
    };
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }
}
