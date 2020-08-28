import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:music_player/blocs/app_bloc.dart';
import 'package:music_player/blocs/player_bloc.dart';
import 'package:music_player/custom_widgets/song_playlist_tile.dart';

import 'package:music_player/custom_widgets/vertical_list_item_widget.dart';
import 'package:music_player/models/songInfo_playlist.dart';
import 'package:music_player/playlists/playlist.dart';
import 'package:music_player/playlists/playlist_bloc.dart';
import 'package:music_player/screens/detailsContentScreen.dart';
import 'package:provider/provider.dart';

class PlaylistTile extends StatelessWidget {
  const PlaylistTile(
      {Key key,
      @required this.playlist,
      this.song,
      @required this.isPopup,
      @required this.bloc})
      : super(key: key);

  final Playlist playlist;
  final SongInfo song;
  final bool isPopup;
  final AppBloc bloc;

  void updateTrackList(PlayerBloc playerBloc, AsyncSnapshot snapshot) async {
    playerBloc.updateCurrentSongsList(
        await bloc.playlistSongsListTrackUpdatetoSongInfo(
      snapshot.data,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final playerBloc = Provider.of<PlayerBloc>(context, listen: false);

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
                    if (snapshot.hasData) updateTrackList(playerBloc, snapshot);

                    return VerticalListItemBuilder<SongInfoPlaylist>(
                        snapshot: snapshot,
                        itemBuilder: (context, songs) {
                          return SongListPlaylistTile(
                              songData: songs, bloc: bloc);
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
