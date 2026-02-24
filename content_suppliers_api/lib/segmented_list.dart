abstract interface class PositioningItem {
  int get position;
}

/// A collection that groups contiguous items and skips gaps during iteration.
class SegmentedList<T extends PositioningItem> extends Iterable<T> {
  final List<_Segment<T>> _segments;
  final int _maxPosition;

  const SegmentedList._(List<_Segment<T>> segments, int maxPosition)
    : _segments = segments,
      _maxPosition = maxPosition;

  factory SegmentedList.empty() {
    return SegmentedList._(const [], 0);
  }

  /// Constructs from an [Iterable] of items that must be sorted by their
  /// [PositioningItem.position].
  ///
  /// The iterable is walked only once; random access is **not** required. Gaps
  /// between positions are skipped when iterating the resulting list.
  factory SegmentedList.fromIterable(Iterable<T> sortedItems) {
    final iterator = sortedItems.iterator;
    if (!iterator.moveNext()) return SegmentedList.empty();

    // initialize with first element
    final first = iterator.current;
    int maxPosition = first.position;

    List<T> currentGroup = [first];
    int startPos = first.position;
    int previousPos = first.position;

    List<_Segment<T>> segments = [];

    while (iterator.moveNext()) {
      final current = iterator.current;

      if (current.position == previousPos + 1) {
        currentGroup.add(current);
      } else {
        segments.add(_Segment(startPos, List.from(currentGroup)));
        currentGroup = [current];
        startPos = current.position;
      }

      previousPos = current.position;
      if (previousPos > maxPosition) {
        maxPosition = previousPos;
      }
    }

    segments.add(_Segment(startPos, currentGroup));

    return SegmentedList._(segments, maxPosition);
  }

  /// Length is still the max position found in the original list.
  @override
  int get length => _maxPosition;

  /// Returns item at the specific position index, or null if it's a gap.
  T? operator [](int index) {
    // Basic bounds check
    if (index < 0 || index > _maxPosition) return null;

    for (var segment in _segments) {
      if (index >= segment.start && index <= segment.end) {
        return segment.items[index - segment.start];
      }
      if (segment.start > index) break;
    }
    return null;
  }

  /// Iterator now only yields existing items, jumping over the gaps.
  @override
  Iterator<T> get iterator => _Iterator(this);

  // ---------------------------------------------------------------------
  // Equality and hashing
  // ---------------------------------------------------------------------

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SegmentedList<T>) return false;

    if (_maxPosition != other._maxPosition) return false;
    if (_segments.length != other._segments.length) return false;

    for (int i = 0; i < _segments.length; i++) {
      if (_segments[i] != other._segments[i]) {
        return false;
      }
    }

    return true;
  }

  @override
  int get hashCode => Object.hash(_maxPosition, Object.hashAll(_segments));
}

class _Segment<T> {
  final int start;
  final List<T> items;
  _Segment(this.start, this.items);

  int get end => start + items.length - 1;

  // Equality is structural so that two segments with the same start
  // and equal items compare equal. Note that T should itself implement
  // == correctly (typically the case for `PositioningItem`s used in
  // the codebase).
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! _Segment<T>) return false;
    if (start != other.start) return false;
    if (items.length != other.items.length) return false;
    for (int i = 0; i < items.length; i++) {
      if (items[i] != other.items[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(start, Object.hashAll(items));
}

class _Iterator<T extends PositioningItem> implements Iterator<T> {
  final SegmentedList<T> _list;
  int _segmentIndex = 0;
  int _itemIndex = -1;

  _Iterator(this._list);

  @override
  T get current => _list._segments[_segmentIndex].items[_itemIndex];

  @override
  bool moveNext() {
    if (_list._segments.isEmpty) return false;

    _itemIndex++;

    // If we've reached the end of the current segment, jump to the next one
    if (_itemIndex >= _list._segments[_segmentIndex].items.length) {
      _segmentIndex++;
      _itemIndex = 0;
    }

    // If there are no more segments, we're done
    return _segmentIndex < _list._segments.length;
  }
}

/// Extension for converting an iterator of positioning items into
/// a [SegmentedList]. Calling this will consume the iterator.
extension PositioningIteratorExtension<T extends PositioningItem>
    on Iterable<T> {
  SegmentedList<T> toSegmentedList() => SegmentedList.fromIterable(this);
}
