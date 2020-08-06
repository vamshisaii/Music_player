import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';

class AlbumCard extends StatefulWidget {
  AlbumCard({Key key, @required this.albumData}) : super(key: key);

  final AlbumInfo albumData;

  @override
  _AlbumCardState createState() => _AlbumCardState();
}

class _AlbumCardState extends State<AlbumCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      child: InkWell(
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
                              child:
                                  Center(child: Text(widget.albumData.title,style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black54),)),
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
