import 'dart:io';

import 'package:lyricsmatic/lyricsmatic.dart' as lyricsmatic;

void main(List<String> arguments) {
  final tags = lyricsmatic
      .getFileTags(File("~/Music/brakence/hypochondriac/04. teeth.opus"));

  print(tags);
}
