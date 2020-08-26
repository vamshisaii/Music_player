import 'package:flutter/foundation.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';

class SongInfoPlaylist{

  SongInfoPlaylist({this.song,this.json,@required this.fromJson});
  final SongInfo song;
  final dynamic json;
  final bool fromJson;

 
  String get artist =>fromJson?json["artist"]: song.artist;
  String get title => fromJson?json["title"]:song.title;
  String get duration => fromJson?json["duration"]:song.duration;
 

  Map toJson() => {
       
        "artist": artist,
        "title": title,
        "duration":duration,
      
       
      };

  factory SongInfoPlaylist.fromJson(dynamic json) {
    return SongInfoPlaylist(json: json,fromJson: true);
  }



}