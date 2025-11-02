/// A lightweight Dart library for handling file size conversions and formatting.
///
/// This library provides the [SizedFile] class for easy file size manipulation
/// across different units (bytes, KB, MB, GB, TB) with support for custom
/// formatting and internationalization.
///
/// Example usage:
/// ```dart
/// import 'package:paging_plus/paging_plus.dart';
///
/// void main() {
///   final fileSize = SizedFile.mb(5);
///   print(fileSize.format()); // "5.00 MB"
///   print(fileSize.inBytes);  // 5242880
/// }
/// ```
library paging_plus;

export 'src/page.dart';
export 'src/paging.dart';
