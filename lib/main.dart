import 'package:flutter/material.dart';
import 'package:music_player/blocs/app_bloc.dart';
import 'package:music_player/playlists/playlist_bloc.dart';
import 'package:music_player/screens/home_screen.dart';
import 'package:provider/provider.dart';

import 'blocs/player_bloc.dart';

void main() => runApp(MusicPlayer());

class MusicPlayer extends StatelessWidget {
  const MusicPlayer({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Provider<PlaylistBloc>(create: (context)=>PlaylistBloc(),
          child: Provider<PlayerBloc>(
          create: (context) => PlayerBloc(), child: MaterialApp(
          title: 'Music player',
          home: Provider<AppBloc>(
            create: (context) => AppBloc(),
            child: HomeScreen(),
          ),
        ),
      ),
    );//hgjhnggf
  }
}
