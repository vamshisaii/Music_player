import 'package:assets_audio_player/assets_audio_player.dart';
import 'dart:async';

import 'package:flutter_audio_query/flutter_audio_query.dart';



class PlayerBloc {


  AssetsAudioPlayer assetsAudioPlayer = AssetsAudioPlayer();


  Stream<bool> get isPlaying=>assetsAudioPlayer.isPlaying;
  


  final StreamController<bool> _playerOpen= StreamController<bool>(); 
  Stream<bool> get isPlayerOpen=>_playerOpen.stream;

  final StreamController<SongInfo> _currentSong=StreamController<SongInfo>();
  Stream<SongInfo> get currentSongPlaying=>_currentSong.stream;




  void playSong(String path) {
    if (assetsAudioPlayer.isPlaying.value) {
      assetsAudioPlayer.stop();
      
      assetsAudioPlayer.open(Audio.file(path),showNotification: true);
    }
    else assetsAudioPlayer.open(Audio.file(path));
  }

  void setplayerStatus(bool playerstatus){
    _playerOpen.add(playerstatus);


  }

  void setCurrentSong(SongInfo song){
    _currentSong.add(song);
  }

  void playPauseSong(){
    assetsAudioPlayer.playOrPause();
  }



  void dispose(){
    _playerOpen.close();
    _currentSong.close();
  }
}
