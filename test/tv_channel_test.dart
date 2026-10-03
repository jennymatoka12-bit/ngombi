import 'package:flutter_test/flutter_test.dart';

import 'package:ngombi/models/tv_channel.dart';

void main() {
  test('parses HLS and DASH channels from an Enigma2 bouquet', () {
    const bouquet = '''
#EXTVLCOPT:http-user-agent=Mozilla/5.0
#SERVICE 4097:0:1:100:0:0:0:0:0:0:https%3a//example.com/live.m3u8:TF1
#SERVICE 4097:0:1:101:0:0:0:0:0:0:https%3a//example.com/live.mpd:M6
''';

    final channels = parseEnigma2Bouquet(bouquet);

    expect(channels, hasLength(2));
    expect(channels[0].name, 'TF1');
    expect(channels[0].type, StreamType.hls);
    expect(channels[0].headers['User-Agent'], 'Mozilla/5.0');
    expect(channels[1].name, 'M6');
    expect(channels[1].type, StreamType.dash);
  });

  test('repairs a percent-encoded stream URL', () {
    const bouquet =
        '#SERVICE 4097:0:1:100:0:0:0:0:0:0:https%3a//example.com/live.m3u8:Test';

    final channels = parseEnigma2Bouquet(bouquet);

    expect(channels.single.url, 'https://example.com/live.m3u8');
  });
}
