import 'dart:async';

import 'package:flutter_audio_query/flutter_audio_query.dart';

enum NavigationOptions { HOME, ARTISTS, ALBUMS, SONGS, PLAYLISTS }
enum SearchBarState { COLLAPSED, EXPANDED }

class AppBloc {
  AppBloc() {
    _navigationController.stream.listen(onDataNavigationChangeCallback);
    _navigationController.sink.add(NavigationOptions.HOME);

  }

  final FlutterAudioQuery audioQuery = FlutterAudioQuery();

  final StreamController<List<AlbumInfo>> _albumController =
      StreamController.broadcast();

  AlbumSortType _albumSortTypeSelected = AlbumSortType.DEFAULT;
// data query streams

  final StreamController<List<ArtistInfo>> _artistController =
      StreamController.broadcast();

   ArtistSortType _artistSortTypeSelected = ArtistSortType.DEFAULT;
//navigation stream controller

  final StreamController<NavigationOptions> _navigationController =
      StreamController.broadcast();

  final StreamController<List<PlaylistInfo>> _playlistController =
      StreamController.broadcast();

  PlaylistSortType _playlistSortTypeSelected = PlaylistSortType.DEFAULT;
  final StreamController<SearchBarState> _searchBarController =
      StreamController.broadcast();

  final StreamController<List<SongInfo>> _songController =
      StreamController.broadcast();

  SongSortType _songSortTypeSelected = SongSortType.DEFAULT;

  Stream<NavigationOptions> get currentNavigationOption =>
      _navigationController.stream;

  Stream<List<ArtistInfo>> get artistStream => _artistController.stream;

  Stream<List<AlbumInfo>> get albumStream => _albumController.stream;

  Stream<List<SongInfo>> get songStream => _songController.stream;

  Stream<List<PlaylistInfo>> get playlistStream => _playlistController.stream;

  Stream<SearchBarState> get searchBarStream => _searchBarController.stream;

   void loadPlaylistData() {
    audioQuery.getPlaylists().then((playlist) {
      _playlistController.sink.add(playlist);
    }).catchError((error) {
      _playlistController.sink.addError(error);
    });
  }

  void changeNavigation(final NavigationOptions option) =>
      _navigationController.sink.add(option);

  void _fetchArtistData({String query}) {
    if (query == null)
      audioQuery
          .getArtists(sortType: _artistSortTypeSelected)
          .then((data) => _artistController.sink.add(data))
          .catchError((error) => _artistController.sink.addError(error));
    else
      audioQuery
          .searchArtists(query: query)
          .then((data) => _artistController.sink.add(data))
          .catchError((error) => _artistController.sink.addError(error));
  }

  void _fetchPlaylistData({String query}) {
    if (query == null)
      audioQuery
          .getPlaylists(sortType: _playlistSortTypeSelected)
          .then(
              (playlistData) => _playlistController.sink.add(playlistData))
          .catchError((error) => _playlistController.sink.addError(error));
    else
      audioQuery
          .searchPlaylists(query: query)
          .then(
              (playlistData) => _playlistController.sink.add(playlistData))
          .catchError((error) => _playlistController.sink.addError(error));
  }

  void _fetchAlbumData({String query}) {
    if (query == null)
      audioQuery
          .getAlbums(sortType: _albumSortTypeSelected)
          .then((data) => _albumController.sink.add(data))
          .catchError((error) => _albumController.sink.addError(error));
    else
      audioQuery
          .searchAlbums(query: query)
          .then((data) => _albumController.sink.add(data))
          .catchError((error) => _albumController.sink.addError(error));
  }

  void _fetchSongData({String query,NavigationOptions option}) {
    if (query == null)
      audioQuery
          .getSongs(sortType: option==NavigationOptions.HOME? SongSortType.RECENT_YEAR :_songSortTypeSelected)
          .then((songList) => _songController.sink.add(songList))
          .catchError((error) => _songController.sink.addError(error));
    else
      audioQuery
          .searchSongs(query: query)
          .then((songList) => _songController.sink.add(songList))
          .catchError((error) => _songController.sink.addError(error));
  }

  onDataNavigationChangeCallback(final NavigationOptions option) {
    switch (option) {
      case NavigationOptions.ARTISTS:
        _fetchArtistData();
        break;

      case NavigationOptions.PLAYLISTS:
        _fetchPlaylistData();
        break;

      case NavigationOptions.ALBUMS:
        _fetchAlbumData();
        break;

      case NavigationOptions.SONGS:
        _fetchSongData();
        break;

      case NavigationOptions.HOME:
        _fetchAlbumData();
        _fetchSongData(option: NavigationOptions.HOME);
        break;
    }
  }

  void search({NavigationOptions option, final String query}) {
    switch (option) {
      case NavigationOptions.ARTISTS:
        _fetchArtistData(query: query);
        break;

      case NavigationOptions.PLAYLISTS:
        _fetchPlaylistData(query: query);
        break;

      case NavigationOptions.ALBUMS:
        _fetchAlbumData(query: query);
        break;

      case NavigationOptions.SONGS:
        _fetchSongData(query: query);
        break;

      case NavigationOptions.HOME:
        _fetchAlbumData(query: query);
        _fetchPlaylistData(query:query);
        break;
    }
  }

   void changeSearchBarState(final SearchBarState newState) =>
      _searchBarController.sink.add(newState);

  void dispose() {
    _navigationController?.close();
    _artistController?.close();
    _albumController?.close();
    _songController?.close();
    
    _playlistController?.close();
    _searchBarController?.close();
  }
}
