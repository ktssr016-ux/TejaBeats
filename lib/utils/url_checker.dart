import 'dart:developer';

bool isUrl(String url) {
  try {
    final uri = Uri.parse(url);
    return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
  } catch (e) {
    return false;
  }
}

enum UrlType {
  youtubeVideo,
  youtubePlaylist,
  spotifyTrack,
  spotifyPlaylist,
  spotifyAlbum,
  other,
}

String? extractVideoId(String url) {
  try {
    final uri = Uri.parse(url);
    if (uri.host.contains('youtube.com') || uri.host.contains('music.youtube.com')) {
      return uri.queryParameters['v'];
    }
    if (uri.host == 'youtu.be') {
      return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
    }
  } catch (e) {
    log(e.toString(), name: 'extractVideoId');
  }
  return null;
}

UrlType getUrlType(String url) {
  if (!isUrl(url)) return UrlType.other;
  try {
    final uri = Uri.parse(url);
    final host = uri.host.toLowerCase();

    // YouTube
    if (host.contains('youtube.com') || host.contains('youtu.be') ||
        host.contains('music.youtube.com')) {
      return uri.queryParameters.containsKey('list')
          ? UrlType.youtubePlaylist
          : UrlType.youtubeVideo;
    }

    // Spotify
    if (host.contains('spotify.com') || host == 'spoti.fi' || host == 'spotify.link') {
      final segments = uri.pathSegments;
      if (segments.isNotEmpty) {
        // Handle international prefixes e.g. /intl-ja/playlist/...
        final typeSegment = segments.firstWhere(
          (s) => s == 'track' || s == 'playlist' || s == 'album',
          orElse: () => '',
        );
        return switch (typeSegment) {
          'track' => UrlType.spotifyTrack,
          'playlist' => UrlType.spotifyPlaylist,
          'album' => UrlType.spotifyAlbum,
          _ => host == 'spotify.link' || host == 'spoti.fi'
              ? UrlType.spotifyPlaylist
              : UrlType.other,
        };
      }
    }
  } catch (_) {}
  return UrlType.other;
}
