import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:music_player/blocs/app_bloc.dart';
import 'package:music_player/blocs/player_bloc.dart';
import 'package:music_player/custom_widgets/song_list_tile.dart';
import 'package:music_player/custom_widgets/vertical_list_item_widget.dart';
import 'package:provider/provider.dart';

class SongsScreen extends StatelessWidget {
  const SongsScreen({Key key,@required this.bloc}) : super(key: key);
  final AppBloc bloc;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _buildVerticalSongs(bloc),
    );
  }

  Widget _buildVerticalSongs(AppBloc bloc){
    return  StreamBuilder<List<SongInfo>>(
          stream: bloc.songStream,
          builder: (context, snapshot) {
            final playerBloc = Provider.of<PlayerBloc>(context, listen: false);
            playerBloc.updateCurrentSongsList(snapshot.data);
            return VerticalListItemBuilder<SongInfo>(
              snapshot: snapshot,
              itemBuilder: (context, song) => SongListTile(bloc:bloc,
                songData: song,
              ),
            );
          })
    ;
  }
}