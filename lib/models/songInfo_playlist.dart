import 'package:flutter/foundation.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';

class SongInfoPlaylist{

  SongInfoPlaylist({this.song,this.json,@required this.fromJson});
  final SongInfo song;
  final dynamic json;
  final bool fromJson;

 String get albumId => fromJson?json["albumId"]:song.albumId;
  String get artistId => fromJson?json["artistId"]:song.artistId;
  String get artist =>fromJson?json["artist"]: song.artist;
  String get album => fromJson?json["album"]:song.album;
  String get title => fromJson?json["title"]:song.title;
  String get duration => fromJson?json["duration"]:song.duration;
  String get filePath => fromJson?json["filePath"]:song.filePath;
  String get albumArtwork => fromJson?json["albumArtwork"]:song.albumArtwork;


  Map toJson() => {
       "albumId":albumId,
        "artistId": artistId,
        "artist": artist,
        "album": album,
        "title": title,
        "duration":duration,
        "albumArtwork":albumArtwork,
        "filePath": filePath,
       
      };

  factory SongInfoPlaylist.fromJson(dynamic json) {
    return SongInfoPlaylist(json: json,fromJson: true);
  }



}