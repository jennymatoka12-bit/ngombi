import 'package:flutter_test/flutter_test.dart';
import 'package:ngombi/models/tv_channel.dart';

void main() {
  test('parses HLS service and preserves URL colons', () {
    const bouquet = '''
#EXTVLCOPT:http-user-agent=Mozilla/5.0
#SERVICE 4097:0:1:1780:0:0:0:0:0:0:https%3a//example.com/live/path.m3u8:TF1
''';

    final channels = parseEnigma2Bouquet(bouquet);

    expect(channels, hasLength(1));
    expect(channels.single.name, 'TF1');
    expect(
      channels.single.url,
      'https://example.com/live/path.m3u8',
    );
    expect(channels.single.type, StreamType.hls);
    expect(
      channels.single.headers['User-Agent'],
      'Mozilla/5.0',
    );
  });

  test('classifies DASH streams', () {
    const bouquet = '''
#SERVICE 4097:0:1:1780:0:0:0:0:0:0:https%3a//example.com/live/stream.mpd:M6
''';

    final channels = parseEnigma2Bouquet(bouquet);

    expect(channels.single.type, StreamType.dash);
    expect(channels.single.category, 'France');
  });

  test('repairs mojibake in channel names', () {
    expect(
      repairMojibake('DÃ©couverte'),
      'Découverte',
    );
  });
}
