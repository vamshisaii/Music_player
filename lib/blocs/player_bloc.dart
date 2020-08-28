import 'package:assets_audio_player/assets_audio_player.dart';
import 'dart:async';

import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'dart:math';

class PlayerBloc {
  AssetsAudioPlayer assetsAudioPlayer = AssetsAudioPlayer();
  int index = 0;
  List<SongInfo>
      songs; //this list is used to track and operate player properties.
  SongInfo currentSong; //tracking current song.
  List<SongInfo>
      queueList; //this list is added to songs list at specific index for queueing up new songs

  final StreamController<SongInfo> _currentSong =
      StreamController<SongInfo>.broadcast();

  PlayerBloc() {
    currentList.listen((event) {
      songs = event;
    });
    queueStream.listen((event) {
      print("queue list $event");
    });
  }

  final StreamController<bool> _loop = StreamController<bool>.broadcast();
  final StreamController<bool> _playerOpen = StreamController<bool>.broadcast();
  final StreamController<bool> _shuffle = StreamController<bool>.broadcast();
  final StreamController<List<SongInfo>> _currentSongList =
      StreamController<List<SongInfo>>.broadcast();
  final StreamController<List<SongInfo>> _currentQueueList =
      StreamController<List<SongInfo>>.broadcast();

  Stream<bool> get isPlaying => assetsAudioPlayer.isPlaying;

  //current song info from assets audio player, flutter audio query not working properly
  Stream<Playing> get currentSongInfo => assetsAudioPlayer.current;
  Stream<Playing> get currentSongInfo2 => assetsAudioPlayer.current;

  Stream<bool> get isPlayerOpen => _playerOpen.stream;
  Stream<List<SongInfo>> get currentList => _currentSongList.stream;
  Stream<SongInfo> get currentSongPlaying => _currentSong.stream;
  Stream<List<SongInfo>> get queueStream => _currentQueueList.stream;

  Stream<bool> get isShuffle => _shuffle.stream;

  Stream<bool> get isLoop => _loop.stream;

  Stream<Duration> get currentDuration => assetsAudioPlayer.currentPosition;

  Stream<bool> get songFinished => assetsAudioPlayer.playlistFinished;

  void controlPlaylist() async {
    String totalDuration;
    bool shuffle;
    bool loop;
    //move to next song once finished
    currentSongPlaying.listen((event) {
      currentSong = event;
      totalDuration = currentSong.duration;
    });

    isShuffle.listen((event) {
      shuffle = event;
    });

    isLoop.listen((event) {
      loop = event;
    });

    currentDuration.listen((currentDuration) {
      if (totalDuration != null) {
        if (loop) {
          assetsAudioPlayer.setLoopMode(LoopMode.single);
        } else {
          if (shuffle) {
            if (currentDuration.inSeconds >
                (int.parse(totalDuration) ~/ 1000) - 0.1) {
              shufflePlaylist();
              Future.delayed(Duration(milliseconds: 100));
            }
          } else {
            assetsAudioPlayer.setLoopMode(LoopMode.none);
            if (currentDuration.inSeconds >
                int.parse(totalDuration) ~/ 1000 - 0.1) {
              next();
              Future.delayed(Duration(milliseconds: 100));
            }
          }
        }
        /*if (await isShuffle.first) {
                print('shuffle is true and waitin ');
                if (currentDuration.inSeconds >
                    (int.parse(totalDuration.duration) ~/ 1000) - 1) {
                  shufflePlaylist();
                  Future.delayed(Duration(milliseconds: 200));
                }
              } else {
                print('shuffle is false and waitin');
                if (currentDuration.inSeconds >
                    int.parse(totalDuration.duration) ~/ 1000 - 1) {
                  print('next');
                  next();
                  Future.delayed(Duration(milliseconds: 200));
                }*/
      }
    });
    //delay added so that it doesn't throw playerBloc.next more than once.:)
  }

  void playSong(String path, SongInfo song) {
    if (assetsAudioPlayer.isPlaying.value) {
      assetsAudioPlayer.stop();

      assetsAudioPlayer.open(
        Audio.file(path),
        showNotification: true,
      );
      setCurrentSong(song);
    } else {
      assetsAudioPlayer.open(Audio.file(path), showNotification: true);
      setCurrentSong(song);
    }
  }

  void setplayerStatus(bool playerstatus) {
    _playerOpen.add(playerstatus);
  }

  void setShuffle(bool isShuffle) {
    _shuffle.sink.add(isShuffle);
  }

  void setCurrentSong(SongInfo song) {
    currentSong = song;

    _currentSong.add(song);
  }

  void playPauseSong() {
    assetsAudioPlayer.playOrPause();
  }

  void seekTo(Duration duration) {
    assetsAudioPlayer.seek(duration);
  }

  void updateCurrentSongsList(List<SongInfo> songs) {
    _currentSongList.add(songs);
  }

  void updateQueueList(List<SongInfo> songs) {
    _currentQueueList.add(songs);
  }

  void trackCurrentSongList() {
    List<String> songsPath = songs.map((e) => e.filePath).toList();
    songs.forEach((element) {});
    currentSongPlaying.listen((event) {
      index = songsPath
          .indexWhere((element) => element.startsWith('${event.filePath}'));
    });
  }

  void next() {
    List<String> songsPath = songs.map((e) => e.filePath).toList();
    setCurrentSong(songs[index + 1]);
    assetsAudioPlayer.stop();
    assetsAudioPlayer.open(Audio.file(songsPath[index + 1]),
        showNotification: true);
  }

  void previous() {
    List<String> songsPath = songs.map((e) => e.filePath).toList();
    setCurrentSong(songs[index - 1]);
    assetsAudioPlayer.stop();
    assetsAudioPlayer.open(Audio.file(songsPath[index - 1]),
        showNotification: true);
  }

  void shufflePlaylist() {
    List<String> songsPath = songs.map((e) => e.filePath).toList();
    Random random = Random();
    int randomIndex = random.nextInt(songsPath.length);
    setCurrentSong(songs[randomIndex]);
    assetsAudioPlayer.stop();
    assetsAudioPlayer.open(Audio.file(songsPath[randomIndex]),
        showNotification: true);
  }

  void setLoop(bool loop) {
    _loop.add(loop);
  }

  void dispose() {
    _playerOpen.close();
    _currentSong.close();
    _shuffle.close();
    _loop.close();
    _currentSongList.close();
    _currentQueueList.close();
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
