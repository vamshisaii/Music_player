import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:music_player/blocs/app_bloc.dart';
import 'package:music_player/blocs/player_bloc.dart';
import 'package:music_player/custom_widgets/Horizontal_list_item_widget.dart';
import 'package:music_player/custom_widgets/album_card.dart';
import 'package:music_player/custom_widgets/song_list_tile.dart';
import 'package:music_player/custom_widgets/vertical_list_item_widget.dart';
import 'package:provider/provider.dart';

class Home extends StatelessWidget {
  const Home({Key key, @required this.bloc}) : super(key: key);
  final AppBloc bloc;

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: <Widget>[
        _buildHorizontalAlbums(bloc),
        Row(
          children: <Widget>[
            SizedBox(width: 30),
            Text(
              'R E C E N T',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
            ),
          ],
        ),
        _buildVerticalRecentSongs(bloc),
      ],
    ));
  }

  Widget _buildHorizontalAlbums(AppBloc bloc) {
    return StreamBuilder<List<AlbumInfo>>(
      stream: bloc.albumStream,
      builder: (context, snapshot) {
        return HorizontalListItemsBuilder<AlbumInfo>(
          snapshot: snapshot,
          itemBuilder: (context, album) => AlbumCard(
            albumData: album,
          ),
        );
      },
    );
  }

  Widget _buildVerticalRecentSongs(AppBloc bloc) {
    return Expanded(
      child: StreamBuilder<List<SongInfo>>(
          stream: bloc.songStream,
          builder: (context, snapshot) {
            final playerBloc = Provider.of<PlayerBloc>(context, listen: false);
            playerBloc.updateCurrentSongsList(snapshot.data);
            return VerticalListItemBuilder<SongInfo>(
              snapshot: snapshot,
              itemBuilder: (context, song) => SongListTile(
                bloc: bloc,
                songData: song,
              ),
            );
          }),
    );
  }
}
