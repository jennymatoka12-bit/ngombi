import 'package:flutter/foundation.dart';

/// Shared signal used to suspend advertising while a TV channel is open.
final ValueNotifier<bool> ngombiTvPlaybackActive = ValueNotifier<bool>(false);
