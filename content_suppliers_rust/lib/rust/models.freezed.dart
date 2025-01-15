// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ContentMediaItemSource {
  String get description => throw _privateConstructorUsedError;
  Map<String, String>? get headers => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String link, String description, Map<String, String>? headers)
        video,
    required TResult Function(
            String link, String description, Map<String, String>? headers)
        subtitle,
    required TResult Function(String description, Map<String, String>? headers,
            int pageNumbers, List<String>? pages, List<String> params)
        manga,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            String link, String description, Map<String, String>? headers)?
        video,
    TResult? Function(
            String link, String description, Map<String, String>? headers)?
        subtitle,
    TResult? Function(String description, Map<String, String>? headers,
            int pageNumbers, List<String>? pages, List<String> params)?
        manga,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            String link, String description, Map<String, String>? headers)?
        video,
    TResult Function(
            String link, String description, Map<String, String>? headers)?
        subtitle,
    TResult Function(String description, Map<String, String>? headers,
            int pageNumbers, List<String>? pages, List<String> params)?
        manga,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ContentMediaItemSource_Video value) video,
    required TResult Function(ContentMediaItemSource_Subtitle value) subtitle,
    required TResult Function(ContentMediaItemSource_Manga value) manga,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ContentMediaItemSource_Video value)? video,
    TResult? Function(ContentMediaItemSource_Subtitle value)? subtitle,
    TResult? Function(ContentMediaItemSource_Manga value)? manga,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ContentMediaItemSource_Video value)? video,
    TResult Function(ContentMediaItemSource_Subtitle value)? subtitle,
    TResult Function(ContentMediaItemSource_Manga value)? manga,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  /// Create a copy of ContentMediaItemSource
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ContentMediaItemSourceCopyWith<ContentMediaItemSource> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ContentMediaItemSourceCopyWith<$Res> {
  factory $ContentMediaItemSourceCopyWith(ContentMediaItemSource value,
          $Res Function(ContentMediaItemSource) then) =
      _$ContentMediaItemSourceCopyWithImpl<$Res, ContentMediaItemSource>;
  @useResult
  $Res call({String description, Map<String, String>? headers});
}

/// @nodoc
class _$ContentMediaItemSourceCopyWithImpl<$Res,
        $Val extends ContentMediaItemSource>
    implements $ContentMediaItemSourceCopyWith<$Res> {
  _$ContentMediaItemSourceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ContentMediaItemSource
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? description = null,
    Object? headers = freezed,
  }) {
    return _then(_value.copyWith(
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      headers: freezed == headers
          ? _value.headers
          : headers // ignore: cast_nullable_to_non_nullable
              as Map<String, String>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ContentMediaItemSource_VideoImplCopyWith<$Res>
    implements $ContentMediaItemSourceCopyWith<$Res> {
  factory _$$ContentMediaItemSource_VideoImplCopyWith(
          _$ContentMediaItemSource_VideoImpl value,
          $Res Function(_$ContentMediaItemSource_VideoImpl) then) =
      __$$ContentMediaItemSource_VideoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String link, String description, Map<String, String>? headers});
}

/// @nodoc
class __$$ContentMediaItemSource_VideoImplCopyWithImpl<$Res>
    extends _$ContentMediaItemSourceCopyWithImpl<$Res,
        _$ContentMediaItemSource_VideoImpl>
    implements _$$ContentMediaItemSource_VideoImplCopyWith<$Res> {
  __$$ContentMediaItemSource_VideoImplCopyWithImpl(
      _$ContentMediaItemSource_VideoImpl _value,
      $Res Function(_$ContentMediaItemSource_VideoImpl) _then)
      : super(_value, _then);

  /// Create a copy of ContentMediaItemSource
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? link = null,
    Object? description = null,
    Object? headers = freezed,
  }) {
    return _then(_$ContentMediaItemSource_VideoImpl(
      link: null == link
          ? _value.link
          : link // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      headers: freezed == headers
          ? _value._headers
          : headers // ignore: cast_nullable_to_non_nullable
              as Map<String, String>?,
    ));
  }
}

/// @nodoc

class _$ContentMediaItemSource_VideoImpl extends ContentMediaItemSource_Video {
  const _$ContentMediaItemSource_VideoImpl(
      {required this.link,
      required this.description,
      final Map<String, String>? headers})
      : _headers = headers,
        super._();

