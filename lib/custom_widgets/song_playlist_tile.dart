import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:music_player/blocs/app_bloc.dart';
import 'package:music_player/blocs/player_bloc.dart';
import 'package:music_player/models/songInfo_playlist.dart';
import 'package:provider/provider.dart';

import '../utility.dart';

class SongListPlaylistTile extends StatefulWidget {
  SongListPlaylistTile(
      {Key key, @required this.songData, @required this.option,@required this.bloc})
      : super(key: key);
  final SongInfoPlaylist songData;
  final NavigationOptions option;
  final AppBloc bloc;

  @override
  _SongListPlaylistTileState createState() => _SongListPlaylistTileState();
}

class _SongListPlaylistTileState extends State<SongListPlaylistTile> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final playerBloc = Provider.of<PlayerBloc>(context, listen: false);

    return InkWell(
      onTap: ()async {
       
        SongInfo song= await widget.bloc.playlistSongTosongInfo(widget.songData);
        playerBloc.playSong(song.filePath,song);

        switch (widget.option) {
          case NavigationOptions.SONGS:
            playerBloc.trackCurrentSongList();
            break;
          case NavigationOptions.ALBUMS:
            playerBloc.trackCurrentSongList();
            break;
          case NavigationOptions.HOME:
            playerBloc.trackCurrentSongList();
            break;
          case NavigationOptions.PLAYLISTS:
            playerBloc.trackCurrentSongList();
            break;
          case NavigationOptions.ARTISTS:
            break;
        }
      },
      child: Container(
        height: 70,
        width: size.width,
        child: Center(
          child: Row(
            children: <Widget>[
              SizedBox(
                width: size.width / 13,
              ),
              Icon(Icons.donut_small, color: Colors.blueAccent),
              SizedBox(
                width: size.width / 30,
              ),
              Container(
                width: size.width * 6.5 / 13,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('${widget.songData.title}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87)),
                    SizedBox(
                      height: 3,
                    ),
                    Text('${widget.songData.artist}',
                        style: TextStyle(color: Colors.black38, fontSize: 10)),
                  ],
                ),
              ),
              SizedBox(
                width: size.width / 10,
              ),
              Text(
                  '${Utility.parseToMinutesSeconds(int.parse(widget.songData.duration))}'),
             
            ],
          ),
        ),
      ),
    );
  }
}
