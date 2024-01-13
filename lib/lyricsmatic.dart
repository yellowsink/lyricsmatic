import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';

// someone is going to murder me for using regex and processes for this.
Future<Map<String, String>> getFileTags(File f) async {
  // run ffprobe
  var res = await Process.run("ffprobe", [
    "-of",
    "json=c=1",
    "-show_entries",
    "format_tags",
    "-show_entries",
    "stream_tags",
    "-v",
    "error",
    f.absolute.path
  ]);

  var parsed = jsonDecode(res.stdout);

  return (parsed["format"] as Map).containsKey("tags")
      ? parsed["format"]["tags"]
      : parsed["streams"][0]["tags"];
}

class SongMeta {
  File fs;
  // preferred
  String? isrc; // International Standard Recording Code
  // second, third choice, etc.
  String? mbidTrack; // Musicbrainz Track ID
  String? mbidRecording;
  // and failing that (we probably have all or none), search:
  String? trackName;
  String? artistName;

  SongMeta(this.fs) {
    throw UnimplementedError();
  }
}

class LyricsFetcher {
  final Client client = Client();
  List<SongMeta> queue = [];

  void close() {
    client.close();
  }
}
