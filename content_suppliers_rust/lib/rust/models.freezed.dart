// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ContentMediaItemSource {

 String get description; Map<String, String>? get headers; String? get language;
/// Create a copy of ContentMediaItemSource
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContentMediaItemSourceCopyWith<ContentMediaItemSource> get copyWith => _$ContentMediaItemSourceCopyWithImpl<ContentMediaItemSource>(this as ContentMediaItemSource, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ContentMediaItemSource;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContentMediaItemSource&&(identical(other.description, _this.description) || other.description == _this.description)&&const DeepCollectionEquality().equals(other.headers, _this.headers)&&(identical(other.language, _this.language) || other.language == _this.language));
}


@override
int get hashCode {
  final _this = this as ContentMediaItemSource;
  return Object.hash(runtimeType,_this.description,const DeepCollectionEquality().hash(_this.headers),_this.language);
}

@override
String toString() {
  final _this = this as ContentMediaItemSource;
  return 'ContentMediaItemSource(description: ${_this.description}, headers: ${_this.headers}, language: ${_this.language})';
}


}

/// @nodoc
abstract mixin class $ContentMediaItemSourceCopyWith<$Res>  {
  factory $ContentMediaItemSourceCopyWith(ContentMediaItemSource value, $Res Function(ContentMediaItemSource) _then) = _$ContentMediaItemSourceCopyWithImpl;
@useResult
$Res call({
 String description, Map<String, String>? headers, String? language
});




}
/// @nodoc
class _$ContentMediaItemSourceCopyWithImpl<$Res>
    implements $ContentMediaItemSourceCopyWith<$Res> {
  _$ContentMediaItemSourceCopyWithImpl(this._self, this._then);

  final ContentMediaItemSource _self;
  final $Res Function(ContentMediaItemSource) _then;

/// Create a copy of ContentMediaItemSource
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? description = null,Object? headers = freezed,Object? language = freezed,}) {
  return _then(_self.copyWith(
description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,headers: freezed == headers ? _self.headers : headers // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,language: freezed == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ContentMediaItemSource].
extension ContentMediaItemSourcePatterns on ContentMediaItemSource {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ContentMediaItemSource_Video value)?  video,TResult Function( ContentMediaItemSource_Subtitle value)?  subtitle,TResult Function( ContentMediaItemSource_Manga value)?  manga,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ContentMediaItemSource_Video() when video != null:
return video(_that);case ContentMediaItemSource_Subtitle() when subtitle != null:
return subtitle(_that);case ContentMediaItemSource_Manga() when manga != null:
return manga(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ContentMediaItemSource_Video value)  video,required TResult Function( ContentMediaItemSource_Subtitle value)  subtitle,required TResult Function( ContentMediaItemSource_Manga value)  manga,}){
final _that = this;
switch (_that) {
case ContentMediaItemSource_Video():
return video(_that);case ContentMediaItemSource_Subtitle():
return subtitle(_that);case ContentMediaItemSource_Manga():
return manga(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ContentMediaItemSource_Video value)?  video,TResult? Function( ContentMediaItemSource_Subtitle value)?  subtitle,TResult? Function( ContentMediaItemSource_Manga value)?  manga,}){
final _that = this;
switch (_that) {
case ContentMediaItemSource_Video() when video != null:
return video(_that);case ContentMediaItemSource_Subtitle() when subtitle != null:
return subtitle(_that);case ContentMediaItemSource_Manga() when manga != null:
return manga(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String link,  String description,  Map<String, String>? headers,  bool hlsProxy,  String? language)?  video,TResult Function( String link,  String description,  Map<String, String>? headers,  String? language)?  subtitle,TResult Function( String description,  Map<String, String>? headers,  List<String>? pages,  List<String> params,  String? language)?  manga,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ContentMediaItemSource_Video() when video != null:
return video(_that.link,_that.description,_that.headers,_that.hlsProxy,_that.language);case ContentMediaItemSource_Subtitle() when subtitle != null:
return subtitle(_that.link,_that.description,_that.headers,_that.language);case ContentMediaItemSource_Manga() when manga != null:
return manga(_that.description,_that.headers,_that.pages,_that.params,_that.language);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String link,  String description,  Map<String, String>? headers,  bool hlsProxy,  String? language)  video,required TResult Function( String link,  String description,  Map<String, String>? headers,  String? language)  subtitle,required TResult Function( String description,  Map<String, String>? headers,  List<String>? pages,  List<String> params,  String? language)  manga,}) {final _that = this;
switch (_that) {
case ContentMediaItemSource_Video():
return video(_that.link,_that.description,_that.headers,_that.hlsProxy,_that.language);case ContentMediaItemSource_Subtitle():
return subtitle(_that.link,_that.description,_that.headers,_that.language);case ContentMediaItemSource_Manga():
return manga(_that.description,_that.headers,_that.pages,_that.params,_that.language);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String link,  String description,  Map<String, String>? headers,  bool hlsProxy,  String? language)?  video,TResult? Function( String link,  String description,  Map<String, String>? headers,  String? language)?  subtitle,TResult? Function( String description,  Map<String, String>? headers,  List<String>? pages,  List<String> params,  String? language)?  manga,}) {final _that = this;
switch (_that) {
case ContentMediaItemSource_Video() when video != null:
return video(_that.link,_that.description,_that.headers,_that.hlsProxy,_that.language);case ContentMediaItemSource_Subtitle() when subtitle != null:
return subtitle(_that.link,_that.description,_that.headers,_that.language);case ContentMediaItemSource_Manga() when manga != null:
return manga(_that.description,_that.headers,_that.pages,_that.params,_that.language);case _:
  return null;

}
}

}

