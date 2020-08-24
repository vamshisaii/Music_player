import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:music_player/blocs/app_bloc.dart';
import 'package:music_player/custom_widgets/song_playlist_tile.dart';

import 'package:music_player/custom_widgets/vertical_list_item_widget.dart';
import 'package:music_player/models/songInfo_playlist.dart';
import 'package:music_player/playlists/playlist.dart';
import 'package:music_player/playlists/playlist_bloc.dart';
import 'package:music_player/screens/detailsContentScreen.dart';
import 'package:provider/provider.dart';

class PlaylistTile extends StatelessWidget {
  const PlaylistTile(
      {Key key, @required this.playlist, this.song, @required this.isPopup})
      : super(key: key);

  final Playlist playlist;
  final SongInfo song;
  final bool isPopup;

  @override
  Widget build(BuildContext context) {
    final playlistBloc = Provider.of<PlaylistBloc>(context, listen: false);
    return FlatButton(
      onPressed: () {
        if (isPopup) {
          playlistBloc.addSongsToPlaylist(song, playlist);
          Navigator.of(context).pop();
        } else {
          Navigator.push(context,
              MaterialPageRoute(builder: (BuildContext context) {
            return DetailsContentScreen(
              bodyContent: FutureBuilder<List<SongInfoPlaylist>>(
                  future: playlistBloc.readPlaylistSongs(playlist),
                  builder: (context, snapshot) {
                    return VerticalListItemBuilder<SongInfoPlaylist>(
                        snapshot: snapshot,
                        itemBuilder: (context, songs) {
                          return SongListPlaylistTile(
                            option: NavigationOptions.PLAYLISTS,
                            songData: songs,
                          ); //TODO build song tile for playlist;
                        });
                  }),
              appBarTitle: playlist.playlistName,
            );
          })); //push to plalist content screen
        }
      },
      child: Text(playlist.playlistName),
    );
  }
}
