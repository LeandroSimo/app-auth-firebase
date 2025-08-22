import 'package:flutter/material.dart';

extension MediaQueryExtension on BuildContext {
  Size get mediaQuery => MediaQuery.sizeOf(this);
}