  @override
  final String link;
  @override
  final String description;
  final Map<String, String>? _headers;
  @override
  Map<String, String>? get headers {
    final value = _headers;
    if (value == null) return null;
    if (_headers is EqualUnmodifiableMapView) return _headers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'ContentMediaItemSource.video(link: $link, description: $description, headers: $headers)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ContentMediaItemSource_VideoImpl &&
            (identical(other.link, link) || other.link == link) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(other._headers, _headers));
  }

  @override
  int get hashCode => Object.hash(runtimeType, link, description,
      const DeepCollectionEquality().hash(_headers));

  /// Create a copy of ContentMediaItemSource
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ContentMediaItemSource_VideoImplCopyWith<
          _$ContentMediaItemSource_VideoImpl>
      get copyWith => __$$ContentMediaItemSource_VideoImplCopyWithImpl<
          _$ContentMediaItemSource_VideoImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String link, String description, Map<String, String>? headers)
        video,
    required TResult Function(
            String link, String description, Map<String, String>? headers)
        subtitle,
    required TResult Function(String description, Map<String, String>? headers,
            int pageNumbers, List<String>? pages, List<String> params)
        manga,
  }) {
    return video(link, description, headers);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            String link, String description, Map<String, String>? headers)?
        video,
    TResult? Function(
            String link, String description, Map<String, String>? headers)?
        subtitle,
    TResult? Function(String description, Map<String, String>? headers,
            int pageNumbers, List<String>? pages, List<String> params)?
        manga,
  }) {
    return video?.call(link, description, headers);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            String link, String description, Map<String, String>? headers)?
        video,
    TResult Function(
            String link, String description, Map<String, String>? headers)?
        subtitle,
    TResult Function(String description, Map<String, String>? headers,
            int pageNumbers, List<String>? pages, List<String> params)?
        manga,
    required TResult orElse(),
  }) {
    if (video != null) {
      return video(link, description, headers);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ContentMediaItemSource_Video value) video,
    required TResult Function(ContentMediaItemSource_Subtitle value) subtitle,
    required TResult Function(ContentMediaItemSource_Manga value) manga,
  }) {
    return video(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ContentMediaItemSource_Video value)? video,
    TResult? Function(ContentMediaItemSource_Subtitle value)? subtitle,
    TResult? Function(ContentMediaItemSource_Manga value)? manga,
  }) {
    return video?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ContentMediaItemSource_Video value)? video,
    TResult Function(ContentMediaItemSource_Subtitle value)? subtitle,
    TResult Function(ContentMediaItemSource_Manga value)? manga,
    required TResult orElse(),
  }) {
    if (video != null) {
      return video(this);
    }
    return orElse();
  }
}

abstract class ContentMediaItemSource_Video extends ContentMediaItemSource {
  const factory ContentMediaItemSource_Video(
      {required final String link,
      required final String description,
      final Map<String, String>? headers}) = _$ContentMediaItemSource_VideoImpl;
  const ContentMediaItemSource_Video._() : super._();

  String get link;
  @override
  String get description;
  @override
  Map<String, String>? get headers;

  /// Create a copy of ContentMediaItemSource
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ContentMediaItemSource_VideoImplCopyWith<
          _$ContentMediaItemSource_VideoImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ContentMediaItemSource_SubtitleImplCopyWith<$Res>
    implements $ContentMediaItemSourceCopyWith<$Res> {
  factory _$$ContentMediaItemSource_SubtitleImplCopyWith(
          _$ContentMediaItemSource_SubtitleImpl value,
          $Res Function(_$ContentMediaItemSource_SubtitleImpl) then) =
      __$$ContentMediaItemSource_SubtitleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String link, String description, Map<String, String>? headers});
}

/// @nodoc
class __$$ContentMediaItemSource_SubtitleImplCopyWithImpl<$Res>
    extends _$ContentMediaItemSourceCopyWithImpl<$Res,
        _$ContentMediaItemSource_SubtitleImpl>
    implements _$$ContentMediaItemSource_SubtitleImplCopyWith<$Res> {
  __$$ContentMediaItemSource_SubtitleImplCopyWithImpl(
      _$ContentMediaItemSource_SubtitleImpl _value,
      $Res Function(_$ContentMediaItemSource_SubtitleImpl) _then)
      : super(_value, _then);

  /// Create a copy of ContentMediaItemSource
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? link = null,
    Object? description = null,
    Object? headers = freezed,
  }) {
    return _then(_$ContentMediaItemSource_SubtitleImpl(
      link: null == link
          ? _value.link
          : link // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      headers: freezed == headers
          ? _value._headers
          : headers // ignore: cast_nullable_to_non_nullable
              as Map<String, String>?,
    ));
  }
}

/// @nodoc

