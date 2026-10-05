import 'package:flutter/foundation.dart';

enum NgombiAdType { image, video }

@immutable
class NgombiAd {
  final String id;
  final String title;
  final NgombiAdType type;
  final String media;
  final Duration duration;
  final String clickUrl;
  final bool active;
  final int priority;

  const NgombiAd({
    required this.id,
    required this.title,
    required this.type,
    required this.media,
    required this.duration,
    required this.clickUrl,
    this.active = true,
    this.priority = 0,
  });

  bool get isRemoteMedia =>
      media.startsWith('http://') || media.startsWith('https://');
}
