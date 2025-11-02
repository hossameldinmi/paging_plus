import 'package:equatable/equatable.dart';
import 'package:paging_plus/paging_plus.dart';

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
class Paging extends Equatable {
  /// The page number to fetch (1-indexed).
  final int pageNumber;

  /// The number of items to fetch per page.
  final int pageSize;

  /// Whether the pagination strategy may result in duplicate items.
  ///
  /// This is set to true when the algorithm optimizes page size in a way
  /// that might overlap with previously fetched data.
  final bool shouldHasDuplicates;

  /// Creates a new [Paging] request.
  ///
  /// * [pageNumber] - The page number to fetch (1-indexed)
  /// * [pageSize] - The number of items per page
  /// * [shouldHasDuplicates] - Whether duplicates may occur (default: false)
  const Paging(this.pageNumber, this.pageSize, [this.shouldHasDuplicates = false]);

  @override
  List<Object> get props => [pageNumber, pageSize, shouldHasDuplicates];

  @override
  bool get stringify => true;

  /// Calculates the next page to fetch with optional optimization.
  ///
  /// This factory constructor intelligently determines the next pagination
  /// request based on the current item count. It can optimize the page size
  /// to avoid redundant fetching when the last page is partially filled.
  ///
  /// * [itemCount] - The current total number of items already fetched
  /// * [pageSize] - The desired number of items per page
  /// * [fetchLatestIfHasRemaining] - If true, always re-fetch the latest page
  ///   if it has remaining slots (default: true)
  /// * [minimumRemainingsToTake] - Minimum number of remaining slots required
  ///   before considering optimization (default: 0)
  /// * [minimumToRequest] - Minimum number of items to request in optimized
  ///   pagination (default: 1)
  ///
  /// Returns a [Paging] object specifying the next page to fetch.
  ///
  /// Example:
  /// ```dart
  /// // Fetch next page with 50 items already loaded, page size 20
  /// final paging = Paging.next(50, 20);
  /// print(paging.pageNumber); // 3
  ///
  /// // With optimization disabled for partial pages
  /// final optimized = Paging.next(50, 20, false);
  /// ```
  factory Paging.next(int itemCount, int pageSize,
      [bool fetchLatestIfHasRemaining = true, int minimumRemainingsToTake = 0, int minimumToRequest = 1]) {
    if (itemCount == 0) {
      return Paging(1, pageSize);
    }
    final latestPage = Page.latestPage(itemCount, pageSize);
    if (latestPage.hasRemaining) {
      if (fetchLatestIfHasRemaining || latestPage.count < minimumRemainingsToTake) {
        return Paging(latestPage.pageNumber, pageSize);
      } else {
        return _calcutaionOptimizedPagination(
            itemCount, pageSize, latestPage.remainingsCount, latestPage, minimumToRequest);
      }
    }
    return Paging(latestPage.pageNumber + 1, pageSize);
  }

  /// Internal method that calculates an optimized pagination strategy.
  ///
  /// This method uses the greatest common divisor (GCD) algorithm to find
  /// an optimal page size that minimizes redundant data fetching when dealing
  /// with partially filled pages.
  ///
  /// The algorithm recursively adjusts the page size to find the best fit
  /// that satisfies the minimum request requirements while avoiding unnecessary
  /// data transfer.
  static Paging _calcutaionOptimizedPagination(int itemCount, int pageSize, int remainings, Page lastPage,
      [int minimumToRequest = 1, bool willHaveDuplicates = false]) {
    final gcd = lastPage.expectedTotalCount.gcd(remainings);
    //todo:add minmum to request if (gcd >= remainings && gcd >= minimumToRequest) {
    if (gcd >= remainings) {
      return Paging(lastPage.pageNumber * pageSize ~/ gcd, gcd, willHaveDuplicates);
    } else {
      final newPageSize = remainings + 1;
      final newLastPage = Page.latestPage(itemCount, newPageSize);
      return _calcutaionOptimizedPagination(itemCount, newPageSize, newPageSize, newLastPage, minimumToRequest, true);
    }
  }
}
