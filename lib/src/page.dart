import 'package:equatable/equatable.dart';

/// Represents a single page in a paginated dataset.
///
/// A [Page] contains information about the current page number, the number of items
/// in the page, and how many items remain to fill the page. This is useful for
/// implementing pagination logic in applications.
///
/// Example:
/// ```dart
/// // Create a page with 10 items on page 1, with 5 remaining slots
/// final page = Page(1, 10, 5);
/// print(page.pageSize); // 15
/// print(page.hasRemaining); // true
/// ```
class Page extends Equatable {
  /// The current page number (1-indexed).
  final int pageNumber;

  /// The number of items currently in this page.
  final int count;

  /// The number of remaining slots in this page.
  final int remainingsCount;

  /// Whether this page has remaining slots to be filled.
  bool get hasRemaining => remainingsCount > 0;

  /// The total size of the page (count + remaining slots).
  int get pageSize => remainingsCount + count;

  /// The total number of items up to and including this page.
  int get currentTotalCount => ((pageNumber - 1) * pageSize) + count;

  /// Creates a new [Page] with the specified page number, item count, and remaining slots.
  ///
  /// * [pageNumber] - The page number (1-indexed)
  /// * [count] - The number of items in this page
  /// * [remainingsCount] - The number of empty slots in this page
  const Page(this.pageNumber, this.count, this.remainingsCount);

  @override
  List<Object> get props => [pageNumber, count, remainingsCount];

  /// Creates the latest (most recent) page based on the total item count and page size.
  ///
  /// This factory constructor calculates which page the last item would be on
  /// and returns a [Page] representing that page with its current item count
  /// and remaining slots.
  ///
  /// * [itemCount] - The total number of items
  /// * [pageSize] - The number of items per page
  ///
  /// Example:
  /// ```dart
  /// // With 25 items and page size of 10
  /// final page = Page.latestPage(25, 10);
  /// print(page.pageNumber); // 3
  /// print(page.count); // 5
  /// print(page.remainingsCount); // 5
  /// ```
  factory Page.latestPage(int itemCount, int pageSize) {
    if (itemCount <= pageSize) {
      return Page(1, itemCount, pageSize - itemCount);
    }
    final pageNumber = (itemCount / pageSize).ceil();
    final remaining = itemCount % pageSize;
    final latestPageItems = remaining == 0 ? pageSize : remaining;
    return Page(pageNumber, latestPageItems, pageSize - latestPageItems);
  }

  /// Generates a list of all pages needed to display the given number of items.
  ///
  /// This static method creates a complete list of [Page] objects representing
  /// all pages required to display [itemCount] items with the specified [pageSize].
  ///
  /// * [itemCount] - The total number of items to paginate
  /// * [pageSize] - The number of items per page
  ///
  /// Returns a list of [Page] objects, each representing a page in the pagination.
  ///
  /// Example:
  /// ```dart
  /// final pages = Page.getPages(25, 10);
  /// print(pages.length); // 3
  /// print(pages[0].count); // 10
  /// print(pages[1].count); // 10
  /// print(pages[2].count); // 5
  /// ```
  static List<Page> getPages(int itemCount, int pageSize) {
    final pages = <Page>[];
    int remainingItems = itemCount;
    int currentPageNumber = 1;

    while (remainingItems > 0) {
      final currentPageItems = remainingItems >= pageSize ? pageSize : remainingItems;
      final remainingsCount = pageSize - currentPageItems;
      pages.add(Page(currentPageNumber, currentPageItems, remainingsCount));
      remainingItems -= currentPageItems;
      currentPageNumber++;
    }
    return pages;
  }

  @override
  bool get stringify => true;
}
