import 'package:flutter/material.dart';
import 'package:music_player/blocs/app_bloc.dart';
import 'package:music_player/screens/home_screen.dart';
import 'package:provider/provider.dart';

void main() => runApp(MusicPlayer());

class MusicPlayer extends StatelessWidget {
  const MusicPlayer({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music player',
      home: Provider<AppBloc>(
        create: (context) => AppBloc(),
        child: HomeScreen.show(context),
      ),
    );
  }
}
