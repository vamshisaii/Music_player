import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:music_player/blocs/app_bloc.dart';
import 'package:music_player/blocs/player_bloc.dart';
import 'package:music_player/custom_widgets/Horizontal_list_item_widget.dart';
import 'package:music_player/custom_widgets/album_card.dart';
import 'package:music_player/custom_widgets/song_list_tile.dart';
import 'package:music_player/custom_widgets/vertical_list_item_widget.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key key}) : super(key: key);

  static Widget show(BuildContext context) {
    return Provider<PlayerBloc>(
        create: (context) => PlayerBloc(), child: HomeScreen());
  }

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  NavigationOptions _currentNavigationOpetion;
  SearchBarState _currentSearchBarState;
  TextEditingController _searchController;

  AnimationController controller;
  AnimationController playPauseController;
  Animation animation;
  bool _canBeDragged;

  int tabIndex = 0;
  bool isPlaying = false;

  static final Map<NavigationOptions, String> _titles = {
    NavigationOptions.HOME: 'H O M E',
    NavigationOptions.ALBUMS: "A L B U M S",
    NavigationOptions.ARTISTS: "A R T I S T S",
    NavigationOptions.SONGS: "S O N G S",
    NavigationOptions.PLAYLISTS: "P L A Y L I S T S",
  };

  @override
  void initState() {
    super.initState();
    final bloc = Provider.of<AppBloc>(context, listen: false);
    final playerBloc = Provider.of<PlayerBloc>(context, listen: false);
    _currentNavigationOpetion = NavigationOptions.HOME;
    bloc.changeNavigation(NavigationOptions.HOME);
    _currentSearchBarState = SearchBarState.COLLAPSED;
    _searchController = TextEditingController();

    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    animation = CurvedAnimation(curve: Curves.easeInOut, parent: controller);

    playPauseController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 210));
    controller.addListener(() {
      if (controller.value == 0.000)
        playerBloc.setplayerStatus(false);
      else
        playerBloc.setplayerStatus(true);
    });
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

  //playpause animation toggle
  void playPauseToggle() {
    if (playPauseController.status == AnimationStatus.dismissed) {
      playPauseController.forward();
    } else if (playPauseController.status == AnimationStatus.completed)
      playPauseController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<AppBloc>(context, listen: false);

    return Stack(children: <Widget>[
      _buildHomeScreen(bloc),
      AnimatedBuilder(
          animation: controller,
          builder: (context, child) => _buildPlayerInfo()),
      AnimatedBuilder(
        animation: controller,
        builder: (context, child) => _buildPlayer(),
      ),
    ]);
  }

  Widget _buildPlayerInfo() {
    final playerBloc = Provider.of<PlayerBloc>(context, listen: false);
    final size = MediaQuery.of(context).size;
    return StreamBuilder<bool>(
        stream: playerBloc.isPlayerOpen,
        initialData: false,
        builder: (context, snapshot) {
          return Transform.translate(
            offset: snapshot.data ? Offset(0, 0) : Offset(0, size.height),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                  sigmaX: animation.value * 5, sigmaY: animation.value * 5),
              child: Opacity(
                opacity: animation.value * 0.4,
                child: Container(color: Colors.white),
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
                              return Stack(
                                children: <Widget>[
                                  //mini player
                                  Opacity(
                                    opacity: 1 - controller.value,
                                    child: controller.value < 1
                                        ? Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 32, vertical: 8),
                                            child: Container(
                                              child: Row(
                                                children: <Widget>[
                                                  CircleAvatar(
                                                    radius: 20,
                                                    backgroundImage: (currentSongPlaying
                                                                .albumArtwork ==
                                                            null)
                                                        ? AssetImage(
                                                            'assets/no_cover.png')
                                                        : FileImage(
                                                            File(currentSongPlaying
                                                                .albumArtwork),
                                                          ),
                                                  ),
                                                  SizedBox(
                                                    width: 25,
                                                  ),
                                                  Container(
                                                    width: 260,
                                                    child: Text(
                                                        currentSongPlaying
                                                            .title),
                                                    // Text(currentSongPlaying.artist,style:TextStyle(color: Colors.black38,fontSize: 12))
                                                  ),
                                                  IconButton(
                                                      onPressed: () {
                                                        playPauseToggle();
                                                        playerBloc
                                                            .playPauseSong();
                                                      },
                                                      icon: AnimatedIcon(
                                                        icon: AnimatedIcons
                                                            .pause_play,
                                                        progress:
                                                            playPauseController,
                                                      ))
                                                ],
                                              ),
                                            ),
                                          )
                                        : Container(),
                                  ),
                                  //large player
                                  Opacity(
                                    opacity: controller.value,
                                    child: Container(
                                      child: Text('large player'),
                                    ),
                                  )
                                ],
                              );
                            })),
                  ),
                ),
              ));
        });
  }

  DefaultTabController _buildHomeScreen(AppBloc bloc) {
    return DefaultTabController(
        length: 5,
        child: Scaffold(
          body: NestedScrollView(
            headerSliverBuilder: (context, value) {
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
                Container(
                    child: Column(
                  children: <Widget>[
                    _buildHorizontalAlbums(bloc),
                    Row(
                      children: <Widget>[
                        SizedBox(width: 30),
                        Text(
                          'R E C E N T',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black54),
                        ),
                      ],
                    ),
                    _buildVerticalRecentSongs(bloc),
                  ],
                )),
                Container(child: Center(child: Text("artists"))),
                Container(child: Center(child: Text("songs"))),
                Container(child: Center(child: Text("albums"))),
                Container(child: Center(child: Text("playlists"))),
              ],
            ),
          ),
        ));
  }

  Widget _buildHorizontalAlbums(AppBloc bloc) {
    return StreamBuilder<List<AlbumInfo>>(
      stream: bloc.albumStream,
      builder: (context, snapshot) {
        return HorizontalListItemsBuilder<AlbumInfo>(
          snapshot: snapshot,
          itemBuilder: (context, album) => AlbumCard(albumData: album),
        );
      },
    );
  }

  Widget _buildVerticalRecentSongs(AppBloc bloc) {
    return Expanded(
      child: StreamBuilder<List<SongInfo>>(
          stream: bloc.songStream,
          builder: (context, snapshot) {
            return VerticalListItemBuilder<SongInfo>(
              snapshot: snapshot,
              itemBuilder: (context, song) => SongListTile(songData: song),
            );
          }),
    );
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
