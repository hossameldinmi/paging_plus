/// A lightweight and intuitive Dart library for pagination management.
///
/// This library provides the [Page] and [Paging] classes for easy pagination
/// handling in Dart and Flutter applications. It supports calculating page
/// information, determining the next page to fetch, and optimizing pagination
/// requests to minimize redundant data fetching.
///
/// ## Features
///
/// * Calculate page information from item counts
/// * Determine the next page to fetch intelligently
/// * Optimize pagination to avoid redundant data fetching
/// * Support for "load more" functionality
/// * Built on Equatable for easy comparison
///
/// ## Usage
///
/// ```dart
/// import 'package:paging_plus/paging_plus.dart';
///
/// void main() {
///   // Get the last page info
///   final page = Page.lastOf(25, 10);
///   print('Page ${page.pageNumber}: ${page.count} items');
///
///   // Calculate next pagination request
///   final paging = Paging.next(25, 10);
///   print('Fetch page ${paging.pageNumber} with size ${paging.pageSize}');
///
///   // Generate all pages
///   final pages = Page.getPages(25, 10);
///   print('Total pages: ${pages.length}');
/// }
/// ```
library paging_plus;

export 'src/page.dart';
export 'src/paging.dart';
