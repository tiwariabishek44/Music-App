import 'package:flutter/foundation.dart';

import 'package:audio_service/audio_service.dart';
import 'package:flutter_backgorund_audio_player/notifiers/play_button_notifier.dart';
import 'package:flutter_backgorund_audio_player/notifiers/progress_notifier.dart';
import 'package:flutter_backgorund_audio_player/notifiers/repete_button_notifier.dart';
import 'package:flutter_backgorund_audio_player/service/play_list_repository.dart';
import 'package:flutter_backgorund_audio_player/service/service_locator.dart';
import 'package:flutter_tts/flutter_tts.dart';

class PageManager {
  FlutterTts flutterTts = FlutterTts();

  Future<void> initTts() async {
    await flutterTts.setLanguage('ne-NP');
    await flutterTts.setSpeechRate(0.1);
    await flutterTts.setVolume(1.0);
  }

  Future<void> speak() async {
    String text = '''
     ‘अहिले हामी राजश्वको दृष्टिकोणबाट धेरै दबाबमा छौँ । राजश्व केही वृद्धि भएको छ, तर हामीले जुन लक्ष्य निर्धारण गरेका थियौँ, त्यो अनुसार हुन सकेको छैन,' अर्थमन्त्री महतले भने, 'त्यो नहुनुको कारण एउटा त राजश्व संरचनामा परिवर्तन आइरहेको छ । डिजिटल युगमा संसारै अगाडि बढेको छ। यो डिजिटलाइजेशन सँग-सँगै अब ट्रान्जेक्शन व्यवसाय गर्ने शैली परिवर्तन भइसकेको छ । सरकारले पनि तौरतरिकालाई बदल्नुपर्ने देखिएको छ ।'

उनले डिजिटल प्रविधि र अनलाइनबाट भइरहेका व्यवसायबाट कर संकलन गर्न नसकेको बताए । 'डिजिटलाइजेसनमा आधारित ठुलो बजार खडा भइसकेको छ । तर त्यहाँ आन्तरिक राजस्व कार्यालयले केही गर्न सकेको अवस्था छैन,' उनले भने, 'भन्सार कार्यालयले आफूलाई पनि अपडेट गर्नुपर्ने अवस्था आएको छ ।'

मन्त्री महतले पछिल्लो समयमा राजस्व कम हुनुमा डिजेल र पेट्रोल गाडीको प्रयोग कम हुनुलाई समेत उदाहरणकारुपमा लिए । 'हामी डिजेल/पेट्रोल गाडी आयात गर्थ्यौं, त्यसबाट ठुलो राजस्व जम्मा हुन्थ्यो । तर अहिले इभीको प्रयोग बढेको छ । र इभी नेपालमै बनिरहेको छ,' उनले भने, 'यसबाट मात्रै पनि सरकारी ढुकुटीमा राजस्वको करिब ३४/३५ अर्व रुपैयाँ कम भएको देखिन्छ ।' उनले अनलाइन प्रणालीलाई व्यवहारिक रुपमा कार्यान्वयन गर्न जरुरी रहेको बताए ।
    ''';
    if (text.isNotEmpty) {
      await flutterTts.speak(text);
    }
  }

  // Listeners: Updates going to the UI
  final currentSongTitleNotifier = ValueNotifier<String>('');
  final playlistNotifier = ValueNotifier<List<String>>([]);
  final progressNotifier = ProgressNotifier();
  final repeatButtonNotifier = RepeatButtonNotifier();
  final isFirstSongNotifier = ValueNotifier<bool>(true);
  final playButtonNotifier = PlayButtonNotifier();
  final isLastSongNotifier = ValueNotifier<bool>(true);
  final isShuffleModeEnabledNotifier = ValueNotifier<bool>(false);

  final _audioHandler = getIt<AudioHandler>();
  void init() async {
    await _loadPlaylist();
    _listenToChangesInPlaylist();
    _listenToPlaybackState();
  }

  Future<void> _loadPlaylist() async {
    final songRepository = getIt<PlaylistRepository>();
    final playlist = await songRepository.fetchInitialPlaylist();
    final mediaItems = playlist
        .map((song) => MediaItem(
              id: song['id'] ?? '',
              album: song['album'] ?? '',
              title: song['title'] ?? '',
              extras: {'url': song['url']},
            ))
        .toList();
    _audioHandler.addQueueItems(mediaItems);
  }

  void _listenToChangesInPlaylist() {
    _audioHandler.queue.listen((playlist) {
      if (playlist.isEmpty) return;
      final newList = playlist.map((item) => item.title).toList();
      playlistNotifier.value = newList;
    });
  }

  void play() => _audioHandler.play();
  void pause() => _audioHandler.pause();

  void _listenToPlaybackState() {
    _audioHandler.playbackState.listen((playbackState) {
      final isPlaying = playbackState.playing;
      final processingState = playbackState.processingState;
      if (processingState == AudioProcessingState.loading ||
          processingState == AudioProcessingState.buffering) {
        playButtonNotifier.value = ButtonState.loading;
      } else if (!isPlaying) {
        playButtonNotifier.value = ButtonState.paused;
      } else if (processingState != AudioProcessingState.completed) {
        playButtonNotifier.value = ButtonState.playing;
      } else {
        _audioHandler.seek(Duration.zero);
        _audioHandler.pause();
      }
    });
  }

  void seek(Duration position) {}
  void previous() {}
  void next() {}
  void repeat() {}
  void shuffle() {}
  void add() {}
  void remove() {}
  void dispose() {}
}
