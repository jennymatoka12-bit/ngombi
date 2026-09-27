import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../models/tv_channel.dart';

class StreamPlayerScreen extends StatefulWidget {
  final TvChannel channel;

  const StreamPlayerScreen({
    super.key,
    required this.channel,
  });

  @override
  State<StreamPlayerScreen> createState() => _StreamPlayerScreenState();
}

class _StreamPlayerScreenState extends State<StreamPlayerScreen> {
  late final VideoPlayerController _controller;

  bool _initialized = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.channel.url),
      );

      await _controller.initialize();

      if (!mounted) {
        return;
      }

      setState(() {
        _initialized = true;
      });

      await _controller.play();
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = error.toString();
      });
    }
  }

  @override
  void dispose() {
    if (_initialized) {
      _controller.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.channel.name),
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: _buildPlayer(),
      ),
    );
  }

  Widget _buildPlayer() {
    if (_errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 56,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 16),
            const Text(
              'Impossible de lire ce flux',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Le flux peut être indisponible ou nécessiter une '
              'protection DRM non prise en charge par ce lecteur.',
              style: TextStyle(
                color: Colors.grey.shade400,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () {
                setState(() {
                  _errorMessage = null;
                  _initialized = false;
                });

                _initializePlayer();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (!_initialized) {
      return const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Connexion au flux…',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ],
      );
    }

    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AspectRatio(
            aspectRatio: _controller.value.aspectRatio > 0
                ? _controller.value.aspectRatio
                : 16 / 9,
            child: VideoPlayer(_controller),
          ),
          const SizedBox(height: 12),
          VideoProgressIndicator(
            _controller,
            allowScrubbing: true,
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                color: Colors.white,
                iconSize: 40,
                icon: Icon(
                  _controller.value.isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_filled,
                ),
                onPressed: () {
                  setState(() {
                    if (_controller.value.isPlaying) {
                      _controller.pause();
                    } else {
                      _controller.play();
                    }
                  });
                },
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '${widget.channel.category} • ${_streamTypeLabel(widget.channel.type)}',
              style: TextStyle(
                color: Colors.grey.shade400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _streamTypeLabel(StreamType type) {
    switch (type) {
      case StreamType.hls:
        return 'HLS';
      case StreamType.dash:
        return 'DASH';
      case StreamType.unknown:
        return 'Flux';
    }
  }
}
