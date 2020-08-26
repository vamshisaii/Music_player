import 'package:flutter/material.dart';
import 'package:music_player/blocs/app_bloc.dart';
import 'package:music_player/custom_widgets/playlist_tile.dart';
import 'package:music_player/custom_widgets/vertical_list_item_widget.dart';
import 'package:music_player/playlists/database_helper.dart';
import 'package:music_player/playlists/playlist.dart';

class PlaylistScreen extends StatelessWidget {
  const PlaylistScreen({Key key, @required this.bloc}) : super(key: key);
  final AppBloc bloc;

  @override
  Widget build(BuildContext context) {
    DatabaseHelper helper = DatabaseHelper.instance;
    //List<Widget> playlists = List<Widget>();
    return FutureBuilder(
        future: helper.playlists(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return VerticalListItemBuilder(
              snapshot: snapshot,
              itemBuilder: (context, playlist) => PlaylistTile(
                bloc: bloc,
                playlist: playlist,
                isPopup: false,
              ),
            );
          }
          return Container(
            child: CircularProgressIndicator(),
          );
        });
  }
}
