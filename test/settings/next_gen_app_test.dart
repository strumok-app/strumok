import 'package:flutter_test/flutter_test.dart';
import 'package:strumok/settings/app_version/next_gen_app_provider.dart';

void main() {
  group('NextGenAppInfo.fromJson', () {
    test('parses GitHub latest release payload', () {
      final info = NextGenAppInfo.fromJson({
        'name': 'Strumok 2.0.0',
        'tag_name': 'v2.0.0',
        'html_url':
            'https://github.com/strumok-app/strumok2/releases/tag/v2.0.0',
      });

      expect(info.name, 'Strumok 2.0.0');
      expect(info.tagName, 'v2.0.0');
      expect(
        info.htmlUrl,
        'https://github.com/strumok-app/strumok2/releases/tag/v2.0.0',
      );
      expect(info.title, 'Strumok 2.0.0');
    });

    test('title falls back to tag when name is null', () {
      final info = NextGenAppInfo.fromJson({
        'name': null,
        'tag_name': 'v2.1.0',
        'html_url': 'https://example.com/release',
      });

      expect(info.title, 'v2.1.0');
    });

    test('title falls back to tag when name is empty', () {
      final info = NextGenAppInfo.fromJson({
        'name': '',
        'tag_name': 'v2.2.0',
        'html_url': 'https://example.com/release',
      });

      expect(info.title, 'v2.2.0');
    });
  });

  group('NextGenAppInfo.assetFor', () {
    final info = NextGenAppInfo.fromJson({
      'name': 'v2.0.7',
      'tag_name': 'v2.0.7',
      'html_url': 'https://example.com/release',
      'assets': [
        for (final name in [
          'strumok-2.0.7.apk',
          'strumok-2.0.7.exe',
          'strumok-2.0.7.tar.gz',
        ])
          {'name': name, 'browser_download_url': 'https://example.com/$name'},
      ],
    });

    test('selects platform specific asset', () {
      expect(info.assetFor('android')?.name, 'strumok-2.0.7.apk');
      expect(info.assetFor('windows')?.name, 'strumok-2.0.7.exe');
      expect(info.assetFor('linux')?.name, 'strumok-2.0.7.tar.gz');
    });

    test('returns null for unsupported platform', () {
      expect(info.assetFor('macos'), isNull);
    });

    test('returns null when release has no assets', () {
      final noAssets = NextGenAppInfo.fromJson({
        'name': 'v2.0.7',
        'tag_name': 'v2.0.7',
        'html_url': 'https://example.com/release',
      });

      expect(noAssets.assetFor('android'), isNull);
    });
  });
}
