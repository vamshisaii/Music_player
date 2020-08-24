import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:music_player/custom_widgets/playlist_tile.dart';
import 'package:music_player/playlists/database_helper.dart';
import 'package:music_player/playlists/playlist.dart';
import 'package:music_player/playlists/playlist_bloc.dart';
import 'package:platform_alert_dialog/platform_alert_dialog.dart';
import 'package:provider/provider.dart';

class Constants {
  static const String addToPlaylist = "Add to Playlist";
  static const String details = "Details";
  static const String addToQueue = "Add to playing queue";

  static const List<String> choices = [addToPlaylist, addToQueue, details];
}

//add to playlist pop up screen
class AddToPlaylistPop extends StatelessWidget {
   AddToPlaylistPop({@required this.song});
  final SongInfo song;
 
  Widget build(BuildContext context) {
    DatabaseHelper helper = DatabaseHelper.instance;
    List<Widget> playlists = [
      FlatButton(
        child: Text('New Playlist'),
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) => NewPlaylistPop());
        },
      ),
    ];
    return PlatformAlertDialog(
        title: Text('Add to Playlist'),
        content: FutureBuilder(
            future: helper.playlists(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                snapshot.data.forEach((Playlist element) {
                  playlists.add(PlaylistTile(playlist: element, song: song,isPopup: true,));
                });
                return Column(children: playlists);
              }
              return Column(children:playlists);
              
            })); //add on pressed and listview for available playlists
  }
}

//creating new playlist pop up screen
class NewPlaylistPop extends StatefulWidget {
  @override
  _NewPlaylistPopState createState() => _NewPlaylistPopState();
}

class _NewPlaylistPopState extends State<NewPlaylistPop> {
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final playlistBloc = Provider.of<PlaylistBloc>(context, listen: false);
    return PlatformAlertDialog(
      title: Text('New Playlist'),
      content: Column(
        children: [
          SizedBox(
            height: 5,
          ),
          TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              labelText: 'Playlist Name',
            ),
            autofocus: true,
            controller: controller,
            onChanged: (value) => playlistBloc.updateName(value),
          ),
        ],
      ),
      actions: [
        FlatButton(
          child: Text('CANCEL'),
          onPressed: Navigator.of(context).pop,
        ),
        FlatButton(
          child: Text('CREATE'),
          onPressed: () {
            playlistBloc.addNewPlaylist();
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
        )
      ],
    );
  }
}
