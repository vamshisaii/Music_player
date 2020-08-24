import 'dart:io';
import 'dart:ui';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:music_player/blocs/app_bloc.dart';
import 'package:music_player/blocs/player_bloc.dart';
import 'package:music_player/container_clipper.dart';

import 'package:music_player/screens/home.dart';
import 'package:music_player/screens/playlists_screen.dart';
import 'package:music_player/screens/songs_screen.dart';
import 'package:provider/provider.dart';

import 'Artist_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  Animation animation;
  AnimationController controller;
  bool isPlaying = false;
  AnimationController playPauseController;
  bool loopSetter = true;
  bool shuffleSetter =
      true; //not able to add events to shuffle stream, so using this bool to trigger it one time.

  int tabIndex = 0;

  static final Map<NavigationOptions, String> _titles = {
    NavigationOptions.HOME: 'H O M E',
    NavigationOptions.ALBUMS: "A L B U M S",
    NavigationOptions.ARTISTS: "A R T I S T S",
    NavigationOptions.SONGS: "S O N G S",
    NavigationOptions.PLAYLISTS: "P L A Y L I S T S",
  };

  bool _canBeDragged;
  NavigationOptions _currentNavigationOpetion;
  SearchBarState _currentSearchBarState;
  TextEditingController _searchController;
  double _slidePosition = 0;

  @override
  void initState() {
    super.initState();
    final playerBloc = Provider.of<PlayerBloc>(context, listen: false);

    _currentNavigationOpetion = NavigationOptions.HOME;
    _currentSearchBarState = SearchBarState.COLLAPSED;
    _searchController = TextEditingController();

    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    animation =
        CurvedAnimation(curve: Curves.fastOutSlowIn, parent: controller);

    playPauseController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 210));
    controller.addListener(() {
      if (controller.value == 0.000)
        playerBloc.setplayerStatus(false);
      else
        playerBloc.setplayerStatus(true);
    });

    //playpause animation control using isplaying stream
    playerBloc.isPlaying.listen((event) {
      if (event)
        playPauseController.reverse();
      else
        playPauseController.forward();
    });
    //controlling next,previous,shuffle,loop
    playerBloc.controlPlaylist();
  }

  //gesture controls
  void _onDragStart(DragStartDetails details) {
    bool isDragOpenFromBottom =
        controller.isDismissed && details.globalPosition.dy > 60;
    bool isDragCloseFromTop =
        controller.isCompleted && details.globalPosition.dy > 30;

    _canBeDragged = isDragCloseFromTop || isDragOpenFromBottom;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_canBeDragged) {
      double delta = -details.primaryDelta / 300;
      controller.value += delta;
    }
  }

  void _onDragEnd(DragEndDetails details) {
    final playerBloc = Provider.of<PlayerBloc>(context, listen: false);
    if (controller.isCompleted) return;
    if (controller.isDismissed) playerBloc.setplayerStatus(false);
    if (details.velocity.pixelsPerSecond.dy.abs() >= 350) {
      double visualVelocity = -details.velocity.pixelsPerSecond.dy /
          MediaQuery.of(context).size.height;
      controller.fling(velocity: visualVelocity);
    } else if (controller.value < 0.5) {
      controller.reverse();
      if (controller.value == 0) playerBloc.setplayerStatus(false);
    } else {
      controller.forward();
    }
  }

  void togglePlayNew() {
    controller.forward();
  }

  Widget _buildAlbumArtScreen() {
    final playerBloc = Provider.of<PlayerBloc>(context, listen: false);
    final size = MediaQuery.of(context).size;
    return StreamBuilder<bool>(
        stream: playerBloc.isPlayerOpen,
        initialData: false,
        builder: (context, snapshot) {
          return Transform.translate(
            offset: snapshot.data ? Offset(0, 0) : Offset(0, size.height),
            child: SafeArea(
                child: Material(
              color: Colors.transparent,
              child: Opacity(
                opacity: controller.value,
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.arrow_back,
                            color: Colors.black87,
                          ),
                          onPressed: () => controller.reverse(),
                        ),
                        Text(
                          'N O W   P L A Y I N G',
                          style: TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                        IconButton(
                          icon: Icon(Icons.more_vert, color: Colors.black87),
                          onPressed: null,
                        )
                      ],
                    ),
                    SizedBox(height: 70),
                    StreamBuilder<SongInfo>(
                        stream: playerBloc.currentSongPlaying,
                        builder: (context, snapshot) {
                          if (snapshot.hasData)
                            return Card(
                              elevation: 15,
                              color: Colors.transparent,
                              child: Container(
                                width: size.width / 2,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20),
                                  ),
                                  child: Image(
                                    image: (snapshot.data.albumArtwork == null)
                                        ? AssetImage("assets/no_cover.png")
                                        : FileImage(
                                            File(snapshot.data.albumArtwork),
                                          ),
                                  ),
                                ),
                              ),
                            );
                          else
                            return Container();
                        }),
                    StreamBuilder<SongInfo>(
                        stream: playerBloc.currentSongPlaying,
                        builder: (context, snapshot) {
                          final currentSong = snapshot.data;
                          if (currentSong != null)
                            return Column(
                              children: [
                                SizedBox(
                                  height: 15,
                                ),
                                Text(currentSong.title,
                                    style: TextStyle(
                                        fontSize: 22, color: Colors.black87)),
                                SizedBox(
                                  height: 15,
                                ),
                                Text(currentSong.artist,
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.black38))
                              ],
                            );
                          return Container();
                        })
                  ],
                ),
              ),
            )),
          );
        });
  }

  Widget _buildPlayerBackground() {
    final playerBloc = Provider.of<PlayerBloc>(context, listen: false);
    final size = MediaQuery.of(context).size;
    return StreamBuilder<bool>(
        stream: playerBloc.isPlayerOpen,
        initialData: false,
        builder: (context, snapshot) {
          return Transform.translate(
            offset: snapshot.data ? Offset(0, 0) : Offset(0, size.height),
            child: Opacity(
              opacity: animation.value * 0.96,
              child: Container(
                height: size.height * 0.65,
                width: size.width,
                color: Colors.white,
                child: Stack(
                  children: [
                    Container(
                        width: size.width / 2,
                        height: size.height * 0.7 / 2,
                        color: Colors.black12),
                    Positioned(
                        top: size.height * 0.7 / 2,
                        left: size.width / 2,
                        child: Container(
                            width: size.width / 2,
                            height: size.height / 2,
                            color: Colors.black12))
                  ],
                ),
              ),
            ),
          );
        });
  }

  Widget _buildPlayer() {
    final playerBloc = Provider.of<PlayerBloc>(context, listen: false);
    final size = MediaQuery.of(context).size;
    return StreamBuilder<bool>(
        stream: playerBloc.isPlaying,
        initialData: false,
        builder: (context, snapshot) {
          if (snapshot.data == true) isPlaying = true;
          return Transform.translate(
              offset: isPlaying
                  ? Offset(0, size.height - 60 - animation.value * 250)
                  : Offset(0, size.height),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40)),
                child: GestureDetector(
                  onTap: () {
                    togglePlayNew();
                    playerBloc.setplayerStatus(true);
                  },
                  onVerticalDragStart: _onDragStart,
                  onVerticalDragUpdate: _onDragUpdate,
                  onVerticalDragEnd: _onDragEnd,
                  child: Material(
                    child: Container(
                        height: size.height,
                        width: size.width,
                        color: Colors.blueGrey[400],
                        child: StreamBuilder<SongInfo>(
                            stream: playerBloc.currentSongPlaying,
                            builder: (context, snapshot) {
                              final currentSongPlaying = snapshot.data;
                              if (snapshot.hasData)
                                return Stack(
                                  children: <Widget>[
                                    //mini player
                                    _buildMiniPlayer(
                                        currentSongPlaying, playerBloc),

                                    //large player
                                    _buildLargePlayer(size, playerBloc)
                                  ],
                                );
                              else
                                return Container();
                            })),
                  ),
                ),
              ));
        });
  }

  Opacity _buildLargePlayer(Size size, PlayerBloc playerBloc) {
    return Opacity(
      opacity: controller.value,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 42),
        child: Container(
            child: Column(
          children: <Widget>[
            SizedBox(
              height: 15,
            ),
            StreamBuilder<Duration>(
                stream: playerBloc.currentDuration,
                builder: (context, snapshot) {
                  if (snapshot.hasData)
                    return Row(
                      children: [
                        SizedBox(width: size.width * 0.06),
                        Text(
                          '${snapshot.data.inMinutes.toString()}:${(snapshot.data.inSeconds % 60).toString()}',
                        ),
                        SizedBox(width: size.width * 0.62),
                        StreamBuilder<Playing>(
                            stream: playerBloc.currentSongInfo,
                            builder: (context, snapshot) {
                              if (snapshot.data != null)
                                return Text(
                                    '${snapshot.data.audio.duration.inMinutes.toString()}:${((snapshot.data.audio.duration.inSeconds) % 60).toString()}');

                              return Container();
                            }),
                      ],
                    );
                  return Container();
                }),
            //  SizedBox(height: 15),
            StreamBuilder<Playing>(
                stream: playerBloc.currentSongInfo,
                builder: (context, snapshot) {
                  final currentSongInfo = snapshot.data;

                  if (snapshot.hasData)
                    return StreamBuilder<Duration>(
                        stream: playerBloc.currentDuration,
                        builder: (context, snapshot) {
                          if (snapshot.data != null) {
                            //slider
                            return Slider(
                                activeColor: Colors.orange,
                                value: double.parse(
                                    snapshot.data.inSeconds.toString()),
                                onChanged: (value) {
                                  setState(() {
                                    _slidePosition = value;
                                  });

                                  playerBloc.seekTo(Duration(
                                      seconds: _slidePosition.toInt()));
                                },
                                min: 0,
                                max: double.parse(currentSongInfo
                                    .audio.duration.inSeconds
                                    .toString()));
                          } else
                            return Container();
                        });
                  return Container();
                }),
            Container(
              height: 150,
              width: size.width,
              child: Transform.scale(
                scale: 1.15,
                child: Stack(
                  children: [
                    Positioned(
                      left: size.width * 0.23,
                      top: 80,
                      child: Row(
                        children: [
                          ClipPath(
                            clipper: BackgroundClipper(isPrevious: true),
                            child: InkWell(
                              onTap: playerBloc.previous,
                              child: Container(
                                  width: 80,
                                  height: 50,
                                  color: Colors.orangeAccent,
                                  child: Row(
                                    children: [
                                      SizedBox(width: 20),
                                      Icon(Icons.skip_previous),
                                    ],
                                  )),
                            ),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          ClipPath(
                            clipper: BackgroundClipper(isPrevious: false),
                            child: InkWell(
                              onTap: playerBloc.next,
                              child: Container(
                                width: 80,
                                height: 50,
                                color: Colors.greenAccent,
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 35,
                                    ),
                                    Icon(Icons.skip_next),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: 54 + size.width * 0.23,
                      top: 47,
                      child: FloatingActionButton(
                        elevation: 10,
                        onPressed: () {
                          playerBloc.playPauseSong();
                        },
                        child: AnimatedIcon(
                          icon: AnimatedIcons.pause_play,
                          progress: playPauseController,
                        ),
                      ),
                    ),
                    Positioned(
                        top: 83,
                        left: size.width * 0.08,
                        child: StreamBuilder<bool>(
                            stream: playerBloc.isShuffle,
                            initialData: false,
                            builder: (context, snapshot) {
                              bool isShuffle = snapshot.data;
                              if (shuffleSetter) {
                                playerBloc.setShuffle(false);
                                shuffleSetter = false;
                              }
                              return IconButton(
                                icon: Icon(
                                  Icons.shuffle,
                                  color: isShuffle
                                      ? Colors.greenAccent
                                      : Colors.black87,
                                ),
                                onPressed: () =>
                                    playerBloc.setShuffle(!isShuffle),
                              );
                            })),
                    Positioned(
                        top: 83,
                        left: size.width * 0.64,
                        child: StreamBuilder<bool>(
                            stream: playerBloc.isLoop,
                            initialData: false,
                            builder: (context, snapshot) {
                              bool isLoop = snapshot.data;
                              if (loopSetter) {
                                playerBloc.setLoop(false);
                                loopSetter = false;
                              }
                              return IconButton(
                                icon: Icon(Icons.repeat,
                                    color: isLoop
                                        ? Colors.greenAccent
                                        : Colors.black87),
                                onPressed: () => playerBloc.setLoop(!isLoop),
                              );
                            }))
                  ],
                ),
              ),
            )
          ],
        )),
      ),
    );
  }

  Opacity _buildMiniPlayer(SongInfo currentSongPlaying, PlayerBloc playerBloc) {
    final size = MediaQuery.of(context).size;
    return Opacity(
      opacity: 1 - controller.value,
      child: controller.value < 1
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
              child: Container(
                child: Row(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: (currentSongPlaying.albumArtwork == null)
                          ? AssetImage('assets/no_cover.png')
                          : FileImage(
                              File(currentSongPlaying.albumArtwork),
                            ),
                    ),
                    SizedBox(
                      width: size.width / 20,
                    ),
                    Container(
                      width: size.width / 1.65,
                      child: Text(currentSongPlaying.title),
                      // Text(currentSongPlaying.artist,style:TextStyle(color: Colors.black38,fontSize: 12))
                    ),
                    IconButton(
                        onPressed: () {
                          playerBloc.playPauseSong();
                        },
                        icon: AnimatedIcon(
                          icon: AnimatedIcons.pause_play,
                          progress: playPauseController,
                        ))
                  ],
                ),
              ),
            )
          : Container(),
    );
  }

  DefaultTabController _buildHomeScreen(AppBloc bloc) {
    return DefaultTabController(
        length: 5,
        child: Scaffold(
          body: NestedScrollView(
            headerSliverBuilder: (context, value) {
              DefaultTabController.of(context).addListener(() {
                int index;
                index = DefaultTabController.of(context).index;
                print(index);
                setState(() {
                  bloc.changeNavigation((NavigationOptions.values[index]));
                  switch (index) {
                    case 0:
                      tabIndex = 0;

                      break;
                    case 1:
                      tabIndex = 1;
                      break;
                    case 2:
                      tabIndex = 2;
                      break;
                    case 3:
                      tabIndex = 3;
                      break;
                    case 4:
                      tabIndex = 4;
                      break;
                  }
                });
              });
              return [
                SliverAppBar(
                  elevation: 8,
                  expandedHeight: 160,
                  backgroundColor: Colors.white,
                  title: StreamBuilder<SearchBarState>(
                      stream: bloc.searchBarStream,
                      builder: (context, snapshot) {
                        if (snapshot.data == SearchBarState.EXPANDED)
                          return TextField(
                            controller: _searchController,
                            autofocus: true,
                            onChanged: (typed) {
                              bloc.search(
                                  option: _currentNavigationOpetion,
                                  query: _searchController.text);
                            },
                            decoration: InputDecoration(
                                hintText: 'Search...',
                                hintStyle: TextStyle(color: Colors.grey)),
                          );
                        return Container();
                      }),
                  leading: IconButton(
                    onPressed: () =>
                        bloc.changeSearchBarState(SearchBarState.EXPANDED),
                    icon: Icon(Icons.search),
                    color: Colors.black54,
                  ),
                  pinned: true,
                  floating: true,
                  actions: <Widget>[
                    StreamBuilder<SearchBarState>(
                      stream: bloc.searchBarStream,
                      builder: (context, snapshot) {
                        if (snapshot.data == SearchBarState.EXPANDED)
                          return IconButton(
                            icon: Icon(Icons.close, color: Colors.black54),
                            onPressed: () {
                              bloc.changeSearchBarState(
                                  SearchBarState.COLLAPSED);
                            },
                          );
                        return Container();
                      },
                    ),
                    Icon(Icons.more_vert, color: Colors.black54),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    title: SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            'Browse',
                            style:
                                TextStyle(fontSize: 22, color: Colors.black54),
                          ),
                          SizedBox(height: 30)
                        ],
                      ),
                    ),
                  ),
                  bottom: TabBar(
                    indicatorWeight: 2,
                    isScrollable: true,
                    indicatorColor: Color(0xff166ed2),
                    onTap: (index) {
                      setState(() {
                        bloc.changeNavigation(
                            (NavigationOptions.values[index]));
                        switch (index) {
                          case 0:
                            tabIndex = 0;

                            break;
                          case 1:
                            tabIndex = 1;
                            break;
                          case 2:
                            tabIndex = 2;
                            break;
                          case 3:
                            tabIndex = 3;
                            break;
                          case 4:
                            tabIndex = 4;
                            break;
                        }
                      });
                    },
                    tabs: <Widget>[
                      Tab(
                        child: Container(
                            width: 70,
                            child: Center(
                              child: Text('H O M E',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: tabIndex == 0
                                          ? Colors.black87
                                          : Colors.black38)),
                            )),
                      ),
                      Tab(
                        child: Container(
                            width: 100,
                            child: Center(
                              child: Text('A R T I S T S',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: tabIndex == 1
                                          ? Colors.black87
                                          : Colors.black38)),
                            )),
                      ),
                      Tab(
                        child: Container(
                            width: 100,
                            child: Center(
                              child: Text('S O N G S',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: tabIndex == 2
                                          ? Colors.black87
                                          : Colors.black38)),
                            )),
                      ),
                      Tab(
                        child: Container(
                            width: 100,
                            child: Center(
                              child: Text('A L B U M S',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: tabIndex == 3
                                          ? Colors.black87
                                          : Colors.black38)),
                            )),
                      ),
                      Tab(
                        child: Container(
                            width: 110,
                            child: Center(
                              child: Text('P L A Y L I S T S',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: tabIndex == 4
                                          ? Colors.black87
                                          : Colors.black38)),
                            )),
                      ),
                    ],
                  ),
                ),
              ];
            },
            body: TabBarView(
              children: <Widget>[
                Home(bloc: bloc),//homse screen
                Artist(
                  bloc: bloc,
                  isArtistScreen: true,
                ),//artist page
                SongsScreen(bloc: bloc),//songs page
                Artist(
                  bloc: bloc,
                  isArtistScreen: false,
                ), //artist screen is used for album as well by setting bool isArtistScreen
                PlaylistScreen()//playlists Screen
              ],
            ),
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<AppBloc>(context, listen: false);

    return Stack(children: <Widget>[
      _buildHomeScreen(bloc),
      AnimatedBuilder(
          animation: controller,
          builder: (context, child) => _buildPlayerBackground()),
      AnimatedBuilder(
        animation: controller,
        builder: (context, child) => _buildAlbumArtScreen(),
      ),
      AnimatedBuilder(
        animation: controller,
        builder: (context, child) => _buildPlayer(),
      ),
    ]);
  }
}

/*   TabBarView(children: <Widget>[
              Expanded(child:Center(child: Text("home"))),
              Expanded(child:Center(child: Text("artists"))),
              Expanded(child:Center(child: Text("songs"))),
              Expanded(child:Center(child: Text("albums"))),
              Expanded(child:Center(child: Text("playlists"))),
            ],)
            */
