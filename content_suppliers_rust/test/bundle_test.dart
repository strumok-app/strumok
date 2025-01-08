import 'package:cached_network_image/cached_network_image.dart';
import 'package:content_suppliers_api/model.dart';
import 'package:content_suppliers_rust/bundle.dart';
import 'package:test/test.dart';

const libDirectory = "rust/target/release/";
const libName = "content_suppliers_rust";

void main() async {
  final bundle = RustContentSuppliersBundle(
    directory: libDirectory,
    libName: libName,
  );

  await bundle.load();

  final suppliers = await bundle.suppliers;
  test("should return avalaible suppliers", () async {
    expect(suppliers.length, equals(1));
    expect(suppliers.map((v) => v.name).toList(), equals(["dummy"]));
  });

  test("should retun channels", () async {
    final supplier = suppliers.first;
    final channels = supplier.channels;

    expect(channels, equals(["dummy_channels"]));
  });

  test("should retun default channels", () async {
    final supplier = suppliers.first;
    final channels = supplier.defaultChannels;

    expect(channels, equals(["dummy_channels"]));
  });

  test("should retun supported types", () async {
    final supplier = suppliers.first;
    final types = supplier.supportedTypes;

    expect(types, equals({ContentType.movie, ContentType.anime}));
  });

  test("should retun supported languges", () async {
    final supplier = suppliers.first;
    final types = supplier.supportedLanguages;

    expect(types, equals({ContentLanguage.en, ContentLanguage.uk}));
  });

  test("should load search results", () async {
    const query = "test";
    final type = {ContentType.anime};

    final supplier = suppliers.first;
    final results = await supplier.search(query, type);

    expect(results.length, equals(1));

    final searchResult = results.first;

    expect(searchResult.id, equals(query));
    expect(searchResult.supplier, equals("dummy"));
    expect(searchResult.title, equals(type.map((t) => t.name).join(",")));
    expect(searchResult.secondaryTitle, equals("secondary_dummy_title"));
    expect(searchResult.image, equals("dummy_image"));
  });

  test("should load channels", () async {
    const channel = "dummy_channel";
    const page = 10;

    final supplier = suppliers.first;
    final items = await supplier.loadChannel(channel, page: page);

    expect(items.length, equals(1));

    final channelItem = items.first;

    expect(channelItem.id, equals("$channel $page"));
    expect(channelItem.supplier, equals("dummy"));
    expect(channelItem.title, equals("dummy_title"));
    expect(channelItem.secondaryTitle, equals("secondary_dummy_title"));
    expect(channelItem.image, equals("dummy_image"));
  });

  test("should load content details", () async {
    const id = "dummy_id";

    final supplier = suppliers.first;
    final details = await supplier.detailsById(id);

    expect(details, isNotNull);
    expect(details!.id, equals(id));
    expect(details.supplier, equals("dummy"));
    expect(details.title, equals("dummy_title $id"));
    expect(details.originalTitle, equals("original_dummy_title"));
    expect(details.image, equals("dummy_image"));
    expect(details.description, equals("dummy_description"));
    expect(details.mediaType, equals(MediaType.video));
    expect(
      details.additionalInfo,
      equals(["dummy_additional_info1", "dummy_additional_info2"]),
    );
    expect(details.similar.length, equals(1));

    final similar = details.similar.first;
    expect(similar.id, equals("dummy_similar"));
    expect(similar.supplier, equals("dummy"));
    expect(similar.title, equals("dummy_title"));
    expect(similar.secondaryTitle, equals("secondary_dummy_title"));
    expect(similar.image, equals("dummy_image"));

    final mediaItems = await details.mediaItems;
    expect(mediaItems.length, equals(1));

    final mediaItem = mediaItems.first;
    expect(mediaItem.number, equals(42));
    expect(mediaItem.title, equals(id));
    expect(mediaItem.section, equals("1,2,3"));
    expect(mediaItem.image, equals("dummy_image"));

    final sources = await mediaItem.sources;
    expect(sources.length, equals(3));

    expect(sources[0], isA<MediaFileItemSource>());
    final videoSource = sources[0] as MediaFileItemSource;

    expect(await videoSource.link, equals(Uri.parse("http://dummy_link")));
    expect(videoSource.kind, equals(FileKind.video));
    expect(videoSource.description, equals("$id 1,2,3"));
    expect(videoSource.headers, equals({"User-Agent": "dummy"}));

    expect(sources[1], isA<MediaFileItemSource>());
    final subtitleSource = sources[1] as MediaFileItemSource;

    expect(await subtitleSource.link, equals(Uri.parse("http://dummy_link")));
    expect(subtitleSource.kind, equals(FileKind.subtitle));
    expect(subtitleSource.description, equals("$id 1,2,3"));
    expect(subtitleSource.headers, equals({"User-Agent": "dummy"}));

    expect(sources[2], isA<MangaMediaItemSource>());
    final mangaSource = sources[2] as MangaMediaItemSource;

    expect(
        await mangaSource.allPages(),
        equals([
          const CachedNetworkImageProvider("http://page1"),
          const CachedNetworkImageProvider("http://page2"),
        ]));
    expect(mangaSource.pageNambers, 2);
    expect(mangaSource.kind, equals(FileKind.manga));
    expect(mangaSource.description, equals("$id 1,2,3"));
    expect(mangaSource.pageNambers, equals(2));
  });

  test("should_load_manga_page_async", () async {
    const id = "async_manga";

    final supplier = suppliers.first;
    final details = await supplier.detailsById(id);

    expect(details, isNotNull);

    final mediaItems = await details!.mediaItems;
    expect(mediaItems.length, equals(1));

    final mediaItem = mediaItems.first;

    final sources = await mediaItem.sources;
    expect(sources.length, equals(1));

    final source = sources[0];
    expect(source, isA<MangaMediaItemSource>());
    final mangaSource = source as MangaMediaItemSource;
    expect(
        await mangaSource.allPages(),
        equals([
          const CachedNetworkImageProvider("http://${id}_$id"),
        ]));
    expect(mangaSource.pageNambers, 2);
    expect(mangaSource.kind, equals(FileKind.manga));
    expect(mangaSource.description, id);
    expect(mangaSource.pageNambers, equals(2));
  });

  test("should load data eagerly", () async {
    const id = "eager_sources";

    final supplier = suppliers.first;
    final details = await supplier.detailsById(id);

    expect(details, isNotNull);

    final mediaItems = await details!.mediaItems;
    expect(mediaItems.length, equals(1));

    final mediaItem = mediaItems.first;

    final sources = await mediaItem.sources;
    expect(sources.length, equals(1));

    final source = sources[0];
    expect(source, isA<MediaFileItemSource>());
  });
}
