import 'dart:math' as math;

import 'page.dart';

/// Represents a pagination request with optimized page size calculation.
///
/// [Paging] is used to determine the next page to fetch in a paginated list.
/// It can optimize the page size to minimize redundant data fetching when
/// dealing with partially filled pages.
///
/// Example:
/// ```dart
/// // Simple next page calculation
/// final paging = Paging.next(50, 20);
/// print(paging.pageNumber); // 3
/// print(paging.pageSize); // 20
/// ```
class Paging {
  /// The page number to fetch (1-indexed).
  final int pageNumber;

  /// The number of items to fetch per page.
  final int pageSize;

  /// Creates a new [Paging] request.
  ///
  /// * [pageNumber] - The page number to fetch (1-indexed, must be >= 1)
  /// * [pageSize] - The number of items per page (must be >= 1)
  const Paging(this.pageNumber, this.pageSize)
      : assert(pageNumber >= 1, 'pageNumber must be at least 1'),
        assert(pageSize >= 1, 'pageSize must be at least 1');

  /// Calculates the next page to fetch with optional optimization.
  ///
  /// This factory constructor determines the next pagination request based on
  /// the number of items already fetched. When the last page is only partially
  /// filled it can either re-fetch that page as-is, or pick an alternative page
  /// size that minimizes how many already-fetched items are downloaded again.
  ///
  /// * [itemCount] - The current total number of items already fetched
  ///   (must be >= 0)
  /// * [pageSize] - The desired number of items per page (must be >= 1)
  /// * [refetchPartialLastPage] - If true (the default), a partially filled
  ///   last page is simply re-fetched with the original [pageSize]
  /// * [minCountToOptimize] - Only optimize when the last page already holds
  ///   at least this many items; below the threshold the last page is
  ///   re-fetched instead (default: 0, must be >= 0)
  /// * [minPageSize] - The smallest page size the optimizer may pick
  ///   (must be between 1 and [pageSize]). Defaults to half of [pageSize],
  ///   which prevents degenerate results like a page size of 1
  ///
  /// The optimizer searches page sizes from [pageSize] down to [minPageSize]
  /// and picks the one whose fetch window starts closest to [itemCount],
  /// preferring the largest size on ties. When a chosen size divides
  /// [itemCount] evenly, the request contains no duplicates at all.
  ///
  /// The result always satisfies two guarantees:
  /// * no gap: `(pageNumber - 1) * pageSize <= itemCount`
  /// * progress: `pageNumber * pageSize > itemCount`
  ///
  /// Throws an [ArgumentError] if any argument is out of range.
  ///
  /// Example:
  /// ```dart
  /// // Fetch next page with 50 items already loaded, page size 20
  /// final paging = Paging.next(50, 20);
  /// print(paging.pageNumber); // 3
  ///
  /// // Avoid re-fetching the whole partial last page
  /// final optimized = Paging.next(15, 10, refetchPartialLastPage: false);
  /// print(optimized); // Paging(pageNumber: 4, pageSize: 5)
  /// ```
  factory Paging.next(
    int itemCount,
    int pageSize, {
    bool refetchPartialLastPage = true,
    int minCountToOptimize = 0,
    int? minPageSize,
  }) {
    if (minCountToOptimize < 0) {
      throw ArgumentError.value(minCountToOptimize, 'minCountToOptimize', 'must not be negative');
    }
    if (minPageSize != null && (minPageSize < 1 || minPageSize > pageSize)) {
      throw ArgumentError.value(minPageSize, 'minPageSize', 'must be between 1 and pageSize ($pageSize)');
    }
    // Validates itemCount and pageSize.
    final lastPage = Page.lastOf(itemCount, pageSize);

    if (itemCount == 0) {
      return Paging(1, pageSize);
    }
    if (!lastPage.hasRemaining) {
      return Paging(lastPage.pageNumber + 1, pageSize);
    }
    if (refetchPartialLastPage || lastPage.count < minCountToOptimize) {
      return Paging(lastPage.pageNumber, pageSize);
    }
    return _optimizedNext(
      itemCount,
      pageSize,
      minPageSize ?? math.max(1, pageSize ~/ 2),
    );
  }

  /// Finds the page size within `[minPageSize, pageSize]` whose fetch window
  /// starts closest to [itemCount], so the request downloads as few
  /// already-fetched items as possible.
  ///
  /// For a candidate size `s` the request is page `itemCount ~/ s + 1`, which
  /// starts at offset `itemCount - itemCount % s`; the overlap with existing
  /// items is therefore `itemCount % s`. Searching downwards keeps the largest
  /// size among equally good candidates, and an overlap of zero (a divisor of
  /// [itemCount]) ends the search early.
  static Paging _optimizedNext(int itemCount, int pageSize, int minPageSize) {
    var bestSize = pageSize;
    var bestOverlap = itemCount % pageSize;
    for (var size = pageSize - 1; size >= minPageSize && bestOverlap > 0; size--) {
      final overlap = itemCount % size;
      if (overlap < bestOverlap) {
        bestSize = size;
        bestOverlap = overlap;
      }
    }
    return Paging(itemCount ~/ bestSize + 1, bestSize);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Paging && pageNumber == other.pageNumber && pageSize == other.pageSize;

  @override
  int get hashCode => Object.hash(pageNumber, pageSize);

  @override
  String toString() => 'Paging(pageNumber: $pageNumber, pageSize: $pageSize)';
}