/// @nodoc


class ContentMediaItemSource_Video extends ContentMediaItemSource {
  const ContentMediaItemSource_Video({required this.link, required this.description,  Map<String, String>? headers, required this.hlsProxy, this.language}): _headers = headers,super._();
  

 final  String link;
@override final  String description;
 final  Map<String, String>? _headers;
@override Map<String, String>? get headers {
  final value = _headers;
  if (value == null) return null;
  if (_headers is EqualUnmodifiableMapView) return _headers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  bool hlsProxy;
@override final  String? language;

/// Create a copy of ContentMediaItemSource
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContentMediaItemSource_VideoCopyWith<ContentMediaItemSource_Video> get copyWith => _$ContentMediaItemSource_VideoCopyWithImpl<ContentMediaItemSource_Video>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ContentMediaItemSource_Video&&(identical(other.link, link) || other.link == link)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.headers, _headers)&&(identical(other.hlsProxy, hlsProxy) || other.hlsProxy == hlsProxy)&&(identical(other.language, language) || other.language == language));
}


@override
int get hashCode {
    return Object.hash(runtimeType,link,description,const DeepCollectionEquality().hash(_headers),hlsProxy,language);
}

@override
String toString() {
    return 'ContentMediaItemSource.video(link: $link, description: $description, headers: $headers, hlsProxy: $hlsProxy, language: $language)';
}


}

