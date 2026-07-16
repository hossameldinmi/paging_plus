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
class Page {
  /// The current page number (1-indexed).
  final int pageNumber;

  /// The number of items currently in this page.
  final int count;

  /// The number of remaining slots in this page.
  final int remainingCount;

  /// Whether this page has remaining slots to be filled.
  bool get hasRemaining => remainingCount > 0;

  /// The total size of the page (count + remaining slots).
  int get pageSize => remainingCount + count;

  /// The total number of items up to and including this page.
  ///
  /// Assumes all previous pages share this page's [pageSize].
  int get currentTotalCount => ((pageNumber - 1) * pageSize) + count;

  /// Creates a new [Page] with the specified page number, item count, and remaining slots.
  ///
  /// * [pageNumber] - The page number (1-indexed, must be >= 1)
  /// * [count] - The number of items in this page (must be >= 0)
  /// * [remainingCount] - The number of empty slots in this page (must be >= 0)
  const Page(this.pageNumber, this.count, this.remainingCount)
      : assert(pageNumber >= 1, 'pageNumber must be at least 1'),
        assert(count >= 0, 'count must not be negative'),
        assert(remainingCount >= 0, 'remainingCount must not be negative');

  /// Creates the last page based on the total item count and page size.
  ///
  /// This factory constructor calculates which page the last item would be on
  /// and returns a [Page] representing that page with its current item count
  /// and remaining slots.
  ///
  /// * [itemCount] - The total number of items (must be >= 0)
  /// * [pageSize] - The number of items per page (must be >= 1)
  ///
  /// Throws an [ArgumentError] if [itemCount] is negative or [pageSize] is
  /// less than 1.
  ///
  /// Example:
  /// ```dart
  /// // With 25 items and page size of 10
  /// final page = Page.lastOf(25, 10);
  /// print(page.pageNumber); // 3
  /// print(page.count); // 5
  /// print(page.remainingCount); // 5
  /// ```
  factory Page.lastOf(int itemCount, int pageSize) {
    _validate(itemCount, pageSize);
    if (itemCount <= pageSize) {
      return Page(1, itemCount, pageSize - itemCount);
    }
    final pageNumber = (itemCount / pageSize).ceil();
    final remainder = itemCount % pageSize;
    final lastPageItems = remainder == 0 ? pageSize : remainder;
    return Page(pageNumber, lastPageItems, pageSize - lastPageItems);
  }

  /// Generates a list of all pages needed to display the given number of items.
  ///
  /// This static method creates a complete list of [Page] objects representing
  /// all pages required to display [itemCount] items with the specified [pageSize].
  ///
  /// * [itemCount] - The total number of items to paginate (must be >= 0)
  /// * [pageSize] - The number of items per page (must be >= 1)
  ///
  /// Returns a list of [Page] objects, each representing a page in the pagination.
  ///
  /// Throws an [ArgumentError] if [itemCount] is negative or [pageSize] is
  /// less than 1.
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
    _validate(itemCount, pageSize);
    final pageCount = (itemCount / pageSize).ceil();
    return List.generate(pageCount, (index) {
      final isLastPage = index == pageCount - 1;
      final count = isLastPage ? itemCount - index * pageSize : pageSize;
      return Page(index + 1, count, pageSize - count);
    });
  }

  static void _validate(int itemCount, int pageSize) {
    if (itemCount < 0) {
      throw ArgumentError.value(itemCount, 'itemCount', 'must not be negative');
    }
    if (pageSize < 1) {
      throw ArgumentError.value(pageSize, 'pageSize', 'must be at least 1');
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Page && pageNumber == other.pageNumber && count == other.count && remainingCount == other.remainingCount;

  @override
  int get hashCode => Object.hash(pageNumber, count, remainingCount);

  @override
  String toString() => 'Page(pageNumber: $pageNumber, count: $count, remainingCount: $remainingCount)';
}
