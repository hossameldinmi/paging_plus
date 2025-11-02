import 'package:equatable/equatable.dart';
import 'package:paging_plus/paging_plus.dart';

class Paging extends Equatable {
  final int pageNumber;
  final int pageSize;
  final bool shouldHasDuplicates;

  const Paging(this.pageNumber, this.pageSize, [this.shouldHasDuplicates = false]);

  @override
  List<Object> get props => [pageNumber, pageSize, shouldHasDuplicates];

  @override
  bool get stringify => true;

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
