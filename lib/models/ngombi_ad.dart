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
  final DateTime? startsAt;
  final DateTime? endsAt;

  const NgombiAd({
    required this.id, required this.title, required this.type, required this.media,
    required this.duration, required this.clickUrl, this.active = true, this.priority = 0,
    this.startsAt, this.endsAt,
  });

  bool get isRemoteMedia => media.startsWith('http://') || media.startsWith('https://');

  bool get isScheduledActive {
    if (!active) return false;
    final now = DateTime.now();
    if (startsAt != null && now.isBefore(startsAt!)) return false;
    if (endsAt != null && now.isAfter(endsAt!)) return false;
    return true;
  }

  NgombiAd copyWith({
    String? id, String? title, NgombiAdType? type, String? media, Duration? duration,
    String? clickUrl, bool? active, int? priority, DateTime? startsAt, DateTime? endsAt,
  }) => NgombiAd(
    id: id ?? this.id, title: title ?? this.title, type: type ?? this.type,
    media: media ?? this.media, duration: duration ?? this.duration, clickUrl: clickUrl ?? this.clickUrl,
    active: active ?? this.active, priority: priority ?? this.priority,
    startsAt: startsAt ?? this.startsAt, endsAt: endsAt ?? this.endsAt,
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'title': title, 'type': type.name, 'media': media,
    'durationSeconds': duration.inSeconds, 'clickUrl': clickUrl, 'active': active,
    'priority': priority, 'startsAt': startsAt?.toIso8601String(), 'endsAt': endsAt?.toIso8601String(),
  };

  factory NgombiAd.fromJson(Map<String, dynamic> json) => NgombiAd(
    id: json['id']?.toString() ?? '', title: json['title']?.toString() ?? '',
    type: json['type']?.toString() == 'video' ? NgombiAdType.video : NgombiAdType.image,
    media: json['media']?.toString() ?? '',
    duration: Duration(seconds: int.tryParse(json['durationSeconds']?.toString() ?? '') ?? 15),
    clickUrl: json['clickUrl']?.toString() ?? '', active: json['active'] == true,
    priority: int.tryParse(json['priority']?.toString() ?? '') ?? 0,
    startsAt: DateTime.tryParse(json['startsAt']?.toString() ?? ''),
    endsAt: DateTime.tryParse(json['endsAt']?.toString() ?? ''),
  );

  @override bool operator ==(Object other) => other is NgombiAd && other.id == id;
  @override int get hashCode => id.hashCode;
}
