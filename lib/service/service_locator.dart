import 'package:audio_service/audio_service.dart';
import 'package:flutter_backgorund_audio_player/page_manager.dart';
import 'package:flutter_backgorund_audio_player/service/play_list_repository.dart';
import 'package:get_it/get_it.dart';
import 'audio_handler.dart';

GetIt getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // services
  getIt.registerLazySingleton<PlaylistRepository>(() => DemoPlaylist());

  // page state
  getIt.registerLazySingleton<PageManager>(() => PageManager());
}
