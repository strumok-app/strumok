import 'package:flutter_test/flutter_test.dart';
import 'package:strumok/content/video/subtitles/subtitle_text_sanitizer.dart';

void main() {
  group('sanitizeCueText', () {
    test('decodes named and numeric HTML entities', () {
      expect(
        sanitizeCueText(
          'Hi &amp; bye&nbsp;&#8212; &lt;3 &#x2019;s &quot;ok&quot;',
        ),
        'Hi & bye\u00A0— <3 ’s "ok"',
      );
    });

    test('decodes astral numeric entities and rejects invalid ones', () {
      expect(sanitizeCueText('&#x1F600; &#128512;'), '😀 😀');
      expect(
        sanitizeCueText('a&#0;b &#x110000; &#xD800;'),
        'a\uFFFDb \uFFFD \uFFFD',
      );
    });

    test('keeps unknown entities and bare ampersands', () {
      expect(sanitizeCueText('Tom & Jerry &foo; &'), 'Tom & Jerry &foo; &');
    });

    test('preserves RTL marks', () {
      expect(sanitizeCueText('&rlm;שלום&lrm;'), '\u200Fשלום\u200E');
    });

    test('strips formatting tags without inserting spaces', () {
      expect(sanitizeCueText('Hel<i>lo</i> <b>world</b>'), 'Hello world');
      expect(sanitizeCueText('<I>Upper</I>'), 'Upper');
    });

    test('strips tags with attributes, classes and voices', () {
      expect(
        sanitizeCueText(
          '<font color="#ffff00">Yellow</font> <c.red.bg_blue>x</c>',
        ),
        'Yellow x',
      );
      expect(sanitizeCueText('<v Bob>Hi</v>'), 'Hi');
      expect(sanitizeCueText('<v.loud Bob Smith>Hey'), 'Hey');
      expect(sanitizeCueText('<lang en-US>Hello</lang>'), 'Hello');
      expect(sanitizeCueText('<span style="x">a</span>'), 'a');
    });

    test('strips WebVTT karaoke timestamps', () {
      expect(
        sanitizeCueText('One <00:00:05.500>two <01:02:03.004>three'),
        'One two three',
      );
    });

    test('drops ruby annotations but keeps base text', () {
      expect(sanitizeCueText('<ruby>漢<rt>kan</rt>字<rt>ji</rt></ruby>'), '漢字');
    });

    test('keeps text that only looks like markup', () {
      expect(sanitizeCueText('I <3 you'), 'I <3 you');
      expect(sanitizeCueText('a < b > c'), 'a < b > c');
      expect(sanitizeCueText('<unknown>'), '<unknown>');
    });

    test('handles double-escaped markup', () {
      expect(sanitizeCueText('&lt;i&gt;Hello&lt;/i&gt;'), 'Hello');
      expect(sanitizeCueText('Fish &amp;amp; chips'), 'Fish & chips');
      expect(sanitizeCueText('It&amp;#39;s'), "It's");
    });

    test('converts <br> to new lines', () {
      expect(sanitizeCueText('One<br>Two<BR/>Three'), 'One\nTwo\nThree');
    });

    test('removes ASS override blocks and converts ASS escapes', () {
      expect(sanitizeCueText(r'{\an8}Top line\NSecond'), 'Top line\nSecond');
      expect(sanitizeCueText(r'{\i1}It{\i0}alic'), 'Italic');
      expect(sanitizeCueText(r'a\hb'), 'a\u00A0b');
    });

    test('keeps plain braces', () {
      expect(sanitizeCueText('{laughs}'), '{laughs}');
    });

    test('decodes literal unicode escapes including surrogate pairs', () {
      expect(sanitizeCueText(r'It\u2019s'), 'It’s');
      expect(sanitizeCueText(r'\uD83D\uDE00'), '😀');
    });

    test('removes control characters and BOM', () {
      expect(sanitizeCueText('\uFEFFa\u0000b\u0007c'), 'abc');
    });

    test('normalizes whitespace and drops empty lines', () {
      expect(
        sanitizeCueText('  Hello \t  world  \r\n\r\n  <i> </i>\n Bye '),
        'Hello world\nBye',
      );
    });

    test('returns empty string for markup-only or blank cues', () {
      expect(sanitizeCueText(r'{\an8}'), '');
      expect(sanitizeCueText('<i></i>'), '');
      expect(sanitizeCueText('&nbsp;'), '');
      expect(sanitizeCueText('   \n  '), '');
    });

    test('keeps dialogue dashes and multi-line structure', () {
      expect(sanitizeCueText('- Hi.\n- <i>Bye.</i>'), '- Hi.\n- Bye.');
    });
  });
}