class _$ContentMediaItemSource_SubtitleImpl
    extends ContentMediaItemSource_Subtitle {
  const _$ContentMediaItemSource_SubtitleImpl(
      {required this.link,
      required this.description,
      final Map<String, String>? headers})
      : _headers = headers,
        super._();

  @override
  final String link;
  @override
  final String description;
  final Map<String, String>? _headers;
  @override
  Map<String, String>? get headers {
    final value = _headers;
    if (value == null) return null;
    if (_headers is EqualUnmodifiableMapView) return _headers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'ContentMediaItemSource.subtitle(link: $link, description: $description, headers: $headers)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ContentMediaItemSource_SubtitleImpl &&
            (identical(other.link, link) || other.link == link) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(other._headers, _headers));
  }

  @override
  int get hashCode => Object.hash(runtimeType, link, description,
      const DeepCollectionEquality().hash(_headers));

  /// Create a copy of ContentMediaItemSource
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ContentMediaItemSource_SubtitleImplCopyWith<
          _$ContentMediaItemSource_SubtitleImpl>
      get copyWith => __$$ContentMediaItemSource_SubtitleImplCopyWithImpl<
          _$ContentMediaItemSource_SubtitleImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String link, String description, Map<String, String>? headers)
        video,
    required TResult Function(
            String link, String description, Map<String, String>? headers)
        subtitle,
    required TResult Function(String description, Map<String, String>? headers,
            int pageNumbers, List<String>? pages, List<String> params)
        manga,
  }) {
    return subtitle(link, description, headers);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            String link, String description, Map<String, String>? headers)?
        video,
    TResult? Function(
            String link, String description, Map<String, String>? headers)?
        subtitle,
    TResult? Function(String description, Map<String, String>? headers,
            int pageNumbers, List<String>? pages, List<String> params)?
        manga,
  }) {
    return subtitle?.call(link, description, headers);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            String link, String description, Map<String, String>? headers)?
        video,
    TResult Function(
            String link, String description, Map<String, String>? headers)?
        subtitle,
    TResult Function(String description, Map<String, String>? headers,
            int pageNumbers, List<String>? pages, List<String> params)?
        manga,
    required TResult orElse(),
  }) {
    if (subtitle != null) {
      return subtitle(link, description, headers);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ContentMediaItemSource_Video value) video,
    required TResult Function(ContentMediaItemSource_Subtitle value) subtitle,
    required TResult Function(ContentMediaItemSource_Manga value) manga,
  }) {
    return subtitle(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ContentMediaItemSource_Video value)? video,
    TResult? Function(ContentMediaItemSource_Subtitle value)? subtitle,
    TResult? Function(ContentMediaItemSource_Manga value)? manga,
  }) {
    return subtitle?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ContentMediaItemSource_Video value)? video,
    TResult Function(ContentMediaItemSource_Subtitle value)? subtitle,
    TResult Function(ContentMediaItemSource_Manga value)? manga,
    required TResult orElse(),
  }) {
    if (subtitle != null) {
      return subtitle(this);
    }
    return orElse();
  }
}

abstract class ContentMediaItemSource_Subtitle extends ContentMediaItemSource {
  const factory ContentMediaItemSource_Subtitle(
          {required final String link,
          required final String description,
          final Map<String, String>? headers}) =
      _$ContentMediaItemSource_SubtitleImpl;
  const ContentMediaItemSource_Subtitle._() : super._();

  String get link;
  @override
  String get description;
  @override
  Map<String, String>? get headers;

  /// Create a copy of ContentMediaItemSource
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ContentMediaItemSource_SubtitleImplCopyWith<
          _$ContentMediaItemSource_SubtitleImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ContentMediaItemSource_MangaImplCopyWith<$Res>
    implements $ContentMediaItemSourceCopyWith<$Res> {
  factory _$$ContentMediaItemSource_MangaImplCopyWith(
          _$ContentMediaItemSource_MangaImpl value,
          $Res Function(_$ContentMediaItemSource_MangaImpl) then) =
      __$$ContentMediaItemSource_MangaImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String description,
      Map<String, String>? headers,
      int pageNumbers,
      List<String>? pages,
      List<String> params});
}

