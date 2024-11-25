import 'dart:async';

import 'package:content_suppliers_api/model.dart';
import '../../scrapper/scrapper.dart';
import '../../scrapper/selectors.dart';
import '../../extrators/dle/dle_ajax_playlist_extractor.dart';
import 'ralodeplayer_extractor.dart';
import '../utils.dart';
import 'package:json_annotation/json_annotation.dart';

part 'anitube.g.dart';

const _siteHost = "anitube.in.ua";

class AniTubeSupplier extends ContentSupplier
    with PageableChannelsLoader, DLESearch, DLEChannelsLoader {
  static final _additionaInfoSectionsPatterns = [
    RegExp(r"Рік виходу аніме:\s+.*"),
    RegExp(r"Жанр:\s+.*"),
    RegExp(r"Режисер:\s+.*"),
    RegExp(r"Студія:\s+.*"),
  ];

  static final _originaTitlePattern = RegExp(r"Оригінальна назва:\s+.*");
  static final _dleLoginHashPattern =
      RegExp(r"dle_login_hash\s+=\s+'(?<hash>[a-z0-9]+)'");
  static final _ralodePlayerPattern =
      RegExp(r"RalodePlayer\.init\((?<params>.*)\);");

  @override
  final host = _siteHost;

  @override
  String get name => "AniTube";

  @override
  Selector<List<Map<String, dynamic>>> get contentInfoSelector => Iterate(
        itemScope: "article.story",
        item: SelectorsToMap({
          "supplier": Const(name),
          "id": UrlId.forScope(".story_c > h2 > a"),
          "title": TextSelector.forScope(".story_c > h2 > a"),
          "image": Image.forScope(".story_c_l img", host),
        }),
      );

  @override
  Set<ContentType> supportedTypes = const {ContentType.anime};

  @override
  Set<ContentLanguage> supportedLanguages = const {ContentLanguage.uk};

  @override
  Future<ContentDetails?> detailsById(String id) async {
    final scrapper = Scrapper(uri: Uri.https(host, "/$id.html"));

    final result = await scrapper.scrap(Scope(
      scope: "div.content",
      item: SelectorsToMap(
        {
          "id": Const(id),
          "supplier": Const(name),
          "title": TextSelector.forScope(".story_c > .rcol > h2"),
          "image": Image.forScope(".story_c .story_post img", host),
          "description": TextNode.forScope(
            ".story_c > .rcol > .story_c_r > .story_c_text > .my-text",
          ),
          "htmlMess": TextSelector.forScope(".rcol > .story_c_r"),
          "similar": Iterate(
            itemScope: "ul.portfolio_items > li",
            item: SelectorsToMap({
              "supplier": Const(name),
              "id": UrlId.forScope(".sl_poster > a"),
              "title": TextSelector.forScope(".text_content > a"),
              "image": Scope(
                scope: ".sl_poster img",
                item: Any.selectors([
                  Image(host, attribute: "data-src"),
                  Image(host),
                ]),
              ),
            }),
          )
        },
      ),
    ));

    if (result == null) {
      return null;
    }

    // I wish burn in hell to the person who made this site markup
    if (result["htmlMess"] != null) {
      final additionalInfo = [];
      final htmlMess = result["htmlMess"] as String;
      for (final sectionPattern in _additionaInfoSectionsPatterns) {
        final text = sectionPattern.firstMatch(htmlMess)?.group(0);
        if (text != null) {
          additionalInfo.add(text);
        }
      }

      result["additionalInfo"] = additionalInfo;
      result["originaTitle"] =
          _originaTitlePattern.firstMatch(htmlMess)?.group(0);
    }

    final ralodePlayerParams = _ralodePlayerPattern
        .firstMatch(scrapper.pageContent)
        ?.namedGroup("params");

    result["ralodePlayerParams"] = ralodePlayerParams;

    if (ralodePlayerParams == null) {
      result["hash"] = _dleLoginHashPattern
          .firstMatch(scrapper.pageContent)
          ?.namedGroup("hash");
    }

    result["newsId"] = id.split("-").first;

    return AniTubeContentDetails.fromJson(result);
  }

  @override
  late final channelInfoSelector = contentInfoSelector;

  @override
  Map<String, String> channelsPath = const {"Новинки": "/anime/page/"};
}

@JsonSerializable(createToJson: false)
// ignore: must_be_immutable
class AniTubeContentDetails extends AbstractContentDetails
    with AsyncMediaItems {
  final String? hash;
  final String newsId;
  final String? ralodePlayerParams;

  AniTubeContentDetails({
    required super.id,
    required super.supplier,
    required super.title,
    required super.originalTitle,
    required super.image,
    required super.description,
    required super.additionalInfo,
    required super.similar,
    required this.newsId,
    this.hash,
    this.ralodePlayerParams,
  });

  factory AniTubeContentDetails.fromJson(Map<String, dynamic> json) =>
      _$AniTubeContentDetailsFromJson(json);

  @override
  ContentMediaItemLoader get mediaExtractor => ralodePlayerParams != null
      ? RalodePlayerExtractor(ralodePlayerParams!)
      : DLEAjaxPLaylistExtractor(
          Uri.https(_siteHost, "/engine/ajax/playlists.php", {
            "user_hash": hash,
            "xfield": "playlist",
            "news_id": newsId,
          }),
          "https://$_siteHost",
        );
}
