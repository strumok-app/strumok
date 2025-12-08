import 'package:flutter/material.dart';

class NextPageIntent extends Intent {
  const NextPageIntent();
}

class PrevPageIntent extends Intent {
  const PrevPageIntent();
}

class NextMediaItemIntent extends Intent {
  const NextMediaItemIntent();
}

class PrevMediaItemIntent extends Intent {
  const PrevMediaItemIntent();
}

class ScrollDownIntent extends Intent {
  final bool page;
  const ScrollDownIntent({this.page = false});
}

class ScrollUpIntent extends Intent {
  final bool page;
  const ScrollUpIntent({this.page = false});
}

class ShowUIIntent extends Intent {
  const ShowUIIntent();
}

class ToggleFullscreanIntent extends Intent {
  const ToggleFullscreanIntent();
}