/// @nodoc
abstract mixin class $ContentMediaItemSource_VideoCopyWith<$Res> implements $ContentMediaItemSourceCopyWith<$Res> {
  factory $ContentMediaItemSource_VideoCopyWith(ContentMediaItemSource_Video value, $Res Function(ContentMediaItemSource_Video) _then) = _$ContentMediaItemSource_VideoCopyWithImpl;
@override @useResult
$Res call({
 String link, String description, Map<String, String>? headers, bool hlsProxy, String? language
});




}
/// @nodoc
class _$ContentMediaItemSource_VideoCopyWithImpl<$Res>
    implements $ContentMediaItemSource_VideoCopyWith<$Res> {
  _$ContentMediaItemSource_VideoCopyWithImpl(this._self, this._then);

  final ContentMediaItemSource_Video _self;
  final $Res Function(ContentMediaItemSource_Video) _then;

/// Create a copy of ContentMediaItemSource
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? link = null,Object? description = null,Object? headers = freezed,Object? hlsProxy = null,Object? language = freezed,}) {
  return _then(ContentMediaItemSource_Video(
link: null == link ? _self.link : link // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,headers: freezed == headers ? _self._headers : headers // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,hlsProxy: null == hlsProxy ? _self.hlsProxy : hlsProxy // ignore: cast_nullable_to_non_nullable
as bool,language: freezed == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class ContentMediaItemSource_Subtitle extends ContentMediaItemSource {
  const ContentMediaItemSource_Subtitle({required this.link, required this.description,  Map<String, String>? headers, this.language}): _headers = headers,super._();
  

 final  String link;
@override final  String description;
 final  Map<String, String>? _headers;
@override Map<String, String>? get headers {
  final value = _headers;
  if (value == null) return null;
  if (_headers is EqualUnmodifiableMapView) return _headers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  String? language;

/// Create a copy of ContentMediaItemSource
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContentMediaItemSource_SubtitleCopyWith<ContentMediaItemSource_Subtitle> get copyWith => _$ContentMediaItemSource_SubtitleCopyWithImpl<ContentMediaItemSource_Subtitle>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ContentMediaItemSource_Subtitle&&(identical(other.link, link) || other.link == link)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.headers, _headers)&&(identical(other.language, language) || other.language == language));
}


@override
int get hashCode {
    return Object.hash(runtimeType,link,description,const DeepCollectionEquality().hash(_headers),language);
}

@override
String toString() {
    return 'ContentMediaItemSource.subtitle(link: $link, description: $description, headers: $headers, language: $language)';
}


}

/// @nodoc
abstract mixin class $ContentMediaItemSource_SubtitleCopyWith<$Res> implements $ContentMediaItemSourceCopyWith<$Res> {
  factory $ContentMediaItemSource_SubtitleCopyWith(ContentMediaItemSource_Subtitle value, $Res Function(ContentMediaItemSource_Subtitle) _then) = _$ContentMediaItemSource_SubtitleCopyWithImpl;
@override @useResult
$Res call({
 String link, String description, Map<String, String>? headers, String? language
});




}
/// @nodoc
class _$ContentMediaItemSource_SubtitleCopyWithImpl<$Res>
    implements $ContentMediaItemSource_SubtitleCopyWith<$Res> {
  _$ContentMediaItemSource_SubtitleCopyWithImpl(this._self, this._then);

  final ContentMediaItemSource_Subtitle _self;
  final $Res Function(ContentMediaItemSource_Subtitle) _then;

/// Create a copy of ContentMediaItemSource
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? link = null,Object? description = null,Object? headers = freezed,Object? language = freezed,}) {
  return _then(ContentMediaItemSource_Subtitle(
link: null == link ? _self.link : link // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,headers: freezed == headers ? _self._headers : headers // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,language: freezed == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class ContentMediaItemSource_Manga extends ContentMediaItemSource {
  const ContentMediaItemSource_Manga({required this.description,  Map<String, String>? headers,  List<String>? pages, required  List<String> params, this.language}): _headers = headers,_pages = pages,_params = params,super._();
  

@override final  String description;
 final  Map<String, String>? _headers;
@override Map<String, String>? get headers {
  final value = _headers;
  if (value == null) return null;
  if (_headers is EqualUnmodifiableMapView) return _headers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  List<String>? _pages;
 List<String>? get pages {
  final value = _pages;
  if (value == null) return null;
  if (_pages is EqualUnmodifiableListView) return _pages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<String> _params;
 List<String> get params {
  if (_params is EqualUnmodifiableListView) return _params;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_params);
}

@override final  String? language;

/// Create a copy of ContentMediaItemSource
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContentMediaItemSource_MangaCopyWith<ContentMediaItemSource_Manga> get copyWith => _$ContentMediaItemSource_MangaCopyWithImpl<ContentMediaItemSource_Manga>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ContentMediaItemSource_Manga&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.headers, _headers)&&const DeepCollectionEquality().equals(other.pages, _pages)&&const DeepCollectionEquality().equals(other.params, _params)&&(identical(other.language, language) || other.language == language));
}


@override
int get hashCode {
    return Object.hash(runtimeType,description,const DeepCollectionEquality().hash(_headers),const DeepCollectionEquality().hash(_pages),const DeepCollectionEquality().hash(_params),language);
}

@override
String toString() {
    return 'ContentMediaItemSource.manga(description: $description, headers: $headers, pages: $pages, params: $params, language: $language)';
}


}

/// @nodoc
abstract mixin class $ContentMediaItemSource_MangaCopyWith<$Res> implements $ContentMediaItemSourceCopyWith<$Res> {
  factory $ContentMediaItemSource_MangaCopyWith(ContentMediaItemSource_Manga value, $Res Function(ContentMediaItemSource_Manga) _then) = _$ContentMediaItemSource_MangaCopyWithImpl;
@override @useResult
$Res call({
 String description, Map<String, String>? headers, List<String>? pages, List<String> params, String? language
});




}
/// @nodoc
class _$ContentMediaItemSource_MangaCopyWithImpl<$Res>
    implements $ContentMediaItemSource_MangaCopyWith<$Res> {
  _$ContentMediaItemSource_MangaCopyWithImpl(this._self, this._then);

  final ContentMediaItemSource_Manga _self;
  final $Res Function(ContentMediaItemSource_Manga) _then;

/// Create a copy of ContentMediaItemSource
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? description = null,Object? headers = freezed,Object? pages = freezed,Object? params = null,Object? language = freezed,}) {
  return _then(ContentMediaItemSource_Manga(
description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,headers: freezed == headers ? _self._headers : headers // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,pages: freezed == pages ? _self._pages : pages // ignore: cast_nullable_to_non_nullable
as List<String>?,params: null == params ? _self._params : params // ignore: cast_nullable_to_non_nullable
as List<String>,language: freezed == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