/// @nodoc
class __$$ContentMediaItemSource_MangaImplCopyWithImpl<$Res>
    extends _$ContentMediaItemSourceCopyWithImpl<$Res,
        _$ContentMediaItemSource_MangaImpl>
    implements _$$ContentMediaItemSource_MangaImplCopyWith<$Res> {
  __$$ContentMediaItemSource_MangaImplCopyWithImpl(
      _$ContentMediaItemSource_MangaImpl _value,
      $Res Function(_$ContentMediaItemSource_MangaImpl) _then)
      : super(_value, _then);

  /// Create a copy of ContentMediaItemSource
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? description = null,
    Object? headers = freezed,
    Object? pageNumbers = null,
    Object? pages = freezed,
    Object? params = null,
  }) {
    return _then(_$ContentMediaItemSource_MangaImpl(
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      headers: freezed == headers
          ? _value._headers
          : headers // ignore: cast_nullable_to_non_nullable
              as Map<String, String>?,
      pageNumbers: null == pageNumbers
          ? _value.pageNumbers
          : pageNumbers // ignore: cast_nullable_to_non_nullable
              as int,
      pages: freezed == pages
          ? _value._pages
          : pages // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      params: null == params
          ? _value._params
          : params // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc

class _$ContentMediaItemSource_MangaImpl extends ContentMediaItemSource_Manga {
  const _$ContentMediaItemSource_MangaImpl(
      {required this.description,
      final Map<String, String>? headers,
      required this.pageNumbers,
      final List<String>? pages,
      required final List<String> params})
      : _headers = headers,
        _pages = pages,
        _params = params,
        super._();

  @override
  final String description;
  final Map<String, String>? _headers;
  @override
  Map<String, String>? get headers {
    final value = _headers;
    if (value == null) return null;
    if (_headers is EqualUnmodifiableMapView) return _headers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final int pageNumbers;
  final List<String>? _pages;
  @override
  List<String>? get pages {
    final value = _pages;
    if (value == null) return null;
    if (_pages is EqualUnmodifiableListView) return _pages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String> _params;
  @override
  List<String> get params {
    if (_params is EqualUnmodifiableListView) return _params;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_params);
  }

  @override
  String toString() {
    return 'ContentMediaItemSource.manga(description: $description, headers: $headers, pageNumbers: $pageNumbers, pages: $pages, params: $params)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ContentMediaItemSource_MangaImpl &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(other._headers, _headers) &&
            (identical(other.pageNumbers, pageNumbers) ||
                other.pageNumbers == pageNumbers) &&
            const DeepCollectionEquality().equals(other._pages, _pages) &&
            const DeepCollectionEquality().equals(other._params, _params));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      description,
      const DeepCollectionEquality().hash(_headers),
      pageNumbers,
      const DeepCollectionEquality().hash(_pages),
      const DeepCollectionEquality().hash(_params));

  /// Create a copy of ContentMediaItemSource
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ContentMediaItemSource_MangaImplCopyWith<
          _$ContentMediaItemSource_MangaImpl>
      get copyWith => __$$ContentMediaItemSource_MangaImplCopyWithImpl<
          _$ContentMediaItemSource_MangaImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String link, String description, Map<String, String>? headers)
        video,
    required TResult Function(
            String link, String description, Map<String, String>? headers)
        subtitle,
    required TResult Function(String description, Map<String, String>? headers,
            int pageNumbers, List<String>? pages, List<String> params)
        manga,
  }) {
    return manga(description, headers, pageNumbers, pages, params);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            String link, String description, Map<String, String>? headers)?
        video,
    TResult? Function(
            String link, String description, Map<String, String>? headers)?
        subtitle,
    TResult? Function(String description, Map<String, String>? headers,
            int pageNumbers, List<String>? pages, List<String> params)?
        manga,
  }) {
    return manga?.call(description, headers, pageNumbers, pages, params);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            String link, String description, Map<String, String>? headers)?
        video,
    TResult Function(
            String link, String description, Map<String, String>? headers)?
        subtitle,
    TResult Function(String description, Map<String, String>? headers,
            int pageNumbers, List<String>? pages, List<String> params)?
        manga,
    required TResult orElse(),
  }) {
    if (manga != null) {
      return manga(description, headers, pageNumbers, pages, params);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ContentMediaItemSource_Video value) video,
    required TResult Function(ContentMediaItemSource_Subtitle value) subtitle,
    required TResult Function(ContentMediaItemSource_Manga value) manga,
  }) {
    return manga(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ContentMediaItemSource_Video value)? video,
    TResult? Function(ContentMediaItemSource_Subtitle value)? subtitle,
    TResult? Function(ContentMediaItemSource_Manga value)? manga,
  }) {
    return manga?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ContentMediaItemSource_Video value)? video,
    TResult Function(ContentMediaItemSource_Subtitle value)? subtitle,
    TResult Function(ContentMediaItemSource_Manga value)? manga,
    required TResult orElse(),
  }) {
    if (manga != null) {
      return manga(this);
    }
    return orElse();
  }
}

abstract class ContentMediaItemSource_Manga extends ContentMediaItemSource {
  const factory ContentMediaItemSource_Manga(
      {required final String description,
      final Map<String, String>? headers,
      required final int pageNumbers,
      final List<String>? pages,
      required final List<String> params}) = _$ContentMediaItemSource_MangaImpl;
  const ContentMediaItemSource_Manga._() : super._();

  @override
  String get description;
  @override
  Map<String, String>? get headers;
  int get pageNumbers;
  List<String>? get pages;
  List<String> get params;

  /// Create a copy of ContentMediaItemSource
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ContentMediaItemSource_MangaImplCopyWith<
          _$ContentMediaItemSource_MangaImpl>
      get copyWith => throw _privateConstructorUsedError;
}
