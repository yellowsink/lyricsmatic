import 'dart:io';

import 'package:lyricsmatic/lyricsmatic.dart' as lyricsmatic;

void main(List<String> arguments) async {
  final file = File("/home/sink/Music/brakence/hypochondriac/04. teeth.opus");
  final songMeta = await lyricsmatic.SongMeta.fromFile(file);
  print(songMeta.isrc);
}
