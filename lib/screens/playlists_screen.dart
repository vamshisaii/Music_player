import 'package:flutter/material.dart';
import 'package:music_player/custom_widgets/playlist_tile.dart';
import 'package:music_player/playlists/database_helper.dart';
import 'package:music_player/playlists/playlist.dart';

class PlaylistScreen extends StatelessWidget {
  const PlaylistScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DatabaseHelper helper = DatabaseHelper.instance;
    List<Widget> playlists =List<Widget>();
    return FutureBuilder(
        future: helper.playlists(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            snapshot.data.forEach((Playlist element) {
              playlists.add(PlaylistTile(playlist: element,isPopup:false));
            });
            return Column(children: playlists,);
          }
          return Container(child: CircularProgressIndicator(),);
        });
  }
}
