import 'package:assets_audio_player/assets_audio_player.dart';
import 'dart:async';

import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'dart:math';

class PlayerBloc {
  AssetsAudioPlayer assetsAudioPlayer = AssetsAudioPlayer();
  int index = 0;
  List<SongInfo> songs;

  final StreamController<SongInfo> _currentSong =
      StreamController<SongInfo>.broadcast();

  final StreamController<bool> _loop=StreamController<bool>.broadcast();
  final StreamController<bool> _playerOpen = StreamController<bool>.broadcast();
  final StreamController<bool> _shuffle=StreamController<bool>.broadcast();

  Stream<bool> get isPlaying => assetsAudioPlayer.isPlaying;

  //current song info from assets audio player, flutter audio query not working properly
  Stream<Playing> get currentSongInfo => assetsAudioPlayer.current;

  Stream<bool> get isPlayerOpen => _playerOpen.stream;

  Stream<SongInfo> get currentSongPlaying => _currentSong.stream;

  Stream<bool> get isShuffle=>_shuffle.stream;

  Stream<bool> get isLoop=> _loop.stream;

  Stream<Duration> get currentDuration => assetsAudioPlayer.currentPosition;

Stream<bool> get songFinished=> assetsAudioPlayer.playlistFinished;

  void playSong(String path) {
    if (assetsAudioPlayer.isPlaying.value) {
      assetsAudioPlayer.stop();

      assetsAudioPlayer.open(Audio.file(path), showNotification: true,);
    } else
      assetsAudioPlayer.open(Audio.file(path), showNotification: true);
  }

  void setplayerStatus(bool playerstatus) {
    _playerOpen.add(playerstatus);
  }

  void setShuffle(bool isShuffle){
    _shuffle.sink.add(isShuffle);
    
    
    
  }

  void setCurrentSong(SongInfo song) {
    _currentSong.add(song);
  }

  void playPauseSong() {
    assetsAudioPlayer.playOrPause();
  }

  void seekTo(Duration duration) {
    assetsAudioPlayer.seek(duration);
  }

  void trackCurrentSongList() {
    List<String> songsPath = songs.map((e) => e.filePath).toList();
    currentSongInfo.listen((event) {
      index = songsPath.indexWhere(
          (element) => element.startsWith('${event.audio.assetAudioPath}'));
     
    });
  }

  void next() {
    
    List<String> songsPath = songs.map((e) => e.filePath).toList();

    assetsAudioPlayer.stop();
    assetsAudioPlayer.open(Audio.file(songsPath[index + 1]),
        showNotification: true);
    setCurrentSong(songs[index + 1]);
    
  }

  void previous() {
    List<String> songsPath = songs.map((e) => e.filePath).toList();

    assetsAudioPlayer.stop();
    assetsAudioPlayer.open(Audio.file(songsPath[index - 1]),
        showNotification: true);
    setCurrentSong(songs[index + 1]);
    
  }

  void shufflePlaylist(){
List<String> songsPath = songs.map((e) => e.filePath).toList();
    Random random=Random();
    int randomIndex=random.nextInt(songsPath.length);

    assetsAudioPlayer.stop();
    assetsAudioPlayer.open(Audio.file(songsPath[randomIndex]),
        showNotification: true);
    setCurrentSong(songs[randomIndex]);
  }

  void setLoop(bool loop){
    _loop.add(loop);
    assetsAudioPlayer.toggleLoop();
  }

   void dispose() {
    _playerOpen.close();
    _currentSong.close();
    _shuffle.close();
    _loop.close();
  }
}



//  List<Audio> audios;

// print(streamSongs.first.then((value) => print(value)));

/* tried to add songstream to playlist to control next and previous tracks but playlist plugin in assets audio player not working properly, throwing some platform errors
    
     await streamSongs.forEach((element) {
      //songs.addAll(element);
      print(element);
    });
    
    
    streamSongs.listen((event)async {
     // songs.addAll(event);
     songs.addAll(event);
      print(event);
      print('lskdfj');



    });
    
    
     songs.forEach((element) {
      //  audios.add(Audio("${element.filePath}"));
      print(element.filePath);
    });
    
     songs.forEach((element) {
      audios.add(Audio(element));
    });
    
    
    
  void playlist(){
    isShuffle.listen((isShuffle) {
            if (isShuffle) {
             
              shufflePlaylist();
              Future.delayed(Duration(milliseconds: 200));
            } else {
             
                next();
              Future.delayed(Duration(milliseconds: 200));
              }
            
          });
  }*/
