import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:music_player/blocs/app_bloc.dart';
import 'package:music_player/custom_widgets/album_card.dart';
import 'package:music_player/custom_widgets/gridview_builder.dart';

class Artist extends StatelessWidget {
  Artist({@required this.bloc,@required this.isArtistScreen});


  final AppBloc bloc;
  final bool isArtistScreen;
  @override
  Widget build(BuildContext context) {
    if(isArtistScreen)
    return Container(
        child: StreamBuilder<List<ArtistInfo>>(
      stream: bloc.artistStream,
      builder: (context, snapshot) {
        return GridViewBuilder<ArtistInfo>(
          snapshot: snapshot,
          itemBuilder: (context, artist) => AlbumCard(artistData: artist)
          //AlbumCard(albumData: artist),
        );
      },
    ));

    else{ return Container(
        child: StreamBuilder<List<AlbumInfo>>(
      stream: bloc.albumStream,
      builder: (context, snapshot) {
        return GridViewBuilder<AlbumInfo>(
          snapshot: snapshot,
          itemBuilder: (context, album) => AlbumCard(albumData: album)
          //AlbumCard(albumData: artist),
        );
      },
    ));

    }
  }
}
