import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:music_player/blocs/app_bloc.dart';
import 'package:music_player/blocs/player_bloc.dart';
import 'package:music_player/custom_widgets/song_moreInfo.dart';
import 'package:provider/provider.dart';

import '../utility.dart';

class SongListTile extends StatefulWidget {
  SongListTile({Key key, @required this.songData, @required this.bloc})
      : super(key: key);
  final SongInfo songData;
  final AppBloc bloc;

  @override
  _SongListTileState createState() => _SongListTileState();
}

class _SongListTileState extends State<SongListTile> {
  void choiceAction(String choice, PlayerBloc playerBloc) async {
    if (choice == Constants.addToPlaylist) {
      showDialog(
          context: context,
          builder: (BuildContext context) =>
              AddToPlaylistPop(song: widget.songData, bloc: widget.bloc));
    } 
    
    else if (choice == Constants.addToQueue) {
      final list = playerBloc.songs;
      final index = playerBloc.index;
      var queueList=playerBloc.queueList;
      print('waiting for queulist');
      if (queueList == null) {
        queueList=[widget.songData];
        playerBloc.updateQueueList(queueList);

      }

      queueList.add(widget.songData);
      playerBloc.updateQueueList(queueList);

      list.insertAll(index + 1, queueList);
      print(list);
      playerBloc.updateCurrentSongsList(list);
    }
    
     else
      print("To-Do");
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final playerBloc = Provider.of<PlayerBloc>(context, listen: false);
    final constants = Constants.choices;

    return InkWell(
      onTap: () {
        playerBloc.playSong(widget.songData.filePath, widget.songData);
        playerBloc.trackCurrentSongList();
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
                width: size.width / 30,
              ),
              Text(
                  '${Utility.parseToMinutesSeconds(int.parse(widget.songData.duration))}'),
              SizedBox(
                width: size.width / 15,
              ),
              Icon(Icons.favorite),
              PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: Colors.grey[600],
                  ),
                  onSelected: (choice) => choiceAction(choice, playerBloc),
                  itemBuilder: (BuildContext context) {
                    return constants
                        .map((String e) =>
                            PopupMenuItem<String>(child: Text(e), value: e))
                        .toList();
                  })
            ],
          ),
        ),
      ),
    );
  }
}
