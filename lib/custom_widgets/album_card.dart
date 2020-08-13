import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:animations/animations.dart';
import 'package:music_player/blocs/app_bloc.dart';
import 'package:music_player/blocs/player_bloc.dart';
import 'package:music_player/custom_widgets/song_list_tile.dart';
import 'package:music_player/custom_widgets/vertical_list_item_widget.dart';
import 'package:music_player/screens/detailsContentScreen.dart';
import 'package:provider/provider.dart';

class AlbumCard extends StatefulWidget {
  AlbumCard({Key key, @required this.albumData}) : super(key: key);

  final AlbumInfo albumData;

  @override
  _AlbumCardState createState() => _AlbumCardState();
}

class _AlbumCardState extends State<AlbumCard> {
  ContainerTransitionType _transitionType = ContainerTransitionType.fade;

  @override
  Widget build(BuildContext context) {
    return _OpenContainerWrapper(
      transitionType: _transitionType,
      appBarBackgroundImage: widget.albumData.albumArt,
      appBarTitle: widget.albumData.title,
      id: widget.albumData.id,
      closedBuilder: (BuildContext _, VoidCallback openContainer) =>
          _buildAlbumCard(openContainer),
    );
  }

  Container _buildAlbumCard(VoidCallback openContainer) {
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
                        child: Image(
                          image: (widget.albumData.albumArt == null)
                              ? AssetImage("assets/no_cover.png")
                              : FileImage(
                                  File(widget.albumData.albumArt),
                                ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      width: 177,

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
                              widget.albumData.title,
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
  final String id;

  const _OpenContainerWrapper(
      {this.closedBuilder,
      this.transitionType,
      this.onClosed,
      this.appBarBackgroundImage,
      this.appBarTitle,
      this.id});

  final OpenContainerBuilder closedBuilder;
  final ContainerTransitionType transitionType;
  final ClosedCallback<bool> onClosed;

  @override
  Widget build(BuildContext context) {
    final appBloc = Provider.of<AppBloc>(context, listen: false);
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
              future: appBloc.audioQuery.getSongsFromAlbum(
                  sortType: SongSortType.DISPLAY_NAME, albumId: id),
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
