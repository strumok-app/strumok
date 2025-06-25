import 'package:flutter/material.dart';

extension MatrixUtils on Matrix4 {
  bool isScaled() => entry(0, 0) != 1.0;
}
