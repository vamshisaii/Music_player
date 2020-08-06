import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:music_player/blocs/player_bloc.dart';
import 'package:provider/provider.dart';

import '../utility.dart';

class SongListTile extends StatefulWidget {
  SongListTile({Key key, @required this.songData}) : super(key: key);
  final SongInfo songData;

  @override
  _SongListTileState createState() => _SongListTileState();
}

class _SongListTileState extends State<SongListTile> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final playerBloc = Provider.of<PlayerBloc>(context, listen: false);
    return InkWell(
      onTap: () {
        playerBloc.playSong(widget.songData.filePath);
        playerBloc.setCurrentSong(widget.songData);
      },
      child: Container(
        height: 70,
        width: size.width,
        child: Center(
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 40,
              ),
              Icon(Icons.donut_small, color: Colors.blueAccent),
              SizedBox(
                width: 20,
              ),
              Container(
                width: 200,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(widget.songData.title,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87)),
                    Text(widget.songData.artist,
                        style: TextStyle(color: Colors.black38, fontSize: 10)),
                  ],
                ),
              ),
              SizedBox(
                width: 40,
              ),
              Text(
                  '${Utility.parseToMinutesSeconds(int.parse(widget.songData.duration))}'),
              SizedBox(
                width: 35,
              ),
              Icon(Icons.favorite),
            ],
          ),
        ),
      ),
    );
  }
}
