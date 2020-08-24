import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:animations/animations.dart';
import 'package:music_player/blocs/app_bloc.dart';
import 'package:music_player/custom_widgets/song_list_tile.dart';
import 'package:music_player/custom_widgets/vertical_list_item_widget.dart';
import 'package:music_player/screens/detailsContentScreen.dart';
import 'package:provider/provider.dart';

class AlbumCard extends StatefulWidget {
  AlbumCard({Key key, this.albumData, this.artistData}) : super(key: key);

  final AlbumInfo albumData;
  final ArtistInfo artistData;

  @override
  _AlbumCardState createState() => _AlbumCardState();
}

NavigationOptions current;
Map<NavigationOptions, List<dynamic>> currentNavigation;

class _AlbumCardState extends State<AlbumCard> {
  ContainerTransitionType _transitionType = ContainerTransitionType.fade;
  bool cardTextPosition = true;

  @override
  void initState() {
    super.initState();
    if (current == null) current = NavigationOptions.HOME;
  }

  @override
  Widget build(BuildContext context) {
    final appBloc = Provider.of<AppBloc>(context, listen: false);

    appBloc.currentNavigationOption.listen((event) {
      if (event == NavigationOptions.SONGS) {
        current = NavigationOptions.HOME;
      } else
        current = event;
      print(current);
    });

    currentNavigation = {
      NavigationOptions.ARTISTS: [
        widget.artistData?.artistArtPath ?? null,
        appBloc.audioQuery.getSongsFromArtist(
            sortType: SongSortType.DISPLAY_NAME,
            artistId: widget.artistData?.id ?? ''),
        widget.artistData?.name ?? 'artist',
        null
      /*  widget.artistData != null//using albumdata instead of artistData on purpose as id was called on null in future id;
            ? appBloc.audioQuery
                .getArtwork(type: ResourceType.ARTIST, id: widget.artistData.id)
            : null*/
      ],
      NavigationOptions.HOME: [
        widget.albumData?.albumArt ?? null,
        appBloc.audioQuery.getSongsFromAlbum(
            sortType: SongSortType.DISPLAY_NAME,
            albumId: widget.albumData?.id ?? ''),
        widget.albumData?.title ?? 'album',
        null
      /*  widget.albumData != null
            ? appBloc.audioQuery
                .getArtwork(type: ResourceType.ALBUM, id: widget.albumData.id)
            : null*/
      ],
      NavigationOptions.ALBUMS: [
        widget.albumData?.albumArt ?? null,
        appBloc.audioQuery.getSongsFromAlbum(
            sortType: SongSortType.DISPLAY_NAME,
            albumId: widget.albumData?.id ?? ''),
        widget.albumData?.title ?? 'album',
        null
      /*  widget.artistData != null
            ? appBloc.audioQuery
                .getArtwork(type: ResourceType.ALBUM, id: widget.albumData.id)
            : null*/
      ],
    };

    if (current == NavigationOptions.ALBUMS) {
      cardTextPosition = false;
      setState(() {});
    } else if (current == NavigationOptions.ARTISTS) {
      cardTextPosition = false;
      setState(() {});
    } else {
      cardTextPosition = true;
      setState(() {});
    }
    print(widget.albumData.id);

    return _OpenContainerWrapper(
      transitionType: _transitionType,
      appBarBackgroundImage: currentNavigation[current][0],
      appBarTitle: currentNavigation[current][2],
      audioquery: currentNavigation[current][1],
      closedBuilder: (BuildContext _, VoidCallback openContainer) =>
          _buildAlbumCard(openContainer, currentNavigation, current),
    );
  }

  Container _buildAlbumCard(
      VoidCallback openContainer,
      Map<NavigationOptions, List<dynamic>> currentNav,
      NavigationOptions curr) {
    return Container(
      width: 200,
      child: InkWell(
          onTap: openContainer,
          child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                color: Colors.grey,
                elevation: 10,
                child: Stack(
                  children: <Widget>[
                    Container(
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(20),
                            topLeft: Radius.circular(20)),
                        child: currentNav[curr][0] == null
                            ? FutureBuilder<Uint8List>(
                                future: currentNav[curr][3],
                                builder: (_, snapshot) {
                                  print(snapshot.data);
                                  if (snapshot.data == null)
                                    return Image(
                                        image:
                                            AssetImage("assets/no_cover.png"));
                                  return Image.memory(snapshot.data);
                                },
                              )
                            : Image(
                                image: (currentNav[curr][0] == null)
                                    ? AssetImage("assets/no_cover.png")
                                    : FileImage(
                                        File(currentNav[curr][0]),
                                      ),
                              ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      width: cardTextPosition ? 177 : 202,

                      height: 40,
                      //without cliprect, the blur regoin will be expanded to full
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20)),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 4, sigmaY: 6),
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.white54,
                                borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(20),
                                    bottomRight: Radius.circular(20))),
                            child: Center(
                                child: Text(
                              currentNav[curr][2],
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54),
                            )),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ))),
    );
  }
}

class _OpenContainerWrapper extends StatelessWidget {
  final String appBarBackgroundImage;
  final String appBarTitle;
  final Future<List<SongInfo>> audioquery;

  const _OpenContainerWrapper(
      {this.closedBuilder,
      this.transitionType,
      this.onClosed,
      this.appBarBackgroundImage,
      this.appBarTitle,
      this.audioquery});

  final OpenContainerBuilder closedBuilder;
  final ContainerTransitionType transitionType;
  final ClosedCallback<bool> onClosed;

  @override
  Widget build(BuildContext context) {
    return OpenContainer<bool>(
      closedColor: Colors.transparent,
      openColor: Colors.transparent,
      transitionDuration: Duration(milliseconds: 350),
      closedElevation: 0,
      openElevation: 0,
      transitionType: transitionType,
      openBuilder: (BuildContext context, VoidCallback _) {
        return DetailsContentScreen(
          appBarBackgroundImage: appBarBackgroundImage,
          appBarTitle: appBarTitle,
          bodyContent: FutureBuilder<List<SongInfo>>(
              future: audioquery,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();

                return VerticalListItemBuilder<SongInfo>(
                  snapshot: snapshot,
                  itemBuilder: (context, song) => SongListTile(
                    songData: song,
                    option: NavigationOptions.HOME,
                  ),
                );
              }),
        );
      },
      onClosed: onClosed,
      tappable: false,
      closedBuilder: closedBuilder,
    );
  }
}
