import 'dart:async';
import 'dart:convert';

import 'package:cloud_hook/content_suppliers/extrators/cryptojs.dart';
import 'package:cloud_hook/content_suppliers/extrators/source/multi_api_keys.dart';
import 'package:cloud_hook/content_suppliers/extrators/utils.dart';
import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:cloud_hook/content_suppliers/scrapper/scrapper.dart';
import 'package:cloud_hook/content_suppliers/scrapper/selectors.dart';
import 'package:cloud_hook/content_suppliers/utils.dart';
import 'package:cloud_hook/utils/logger.dart';
import 'package:dio/dio.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:json_annotation/json_annotation.dart';

part 'moviesapi.g.dart';

@JsonSerializable(createToJson: false)
class _CryptoJSParams {
  final String ct;
  final String iv;
  final String s;

  _CryptoJSParams({
    required this.ct,
    required this.iv,
    required this.s,
  });

  factory _CryptoJSParams.fromJson(Map<String, dynamic> json) =>
      _$CryptoJSParamsFromJson(json);
}

class MoviesapiSourceLoader {
  static const baseUrl = "https://moviesapi.club";
  static const iframeBaseUrl = "https://w1.moviesapi.club";

  static final _aesRegExp = RegExp(r"JScripts\s+=\s+'(?<aes>[^']+)'");
  static final _fileRegExp = RegExp(r'"file":\s*"(?<file>[^"]+)');
  static final _subtitlesRegExp = RegExp(r'"subtitle"?:\s*"(?<subtitle>[^"]+)');

  final int tmdb;
  final int? episode;
  final int? season;

  MoviesapiSourceLoader({
    required this.tmdb,
    this.episode,
    this.season,
  });

  Future<List<ContentMediaItemSource>> call() async {
    String url;

    if (episode == null) {
      url = "$baseUrl/movie/$tmdb";
    } else {
      url = "$baseUrl/tv/$tmdb-$season-$episode";
    }

    final iframe =
        await Scrapper(uri: url, headers: {"Referer": baseUrl}).scrap(
      Attribute.forScope("#frame2", "src"),
    );

    if (iframe == null || iframe.isEmpty) {
      logger.w("[moviesapi] iframe not found");
      return [];
    }

    return await _extractIframe(iframe, url);
  }

  Future<List<ContentMediaItemSource>> _extractIframe(
    String iframe,
    String url,
  ) async {
    final iframeRes = await dio.get(
      iframe,
      options: Options(headers: {
        ...defaultHeaders,
        "Referer": url,
      }),
    );

    final page = iframeRes.data as String;
    final aesJsonStr = _aesRegExp.firstMatch(page)?.namedGroup("aes");

    if (aesJsonStr == null) {
      logger.w("[moviesapi] Encrypted code not found");
      return [];
    }

    final cryptoParams = _CryptoJSParams.fromJson(json.decode(aesJsonStr));

    final apiKeys = await MultiApiKeys.fetch();

    if (apiKeys.chillx?.isEmpty ?? true) {
      logger.w("[moviesapi] chillx key not found");
      return [];
    }

    final (key, iv) = deriveKeyAndIV(
      utf8.encode(apiKeys.chillx!.first),
      hexToBytes(cryptoParams.s),
    );

    final encrypter = encrypt.Encrypter(encrypt.AES(
      encrypt.Key(key),
      mode: encrypt.AESMode.cbc,
      padding: "PKCS7",
    ));

    final script = encrypter
        .decrypt64(cryptoParams.ct, iv: encrypt.IV(iv))
        .replaceAll(r"\", "");

    final fileUrl = _fileRegExp.firstMatch(script)?.namedGroup("file");

    if (fileUrl == null) {
      logger.w("[moviesapi] file url not found");
      return [];
    }

    final subtitlesSources = [];
    final subtitles =
        _subtitlesRegExp.firstMatch(script)?.namedGroup("subtitle");

    if (subtitles != null) {}

    const headers = {
      ...defaultHeaders,
      "Accept": "*/*",
      "Connection": "keep-alive",
      "Sec-Fetch-Dest": "empty",
      "Sec-Fetch-Mode": "cors",
      "Sec-Fetch-Site": "cross-site",
      "Origin": iframeBaseUrl,
      "Referer": iframeBaseUrl
    };

    return [
      SimpleContentMediaItemSource(
        description: "Moviesapi",
        link: Uri.parse(fileUrl),
        headers: headers,
      ),
      ...subtitlesSources
    ];
  }
}