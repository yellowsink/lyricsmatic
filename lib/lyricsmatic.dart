import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';

// someone is going to murder me for using regex and processes for this.
Future<Map<String, String>> getFileTags(File f) async {
  // run ffprobe
  final res = await Process.run("ffprobe", [
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

  final parsed = jsonDecode(res.stdout);

  final Map<String, dynamic> tags = parsed["format"]!["tags"] != null
      ? parsed["format"]["tags"]
      : parsed["streams"][0]["tags"];

  return tags
      .map((key, value) => MapEntry(key, (value as String).toUpperCase()));
}

class SongMeta {
  File fs;
  // search options to try, in order of preference
  // if we have the ISRC we don't need to search
  String isrc; // International Standard Recording Code
  String? mbidTrack; // Musicbrainz Track ID
  String? mbidRecording; // Musicbrainz Recording ID
  // and failing that (we probably have all or none), search:
  String? trackName;
  String? artistName;

  // async construction is cool! :(
  SongMeta._(this.fs, this.isrc, this.mbidTrack, this.mbidRecording,
      this.trackName, this.artistName);

  static Future<SongMeta> fromFile(File fs) async {
    final tags = await getFileTags(fs);
    return SongMeta._(fs, tags["ISRC"]!, tags["MUSICBRAINZ_RELEASETRACKID"],
        tags["MUSICBRAINZ_TRACKID"], tags["TITLE"], tags["ARTIST"]);
  }
}

class LyricsLine {
  double start;
  double end;
  //String key; // TODO: what is itunes:key?
  int singerId;
  List<(double start, double end, String txt, bool emphasis)> chunks;
}

class LyricsBlock {
  double start;
  double end;
  String? songPart;
  List<LyricsLine> lines;
}

class Lyrics {
  List<(String type, String person)> credits;
  List<String> singers;
  double leadingSilence;
  double duration;
  List<LyricsBlock> blocks;
}

class LyricsFetcher {
  final Client client = Client();

  void close() {
    client.close();
  }

  Future getLyrics(SongMeta song) async {
    // TODO: implement search for songs without ISRCs
    final uri = Uri(
        scheme: "https",
        host: "beautiful-lyrics.socalifornian.live",
        pathSegments: ["lyrics", song.isrc]);

    final res = await client.get(uri);
    assert(res.statusCode == 200);
    final json = jsonDecode(res.body);
    assert(json["Source"] == "AppleMusic");

    final String ttml = json["Content"];
  }
}
